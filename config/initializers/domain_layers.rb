# require_dependency Rails.root.join("app/business/types.rb").to_s

# Dir[Rails.root.join("app/business/**/*.rb")].sort.reject { |file| file.end_with?("app/business/types.rb") }.each do |file|
#   require_dependency file
# end

# Dir[Rails.root.join("app/services/**/*.rb")].sort.each do |file|
#   require_dependency file
# end
