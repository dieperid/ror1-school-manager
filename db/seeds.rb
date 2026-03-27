load Rails.root.join("db/seeds/support.rb")
load Rails.root.join("db/seeds/admin.rb")

if Rails.env.development?
  load Rails.root.join("db/seeds/development.rb")
else
  puts "Development sample data is only seeded in development."
end
