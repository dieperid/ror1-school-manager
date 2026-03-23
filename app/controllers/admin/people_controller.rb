module Admin
  class PeopleController < BaseController
    before_action :build_person, only: %i[new create]
    before_action :set_person, only: %i[show edit update destroy]
    before_action :prepare_form_dependencies, only: %i[new edit]

    def index
      @role_filter_options = role_filter_options
      @role_filter = selected_role_filter
      @people, @pagination = paginate_scope(filtered_people_scope)
    end

    def show
    end

    def new
    end

    def create
      @person.assign_attributes(person_params)
      prepare_form_dependencies(assign_role_attributes: true)

      if valid_submission?
        save_person_with_dependencies!
        redirect_after_create
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @person.assign_attributes(person_params)
      prepare_form_dependencies(assign_role_attributes: true)

      if valid_update_submission?
        save_person_with_dependencies!
        redirect_to admin_person_path(@person), notice: "#{@person.full_name} was updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @person == current_person
        redirect_to admin_person_path(@person), alert: "You cannot delete your own person record while signed in."
        return
      end

      deleted_name = @person.full_name
      @person.destroy!
      redirect_to admin_people_path, notice: "#{deleted_name} was deleted."
    end

    private

    def build_person
      @person = Person.new
      @account_email = account_params[:email].to_s.strip.downcase
      @account_admin = ActiveModel::Type::Boolean.new.cast(account_params.fetch(:admin, "0")) || false
    end

    def prepare_form_dependencies(assign_role_attributes: false)
      @departure_reasons = DepartureReason.order(:title)
      @collaborator_roles = CollaboratorRole.order(:title)
      @person_role_type = requested_person_role_type
      @collaborator_form = @person.collaborator || Collaborator.new(person: @person)
      @student_form = @person.student || Student.new(person: @person, repeating_grade: false)
      @selected_collaborator_role_ids = selected_collaborator_role_ids
      @new_collaborator_role_titles = new_collaborator_role_titles

      return unless assign_role_attributes

      @collaborator_form.assign_attributes(collaborator_attributes_for_assignment)
      @student_form.assign_attributes(student_attributes_for_assignment)
    end

    def person_params
      params.fetch(:person, {}).permit(
        :avs_number,
        :birth_date,
        :city,
        :first_name,
        :last_name,
        :phone_number,
        :postal_code,
        :street,
        :street_number
      )
    end

    def account_params
      params.fetch(:account, {}).permit(:email, :admin)
    end

    def collaborator_form_params
      params.fetch(:collaborator, {}).permit(:contract_begin, :contract_end, :new_role_titles, collaborator_role_ids: [])
    end

    def student_params
      params.fetch(:student, {}).permit(
        :admission_date,
        :departure_date,
        :departure_reason_id,
        :repeating_grade
      )
    end

    def set_person
      @person = Person.find(params[:id])
    end

    def requested_person_role_type
      params.fetch(:person, {}).fetch(:role_type, @person.role_type).presence || "none"
    end

    def selected_role_filter
      @role_filter_options.map(&:last).include?(params[:role]) ? params[:role] : "all"
    end

    def role_filter_options
      [
        ["All roles", "all"],
        ["Admin accounts", "admin_account"],
        ["Collaborators", "collaborator"],
        ["Students", "student"],
        ["No role", "none"]
      ] + CollaboratorRole.order(:title).pluck(:title, :id).map { |title, id| ["Collaborator role: #{title}", "collaborator_role:#{id}"] }
    end

    def collaborator_role_filter_id
      return unless @role_filter.start_with?("collaborator_role:")

      Integer(@role_filter.delete_prefix("collaborator_role:"), exception: false)
    end

    def filtered_people_scope
      scope = Person
        .includes(:account, { collaborator: :collaborator_roles }, :student)
        .left_outer_joins(:account, :student, collaborator: :collaborator_roles)
        .distinct
        .order(:last_name, :first_name)

      case @role_filter
      when "admin_account"
        scope.where(accounts: { admin: true })
      when "collaborator"
        scope.where.not(collaborators: { id: nil })
      when "student"
        scope.where.not(students: { id: nil })
      when "none"
        scope.where(collaborators: { id: nil }, students: { id: nil })
      else
        collaborator_role_filter_id.present? ? scope.where(collaborator_roles: { id: collaborator_role_filter_id }) : scope
      end
    end

    def account_requested?
      @account_email.present?
    end

    def valid_submission?
      person_valid = @person.valid?
      account_valid = account_requested? ? invitation_account.valid? : true
      merge_account_errors unless account_valid
      role_valid = valid_role_form?
      person_valid && account_valid && role_valid
    end

    def valid_update_submission?
      @person.valid? && valid_role_form?
    end

    def invitation_account
      temporary_password = @temporary_password ||= Account.generate_temporary_password

      @invitation_account ||= Account.new(
        person: @person,
        email: @account_email,
        admin: @account_admin,
        enabled: true,
        password: temporary_password,
        password_confirmation: temporary_password
      )
    end

    def merge_account_errors
      invitation_account.errors.full_messages.each do |message|
        @person.errors.add(:base, message)
      end
    end

    def merge_role_errors(resource)
      resource.errors.full_messages.each do |message|
        @person.errors.add(:base, message)
      end
    end

    def collaborator_attributes_for_assignment
      collaborator_form_params.slice(:contract_begin, :contract_end).to_h
    end

    def student_attributes_for_assignment
      attributes = student_params.to_h
      attributes["departure_reason_id"] = nil if attributes["departure_reason_id"].blank?
      attributes["repeating_grade"] = ActiveModel::Type::Boolean.new.cast(attributes.fetch("repeating_grade", "0"))
      attributes
    end

    def collaborator_role?
      @person_role_type == "collaborator"
    end

    def student_role?
      @person_role_type == "student"
    end

    def valid_role_form?
      if collaborator_role?
        valid = @collaborator_form.valid?
        merge_role_errors(@collaborator_form) unless valid
        valid && collaborator_roles_request_valid?
      elsif student_role?
        valid = @student_form.valid?
        merge_role_errors(@student_form) unless valid
        valid
      else
        true
      end
    end

    def save_person_with_dependencies!
      Person.transaction do
        @person.save!
        sync_role_records!

        if account_requested?
          invitation_account.person = @person
          invitation_account.save!
        end
      end
    end

    def sync_role_records!
      case @person_role_type
      when "collaborator"
        save_collaborator!
        @person.student&.destroy!
      when "student"
        save_student!
        @person.collaborator&.destroy!
      else
        @person.collaborator&.destroy!
        @person.student&.destroy!
      end
    end

    def save_collaborator!
      collaborator = @person.collaborator || @person.build_collaborator
      collaborator.assign_attributes(collaborator_attributes_for_assignment)
      collaborator.save!
      collaborator.collaborator_roles = collaborator_roles_for_assignment
      @collaborator_form = collaborator
    end

    def save_student!
      student = @person.student || @person.build_student
      student.assign_attributes(student_attributes_for_assignment)
      student.save!
    end

    def selected_collaborator_role_ids
      ids =
        if params[:collaborator].present?
          collaborator_form_params[:collaborator_role_ids]
        else
          @person.collaborator&.collaborator_role_ids || []
        end

      Array(ids).reject(&:blank?).map(&:to_i).uniq
    end

    def new_collaborator_role_titles
      return collaborator_form_params[:new_role_titles].to_s if params[:collaborator].present?

      ""
    end

    def parsed_new_collaborator_role_titles
      new_collaborator_role_titles.split(/[\n,;]+/).map(&:strip).reject(&:blank?).each_with_object([]) do |title, titles|
        titles << title unless titles.any? { |existing_title| existing_title.casecmp?(title) }
      end
    end

    def collaborator_roles_request_valid?
      valid = true
      existing_ids = CollaboratorRole.where(id: selected_collaborator_role_ids).pluck(:id)

      if existing_ids.sort != selected_collaborator_role_ids.sort
        @person.errors.add(:base, "One or more collaborator roles are invalid")
        valid = false
      end

      roles_to_create.each do |role|
        next if role.valid?

        merge_role_errors(role)
        valid = false
      end

      valid
    end

    def collaborator_roles_for_assignment
      selected_roles = CollaboratorRole.where(id: selected_collaborator_role_ids).order(:title).to_a
      selected_roles + roles_to_create.map { |role| CollaboratorRole.find_or_create_by!(title: role.title) }
    end

    def roles_to_create
      @roles_to_create ||= parsed_new_collaborator_role_titles.filter_map do |title|
        next if CollaboratorRole.exists?(title: title)

        CollaboratorRole.new(title: title)
      end
    end

    def redirect_after_create
      if account_requested?
        redirect_to admin_person_account_invitation_path(@person, format: :txt)
      else
        redirect_to admin_person_path(@person), notice: success_message
      end
    end

    def success_message
      "#{@person.full_name} was created."
    end
  end
end
