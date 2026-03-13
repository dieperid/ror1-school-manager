module Admin
  class FormationPlansController < BaseController
    before_action :set_formation_plan, only: %i[show edit update destroy]

    def index
      @formation_plans = FormationPlan.includes(:school_classes).order(:name)
    end

    def show
      @school_classes = @formation_plan.school_classes.includes(responsible_collaborator: [ :person, :collaborator_roles ]).order(:name)
    end

    def new
      @formation_plan = FormationPlan.new
    end

    def create
      @formation_plan = FormationPlan.new(formation_plan_params)

      if @formation_plan.save
        redirect_to admin_formation_plan_path(@formation_plan), notice: "Formation plan created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @formation_plan.update(formation_plan_params)
        redirect_to admin_formation_plan_path(@formation_plan), notice: "Formation plan updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @formation_plan.destroy!
      redirect_to admin_formation_plans_path, notice: "Formation plan deleted."
    rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
      redirect_to admin_formation_plan_path(@formation_plan), alert: "Delete the school classes linked to this formation plan first."
    end

    private

    def set_formation_plan
      @formation_plan = FormationPlan.find(params[:id])
    end

    def formation_plan_params
      params.fetch(:formation_plan, {}).permit(:name)
    end
  end
end
