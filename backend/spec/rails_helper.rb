# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'spec_helper'
require File.expand_path('../config/environment', __dir__)

abort('Rails is running in production!') if Rails.env.production?

require 'rspec/rails'
require 'pg_eventstore/rspec/test_helpers'
require 'yes/core/test_support'
require 'factory_bot_rails'

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.use_transactional_fixtures = true

  config.include FactoryBot::Syntax::Methods
  config.include Yes::Core::TestSupport::EventHelpers

  config.before do
    PgEventstore::TestHelpers.clean_up_db
  end
end
