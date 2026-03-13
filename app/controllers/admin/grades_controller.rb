module Admin
  class GradesController < BaseController
    before_action :set_unit
    before_action :build_grade, only: %i[new create]
    before_action :set_grade, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]

    def show
    end

    def new
    end

    def create
      @grade.assign_attributes(grade_params)

      if @grade.save
        redirect_to admin_unit_path(@unit), notice: "Grade created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @grade.update(grade_params)
        redirect_to admin_unit_path(@unit), notice: "Grade updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @grade.destroy!
      redirect_to admin_unit_path(@unit), notice: "Grade deleted."
    end

    private

    def collaborator_access_allowed?
      return false unless current_collaborator.present?

      Unit.taught_by(current_collaborator).where(id: params[:unit_id]).exists?
    end

    def set_unit
      @unit = if current_account.admin?
        Unit.find(params[:unit_id])
      else
        Unit.taught_by(current_collaborator).find(params[:unit_id])
      end
    end

    def build_grade
      @grade = @unit.grades.build(student_id: params[:student_id], awarded_on: params[:awarded_on])
    end

    def set_grade
      @grade = @unit.grades.includes(:unit, student: :person).find(params[:id])
    end

    def load_form_dependencies
      @students = Student.joins(:person).includes(:person).order("people.last_name ASC, people.first_name ASC")
    end

    def ensure_prerequisites!
      if @students.empty?
        redirect_to admin_unit_path(@unit), alert: "Create a student before creating a grade."
        return
      end
    end

    def grade_params
      params.fetch(:grade, {}).permit(:value, :awarded_on, :student_id)
    end
  end
end
