ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.

env_file = File.expand_path("../.env", __dir__)
if File.exist?(env_file)
  # Load simple KEY=value pairs from .env without overriding real shell env vars.
  File.foreach(env_file) do |line|
    next if line.strip.empty? || line.lstrip.start_with?("#")

    key, value = line.split("=", 2)
    next if key.nil? || value.nil?

    key = key.strip
    value = value.strip
    value = value[1...-1] if value.start_with?('"') && value.end_with?('"')
    value = value[1...-1] if value.start_with?("'") && value.end_with?("'")

    ENV[key] ||= value
  end
end

require "bootsnap/setup" # Speed up boot time by caching expensive operations.
