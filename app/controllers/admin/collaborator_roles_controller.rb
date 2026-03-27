module Admin
  class CollaboratorRolesController < BaseController
    def index
      @collaborator_roles, @pagination = paginate_scope(CollaboratorRole.includes(:collaborators).order(:title))
    end

    def new
      @collaborator_role = CollaboratorRole.new
    end

    def create
      @collaborator_role = CollaboratorRole.new(collaborator_role_params)

      if @collaborator_role.save
        redirect_to admin_collaborator_roles_path, notice: "Collaborator role created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def collaborator_role_params
      params.fetch(:collaborator_role, {}).permit(:title)
    end
  end
end
