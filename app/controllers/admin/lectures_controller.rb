module Admin
  class LecturesController < BaseController
    before_action :build_lecture, only: %i[new create]
    before_action :set_lecture, only: %i[show edit update destroy]
    before_action :load_form_dependencies, only: %i[new create edit update]
    before_action :ensure_prerequisites!, only: %i[new create]

    def index
      @lectures = Lecture.includes(:room, :unit, collaborator: :person).order(:date, :start_time)
    end

    def show
    end

    def new
    end

    def create
      @lecture.assign_attributes(lecture_params)

      if @lecture.save
        redirect_to admin_lecture_path(@lecture), notice: "Lecture created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @lecture.update(lecture_params)
        redirect_to admin_lecture_path(@lecture), notice: "Lecture updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @lecture.destroy!
      redirect_to admin_lectures_path, notice: "Lecture deleted."
    end

    private

    def build_lecture
      @lecture = Lecture.new(
        room_id: params[:room_id],
        unit_id: params[:unit_id],
        collaborator_id: params[:collaborator_id],
        date: params[:date]
      )
    end

    def set_lecture
      @lecture = Lecture.includes(:room, :unit, collaborator: :person).find(params[:id])
    end

    def load_form_dependencies
      @rooms = Room.order(:name)
      @units = Unit.order(:name)
      @collaborators = Collaborator.joins(:person)
                                   .includes(:person, :collaborator_roles)
                                   .order("people.last_name ASC, people.first_name ASC")
    end

    def ensure_prerequisites!
      if @rooms.empty?
        redirect_to admin_rooms_path, alert: "Create a room before creating a lecture."
        return
      end

      if @units.empty?
        redirect_to admin_units_path, alert: "Create a unit before creating a lecture."
        return
      end

      return unless @collaborators.empty?

      redirect_to admin_people_path, alert: "Create a collaborator before creating a lecture."
    end

    def lecture_params
      params.fetch(:lecture, {}).permit(:date, :start_time, :end_time, :room_id, :unit_id, :collaborator_id)
    end
  end
end
