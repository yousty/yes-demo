# frozen_string_literal: true

require 'pg_eventstore'

PgEventstore.configure do |config|
  config.pg_uri = ENV.fetch(
    'PG_EVENTSTORE_URI',
    'postgresql://postgres:postgres@localhost:5432/taskflow_eventstore'
  )
  config.connection_pool_size = ENV.fetch('PG_EVENTSTORE_POOL_SIZE', 10).to_i
end
