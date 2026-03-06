# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_email = ENV["ADMIN_EMAIL"].presence
admin_password = ENV["ADMIN_PASSWORD"].presence

if !Rails.env.production?
  admin_email ||= "admin@example.com"
  admin_password ||= "ChangeMe123!"
end

if admin_email.blank?
  puts "Skipping admin account seed. Set ADMIN_EMAIL to create it."
else
  admin_person = Person.find_or_initialize_by(
    avs_number: ENV.fetch("ADMIN_AVS_NUMBER", "ADMIN-0001")
  )
  admin_person.assign_attributes(
    first_name: ENV.fetch("ADMIN_FIRST_NAME", "System"),
    last_name: ENV.fetch("ADMIN_LAST_NAME", "Administrator"),
    city: ENV.fetch("ADMIN_CITY", "Lausanne"),
    postal_code: ENV.fetch("ADMIN_POSTAL_CODE", "1000"),
    street: ENV.fetch("ADMIN_STREET", "Admin Street"),
    street_number: ENV.fetch("ADMIN_STREET_NUMBER", "1").to_i,
    phone_number: ENV.fetch("ADMIN_PHONE_NUMBER", "0790000000")
  )

  if admin_person.account.nil? && admin_password.blank?
    puts "Skipping admin account creation. Set ADMIN_PASSWORD for the first admin account."
  else
    admin_person.save!

    admin_account = admin_person.account || admin_person.build_account
    admin_account.assign_attributes(
      email: admin_email,
      admin: true,
      enabled: true
    )

    if admin_account.new_record?
      admin_account.password = admin_password
      admin_account.password_confirmation = admin_password
    end

    admin_account.save!
    puts "Admin account ready for #{admin_email}."
  end
end
