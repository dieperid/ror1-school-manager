admin_email = ENV["ADMIN_EMAIL"].presence
admin_password = ENV["ADMIN_PASSWORD"].presence

if !Rails.env.production?
  admin_email ||= "admin@example.com"
  admin_password ||= Seeds::DEV_PASSWORD
end

if admin_email.blank?
  puts "Skipping admin account seed. Set ADMIN_EMAIL to create it."
else
  admin_person = Seeds.upsert_person(
    avs_number: ENV.fetch("ADMIN_AVS_NUMBER", "ADMIN-0001"),
    first_name: ENV.fetch("ADMIN_FIRST_NAME", "System"),
    last_name: ENV.fetch("ADMIN_LAST_NAME", "Administrator"),
    city: ENV.fetch("ADMIN_CITY", "Lausanne"),
    postal_code: ENV.fetch("ADMIN_POSTAL_CODE", "1000"),
    street: ENV.fetch("ADMIN_STREET", "Admin Street"),
    street_number: ENV.fetch("ADMIN_STREET_NUMBER", "1").to_i,
    phone_number: ENV.fetch("ADMIN_PHONE_NUMBER", "0790000000"),
    birth_date: ENV.fetch("ADMIN_BIRTH_DATE", "1990-01-01")
  )

  if admin_password.blank?
    puts "Skipping admin account creation. Set ADMIN_PASSWORD for the first admin account."
  else
    Seeds.upsert_account(
      person: admin_person,
      email: admin_email,
      admin: true,
      enabled: true,
      password: admin_password,
      reset_password: !Rails.env.production?
    )
    puts "Admin account ready for #{admin_email}."
  end
end
