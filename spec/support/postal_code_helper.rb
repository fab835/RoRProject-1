module PostalCodeHelper
  def fake_postal_code
    Faker::Address.postcode
  end
end

RSpec.configure do |config|
  config.include PostalCodeHelper
end
