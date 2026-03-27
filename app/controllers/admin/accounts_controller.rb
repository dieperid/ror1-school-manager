module Admin
  class AccountsController < BaseController
    before_action :set_person
    before_action :set_account, only: %i[show edit update destroy invitation]

    def show
    end

    def new
      if @person.account.present?
        redirect_to admin_person_account_path(@person), alert: "This person already has an account."
        return
      end

      @account = @person.build_account(enabled: true)
    end

    def create
      if @person.account.present?
        redirect_to admin_person_account_path(@person), alert: "This person already has an account."
        return
      end

      temporary_password = Account.generate_temporary_password
      @account = @person.build_account(
        account_create_params.merge(
          password: temporary_password,
          password_confirmation: temporary_password
        )
      )

      if @account.save
        redirect_to admin_person_account_invitation_path(@person, format: :txt)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if self_lockout_attempt?
        redirect_to admin_person_account_path(@person), alert: "You cannot disable or remove admin access from your own account while signed in."
        return
      end

      if dean_admin_restriction_attempt?
        redirect_to admin_person_account_path(@person), alert: "Dean access cannot disable or remove admin access from an admin account."
        return
      end

      if @account.update(account_update_attributes)
        redirect_to admin_person_account_path(@person), notice: "Account updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @account == current_account
        redirect_to admin_person_account_path(@person), alert: "You cannot delete your own account while signed in."
        return
      end

      if current_dean? && @account.admin?
        redirect_to admin_person_account_path(@person), alert: "Dean access cannot delete an admin account."
        return
      end

      @account.destroy!
      redirect_to admin_person_path(@person), notice: "Account deleted."
    end

    def invitation
      token = @account.generate_password_setup_token!

      send_data(
        invitation_contents(token),
        filename: invitation_filename,
        type: "text/plain; charset=utf-8",
        disposition: "attachment"
      )
    end

    private

    def set_person
      @person = Person.find(params[:person_id])
    end

    def set_account
      @account = @person.account
      return if @account.present?

      redirect_to admin_person_path(@person), alert: "This person does not have a linked account."
    end

    def account_create_params
      params.fetch(:account, {}).permit(:email, :admin, :enabled)
    end

    def account_update_params
      params.fetch(:account, {}).permit(:email, :admin, :enabled, :password, :password_confirmation)
    end

    def account_update_attributes
      attributes = account_update_params.to_h

      if attributes["password"].blank? && attributes["password_confirmation"].blank?
        attributes.except!("password", "password_confirmation")
      end

      attributes
    end

    def self_lockout_attempt?
      return false unless @account == current_account

      boolean = ActiveModel::Type::Boolean.new
      enabled = boolean.cast(account_update_params.fetch(:enabled, @account.enabled))
      admin = boolean.cast(account_update_params.fetch(:admin, @account.admin))

      !enabled || !admin
    end

    def dean_admin_restriction_attempt?
      return false unless current_dean? && @account.admin?

      boolean = ActiveModel::Type::Boolean.new
      enabled = boolean.cast(account_update_params.fetch(:enabled, @account.enabled))
      admin = boolean.cast(account_update_params.fetch(:admin, @account.admin))

      !enabled || !admin
    end

    def invitation_contents(token)
      <<~TEXT
        Ror1 School Manager account invitation

        Name: #{@person.full_name}
        Username: #{@account.email}

        Set password link:
        #{edit_account_password_url(reset_password_token: token)}
      TEXT
    end

    def invitation_filename
      "#{@person.full_name.parameterize.presence || "person"}-invitation.txt"
    end
  end
end
