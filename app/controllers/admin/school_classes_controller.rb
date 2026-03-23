module Admin
  class SchoolClassesController < BaseController
    before_action :build_school_class, only: %i[new create]
    before_action :set_school_class, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]

    def index
      @school_classes, @pagination = paginate_scope(
        SchoolClass.includes(:formation_plan, :students, responsible_collaborator: [ :person, :collaborator_roles ]).order(:name)
      )
    end

    def show
      @students = @school_class.students.joins(:person).includes(:person).order("people.last_name ASC, people.first_name ASC")
    end

    def new
    end

    def create
      @school_class.assign_attributes(school_class_params)

      if save_school_class
        redirect_to admin_school_class_path(@school_class), notice: "School class created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      @school_class.assign_attributes(school_class_params)

      if save_school_class
        redirect_to admin_school_class_path(@school_class), notice: "School class updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @school_class.destroy!
      redirect_to admin_school_classes_path, notice: "School class deleted."
    rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
      redirect_to admin_school_class_path(@school_class), alert: "Delete the enrollments linked to this school class first."
    end

    private

    def build_school_class
      @school_class = SchoolClass.new(formation_plan_id: params[:formation_plan_id])
    end

    def set_school_class
      @school_class = SchoolClass.includes(:formation_plan, :students, responsible_collaborator: [ :person, :collaborator_roles ]).find(params[:id])
    end

    def load_form_dependencies
      @formation_plans = FormationPlan.order(:name)
      @responsible_collaborators = Collaborator.joins(:person)
                                             .includes(:person, :collaborator_roles)
                                             .order("people.last_name ASC, people.first_name ASC")
      @students = Student.joins(:person).includes(:person).order("people.last_name ASC, people.first_name ASC")
      @selected_student_ids = selected_student_ids
    end

    def ensure_prerequisites!
      if @formation_plans.empty?
        redirect_to admin_formation_plans_path, alert: "Create a formation plan before creating a school class."
        return
      end

      return unless @responsible_collaborators.empty?

      redirect_to admin_people_path, alert: "Create a collaborator before creating a school class."
    end

    def school_class_params
      params.fetch(:school_class, {}).permit(:name, :formation_plan_id, :responsible_collaborator_id)
    end

    def enrollment_params
      params.fetch(:school_class, {}).permit(student_ids: [])
    end

    def selected_student_ids
      ids =
        if params[:school_class].present?
          enrollment_params[:student_ids]
        else
          @school_class.student_ids
        end

      Array(ids).reject(&:blank?).map(&:to_i).uniq
    end

    def save_school_class
      valid_class = @school_class.valid?
      valid_students = selected_students_valid?

      return false unless valid_class && valid_students

      SchoolClass.transaction do
        @school_class.save!
        @school_class.student_ids = @selected_student_ids
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def selected_students_valid?
      return true if @selected_student_ids.empty?

      return true if Student.where(id: @selected_student_ids).count == @selected_student_ids.size

      @school_class.errors.add(:base, "One or more selected students are invalid")
      false
    end
  end
end
