# frozen_string_literal: true

require_relative '../../app/lib/dev_auth_adapter'

Yes::Core.configure do |config|
  config.auth_adapter = DevAuthAdapter.new
  config.aggregate_shortcuts = true
  # Single-service demo: read models are updated synchronously inside the command handler,
  # so no subscriptions worker is required.
  config.process_commands_inline = true
  config.logger = Rails.logger
end
