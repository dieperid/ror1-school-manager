module Admin
  class PeopleController < BaseController
    before_action :build_person, only: %i[new create]

    def index
      @people = Person.includes(:account).order(:last_name, :first_name)
    end

    def new
    end

    def create
      @person.assign_attributes(person_params)

      if valid_submission?
        save_person_and_account!
        redirect_to admin_people_path, notice: success_message
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def build_person
      @person = Person.new
      @account_email = account_params[:email].to_s.strip.downcase
      @account_admin = ActiveModel::Type::Boolean.new.cast(account_params[:admin])
    end

    def person_params
      params.fetch(:person, {}).permit(
        :avs_number,
        :birth_date,
        :city,
        :first_name,
        :last_name,
        :phone_number,
        :postal_code,
        :street,
        :street_number
      )
    end

    def account_params
      params.fetch(:account, {}).permit(:email, :admin)
    end

    def account_requested?
      @account_email.present?
    end

    def valid_submission?
      person_valid = @person.valid?
      account_valid = account_requested? ? invitation_account.valid? : true
      merge_account_errors unless account_valid
      person_valid && account_valid
    end

    def invitation_account
      temporary_password = @temporary_password ||= Account.generate_temporary_password

      @invitation_account ||= Account.new(
        person: @person,
        email: @account_email,
        admin: @account_admin,
        enabled: true,
        password: temporary_password,
        password_confirmation: temporary_password
      )
    end

    def merge_account_errors
      invitation_account.errors.full_messages.each do |message|
        @person.errors.add(:base, message)
      end
    end

    def save_person_and_account!
      Person.transaction do
        @person.save!

        if account_requested?
          invitation_account.person = @person
          invitation_account.save!
          invitation_account.deliver_invitation!
        end
      end
    end

    def success_message
      message = "#{@person.full_name} was created."
      return message unless account_requested?

      "#{message} An invitation was sent to #{@account_email}."
    end
  end
end
