module Admin
  class GradesController < BaseController
    before_action :set_unit
    before_action :build_grade, only: %i[new create]
    before_action :set_grade, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]
    before_action :redirect_collaborator_public_path!, only: %i[new show edit]

    def show
    end

    def new
    end

    def create
      @grade.assign_attributes(grade_params)
      ensure_selected_student_is_allowed!

      if @grade.errors.empty? && @grade.save
        redirect_to unit_path_for_current_account(@unit), notice: "Grade created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @grade.assign_attributes(grade_params)
      ensure_selected_student_is_allowed!

      if @grade.errors.empty? && @grade.save
        redirect_to unit_path_for_current_account(@unit), notice: "Grade updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @grade.destroy!
      redirect_to unit_path_for_current_account(@unit), notice: "Grade deleted."
    end

    private

    def collaborator_access_allowed?
      return false unless current_collaborator.present?

      Unit.taught_by(current_collaborator).where(id: params[:unit_id]).exists?
    end

    def set_unit
      @unit = if current_admin_or_dean?
        Unit.find(params[:unit_id])
      else
        Unit.taught_by(current_collaborator).find(params[:unit_id])
      end
    end

    def build_grade
      @grade = @unit.grades.build(student_id: params[:student_id], awarded_on: params[:awarded_on])
    end

    def set_grade
      @grade = visible_grades.includes(:unit, student: :person).find(params[:id])
    end

    def load_form_dependencies
      @students = available_students.includes(:person).to_a.sort_by { |student| [student.person.last_name, student.person.first_name] }
    end

    def ensure_prerequisites!
      if @students.empty?
        redirect_to unit_path_for_current_account(@unit), alert: "No eligible students are linked to this unit yet."
        return
      end
    end

    def visible_grades
      return @unit.grades if current_admin_or_dean?

      @unit.grades.where(student_id: @unit.eligible_students.select(:id))
    end

    def available_students
      return Student.all if current_admin_or_dean?

      @unit.eligible_students
    end

    def ensure_selected_student_is_allowed!
      return if @grade.student_id.blank?
      return if @students.any? { |student| student.id == @grade.student_id }

      @grade.errors.add(:student, "must belong to a formation plan that includes this unit")
    end

    def redirect_collaborator_public_path!
      return unless current_collaborator.present?
      return unless request.path.start_with?("/admin/")

      redirect_to(
        case action_name
        when "new"
          new_unit_grade_path(@unit)
        when "show"
          unit_grade_path(@unit, @grade)
        when "edit"
          edit_unit_grade_path(@unit, @grade)
        end
      )
    end

    def grade_params
      params.fetch(:grade, {}).permit(:value, :awarded_on, :student_id)
    end
  end
end
