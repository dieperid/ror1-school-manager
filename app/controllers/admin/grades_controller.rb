module Admin
  class GradesController < BaseController
    before_action :build_grade, only: %i[new create]
    before_action :set_grade, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]

    def index
      @grades = Grade.includes(:unit, student: :person).order(awarded_on: :desc, created_at: :desc)
    end

    def show
    end

    def new
    end

    def create
      @grade.assign_attributes(grade_params)

      if @grade.save
        redirect_to admin_grade_path(@grade), notice: "Grade created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @grade.update(grade_params)
        redirect_to admin_grade_path(@grade), notice: "Grade updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @grade.destroy!
      redirect_to admin_grades_path, notice: "Grade deleted."
    end

    private

    def build_grade
      @grade = Grade.new(student_id: params[:student_id], unit_id: params[:unit_id], awarded_on: params[:awarded_on])
    end

    def set_grade
      @grade = Grade.includes(:unit, student: :person).find(params[:id])
    end

    def load_form_dependencies
      @students = Student.joins(:person).includes(:person).order("people.last_name ASC, people.first_name ASC")
      @units = Unit.order(:name)
    end

    def ensure_prerequisites!
      if @students.empty?
        redirect_to admin_people_path, alert: "Create a student before creating a grade."
        return
      end

      return unless @units.empty?

      redirect_to admin_units_path, alert: "Create a unit before creating a grade."
    end

    def grade_params
      params.fetch(:grade, {}).permit(:value, :awarded_on, :student_id, :unit_id)
    end
  end
end
