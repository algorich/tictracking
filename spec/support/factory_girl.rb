RSpec.configure do |config|
  # Syntax sugar to use the FactoryGirl methods directly instead FactoryGirl.create
  config.include FactoryGirl::Syntax::Methods
end