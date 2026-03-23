module Admin
  class UnitsController < BaseController
    before_action :set_unit, only: %i[show edit update destroy]

    def index
      @units = accessible_units.includes(:learning_modules, :lectures).order(:name)
    end

    def show
      @learning_modules = @unit.learning_modules.order(:name)
      @lectures = @unit.lectures.includes(:room, collaborator: :person).order(:date, :start_time)
      @grades = visible_grades.includes(student: :person).order(awarded_on: :desc, created_at: :desc)
    end

    def new
      @unit = Unit.new
    end

    def create
      @unit = Unit.new(unit_params)

      if @unit.save
        redirect_to admin_unit_path(@unit), notice: "Unit created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @unit.update(unit_params)
        redirect_to admin_unit_path(@unit), notice: "Unit updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @unit.destroy!
      redirect_to admin_units_path, notice: "Unit deleted."
    rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
      redirect_to admin_unit_path(@unit), alert: "Delete the lectures linked to this unit first."
    end

    private

    def collaborator_access_allowed?
      return false unless current_collaborator.present?
      return true if action_name == "index"

      action_name == "show" && Unit.taught_by(current_collaborator).where(id: params[:id]).exists?
    end

    def accessible_units
      return Unit.all if current_account.admin?

      Unit.taught_by(current_collaborator)
    end

    def set_unit
      @unit = accessible_units
        .includes(:learning_modules, :lectures, grades: { student: :person })
        .find(params[:id])
    end

    def unit_params
      params.fetch(:unit, {}).permit(:name)
    end

    def visible_grades
      return @unit.grades if current_account.admin?

      @unit.grades.where(student_id: @unit.eligible_students.select(:id))
    end
  end
end
