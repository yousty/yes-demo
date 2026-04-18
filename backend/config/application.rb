# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick only the frameworks we need — this is an API-only service
require 'active_model/railtie'
require 'active_record/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)

module TaskFlowBackend
  # Rails application for the TaskFlow demo. Wires up the Yes command/read APIs,
  # the PgEventstore admin UI, and CORS for the Next.js frontend.
  class Application < Rails::Application
    config.load_defaults 8.0

    config.api_only = true
    config.autoload_lib(ignore: %w[assets tasks])
    config.active_record.schema_format = :ruby
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
    end
  end
end
