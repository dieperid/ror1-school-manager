module Admin
  class RoomsController < BaseController
    before_action :set_room, only: %i[show edit update destroy]

    def index
      @rooms = Room.includes(:lectures).order(:name)
    end

    def show
      @lectures = @room.lectures.includes(:unit, collaborator: :person).order(:date, :start_time)
    end

    def new
      @room = Room.new
    end

    def create
      @room = Room.new(room_params)

      if @room.save
        redirect_to admin_room_path(@room), notice: "Room created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @room.update(room_params)
        redirect_to admin_room_path(@room), notice: "Room updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @room.destroy!
      redirect_to admin_rooms_path, notice: "Room deleted."
    rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::InvalidForeignKey
      redirect_to admin_room_path(@room), alert: "Delete the lectures linked to this room first."
    end

    private

    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.fetch(:room, {}).permit(:name)
    end
  end
end
