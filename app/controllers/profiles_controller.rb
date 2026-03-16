class ProfilesController < ApplicationController
  before_action :authenticate_account!
  before_action :set_profile

  def show
  end

  def edit
  end

  def update
    @person.assign_attributes(person_params)

    if @person.valid? && persist_profile_changes
      bypass_sign_in(@account)
      redirect_to profile_path, notice: "Your profile was updated."
    else
      merge_account_errors
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @account = current_account
    @person = current_person
    @student_grades = @person.student&.grades&.includes(:unit)&.order(awarded_on: :desc, created_at: :desc) || []
  end

  def person_params
    params.fetch(:person, {}).permit(
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
    params.fetch(:account, {}).permit(:current_password, :email, :password, :password_confirmation)
  end

  def persist_profile_changes
    success = false

    Person.transaction do
      @person.save!
      success = persist_account_changes
      raise ActiveRecord::Rollback unless success
    end

    success
  rescue ActiveRecord::RecordInvalid
    false
  end

  def persist_account_changes
    return true unless account_change_requested?

    if sensitive_account_change?
      @account.update_with_password(sensitive_account_attributes)
    else
      @account.update(email: normalized_email)
    end
  end

  def account_change_requested?
    account_params.key?(:email) || password_change_requested?
  end

  def sensitive_account_change?
    password_change_requested? || normalized_email != @account.email
  end

  def password_change_requested?
    account_params[:password].present? || account_params[:password_confirmation].present?
  end

  def normalized_email
    account_params.fetch(:email, @account.email).to_s.strip.downcase
  end

  def sensitive_account_attributes
    {
      current_password: account_params[:current_password],
      email: normalized_email,
      password: account_params[:password],
      password_confirmation: account_params[:password_confirmation]
    }
  end

  def merge_account_errors
    @account.errors.full_messages.each do |message|
      @person.errors.add(:base, message) unless @person.errors.full_messages.include?(message)
    end
  end
end
