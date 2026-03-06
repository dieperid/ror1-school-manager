module Admin
  class PeopleController < BaseController
    before_action :build_person, only: %i[new create]
    before_action :set_person, only: :invitation

    def index
      @people = Person.includes(:account).order(:last_name, :first_name)
    end

    def new
    end

    def create
      @person.assign_attributes(person_params)

      if valid_submission?
        save_person_and_account!
        redirect_after_create
      else
        render :new, status: :unprocessable_entity
      end
    end

    def invitation
      account = @person.account

      if account.blank?
        redirect_to admin_people_path, alert: "This person does not have a linked account."
        return
      end

      token = account.generate_password_setup_token!

      send_data(
        invitation_contents(account, token),
        filename: invitation_filename,
        type: "text/plain; charset=utf-8",
        disposition: "attachment"
      )
    end

    private

    def build_person
      @person = Person.new
      @account_email = account_params[:email].to_s.strip.downcase
      @account_admin = ActiveModel::Type::Boolean.new.cast(account_params.fetch(:admin, "0")) || false
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

    def set_person
      @person = Person.find(params[:id])
    end

    def account_requested?
      @account_email.present?
    end

    def valid_submission?
      person_valid = @person.valid?
      account_valid = account_requested? ? invitation_account.valid? : true
      merge_account_errors unless account_valid
      person_valid && account_valid
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

    def save_person_and_account!
      Person.transaction do
        @person.save!

        if account_requested?
          invitation_account.person = @person
          invitation_account.save!
        end
      end
    end

    def redirect_after_create
      if account_requested?
        redirect_to invitation_admin_person_path(@person, format: :txt)
      else
        redirect_to admin_people_path, notice: success_message
      end
    end

    def success_message
      message = "#{@person.full_name} was created."
      return message unless account_requested?

      "#{message} The invitation file is ready for download."
    end

    def invitation_contents(account, token)
      <<~TEXT
        Ror1 School Manager account invitation

        Name: #{@person.full_name}
        Username: #{account.email}

        Set password link:
        #{edit_account_password_url(reset_password_token: token)}
      TEXT
    end

    def invitation_filename
      "#{@person.full_name.parameterize.presence || "person"}-invitation.txt"
    end
  end
end
