module Admin
  class SchoolClassesController < BaseController
    before_action :build_school_class, only: %i[new create]
    before_action :set_school_class, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]

    def index
      @school_classes = SchoolClass.includes(:formation_plan, responsible_collaborator: [ :person, :collaborator_roles ]).order(:name)
    end

    def show
    end

    def new
    end

    def create
      @school_class.assign_attributes(school_class_params)

      if @school_class.save
        redirect_to admin_school_class_path(@school_class), notice: "School class created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @school_class.update(school_class_params)
        redirect_to admin_school_class_path(@school_class), notice: "School class updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @school_class.destroy!
      redirect_to admin_school_classes_path, notice: "School class deleted."
    rescue ActiveRecord::InvalidForeignKey
      redirect_to admin_school_class_path(@school_class), alert: "Delete the enrollments linked to this school class first."
    end

    private

    def build_school_class
      @school_class = SchoolClass.new(formation_plan_id: params[:formation_plan_id])
    end

    def set_school_class
      @school_class = SchoolClass.includes(:formation_plan, responsible_collaborator: [ :person, :collaborator_roles ]).find(params[:id])
    end

    def load_form_dependencies
      @formation_plans = FormationPlan.order(:name)
      @responsible_collaborators = Collaborator.joins(:person)
                                             .includes(:person, :collaborator_roles)
                                             .order("people.last_name ASC, people.first_name ASC")
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
  end
end
