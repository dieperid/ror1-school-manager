module Admin
  class UnitsController < BaseController
    before_action :set_unit, only: %i[show edit update destroy]

    def index
      @units = Unit.includes(:learning_modules).order(:name)
    end

    def show
      @learning_modules = @unit.learning_modules.order(:name)
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
    end

    private

    def set_unit
      @unit = Unit.includes(:learning_modules).find(params[:id])
    end

    def unit_params
      params.fetch(:unit, {}).permit(:name)
    end
  end
end
