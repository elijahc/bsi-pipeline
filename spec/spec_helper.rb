require 'coveralls'
Coveralls.wear!

require 'pry'
require 'rbc'
require 'bsi-pipeline'
require 'bsi-pipeline/importer'
require 'bsi-pipeline/models'
require 'bsi-pipeline/version'
require 'factory_girl'
include Pipeline::BSI::Importer
include Pipeline::BSI::Models

RSpec.configure do |config|
  config.expect_with :rspec

  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.lint
  end

  FactoryGirl.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
  FactoryGirl.find_definitions
end
