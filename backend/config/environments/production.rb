# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.headers = { 'cache-control' => "public, max-age=#{1.year.to_i}" }

  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::Logger.new($stdout)
                                       .tap { |logger| logger.formatter = Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.action_dispatch.show_exceptions = :rescuable

  config.hosts.clear
end
