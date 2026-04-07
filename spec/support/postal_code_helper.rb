module PostalCodeHelper
  def fake_postal_code
    "#{Faker::Alphanumeric.alphanumeric(number: 3).upcase} #{Faker::Alphanumeric.alphanumeric(number: 3).upcase}"
  end
end

RSpec.configure do |config|
  config.include PostalCodeHelper
end
