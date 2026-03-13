module Admin
  class LearningModulesController < BaseController
    before_action :set_learning_module, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]

    def index
      @learning_modules = LearningModule.includes(:formation_plans, :units).order(:name)
    end

    def show
    end

    def new
      @learning_module = LearningModule.new
      @selected_formation_plan_ids = selected_formation_plan_ids
      @selected_unit_ids = selected_unit_ids
    end

    def create
      @learning_module = LearningModule.new(learning_module_params)
      @selected_formation_plan_ids = selected_formation_plan_ids
      @selected_unit_ids = selected_unit_ids

      if save_learning_module
        redirect_to admin_learning_module_path(@learning_module), notice: "Learning module created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @selected_formation_plan_ids = @learning_module.formation_plan_ids
      @selected_unit_ids = @learning_module.unit_ids
    end

    def update
      @learning_module.assign_attributes(learning_module_params)
      @selected_formation_plan_ids = selected_formation_plan_ids
      @selected_unit_ids = selected_unit_ids

      if save_learning_module
        redirect_to admin_learning_module_path(@learning_module), notice: "Learning module updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @learning_module.destroy!
      redirect_to admin_learning_modules_path, notice: "Learning module deleted."
    end

    private

    def set_learning_module
      @learning_module = LearningModule.includes(:formation_plans, :units).find(params[:id])
    end

    def load_form_dependencies
      @formation_plans = FormationPlan.order(:name)
      @units = Unit.order(:name)
    end

    def learning_module_params
      params.fetch(:learning_module, {}).permit(:name)
    end

    def association_params
      params.fetch(:learning_module, {}).permit(formation_plan_ids: [], unit_ids: [])
    end

    def selected_formation_plan_ids
      ids = association_params[:formation_plan_ids]
      ids = [ params[:formation_plan_id] ] if ids.blank? && params[:formation_plan_id].present?

      Array(ids).reject(&:blank?).map(&:to_i).uniq
    end

    def selected_unit_ids
      ids = association_params[:unit_ids]
      ids = [ params[:unit_id] ] if ids.blank? && params[:unit_id].present?

      Array(ids).reject(&:blank?).map(&:to_i).uniq
    end

    def save_learning_module
      valid_module = @learning_module.valid?
      valid_associations = associations_valid?

      return false unless valid_module && valid_associations

      LearningModule.transaction do
        @learning_module.save!
        @learning_module.formation_plan_ids = selected_formation_plan_ids
        @learning_module.unit_ids = selected_unit_ids
      end

      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def associations_valid?
      valid = true

      if FormationPlan.where(id: selected_formation_plan_ids).count != selected_formation_plan_ids.size
        @learning_module.errors.add(:base, "One or more formation plans are invalid")
        valid = false
      end

      if Unit.where(id: selected_unit_ids).count != selected_unit_ids.size
        @learning_module.errors.add(:base, "One or more units are invalid")
        valid = false
      end

      valid
    end
  end
end
