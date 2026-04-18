# frozen_string_literal: true

require 'pg_eventstore/web'

Rails.application.routes.draw do
  mount Yes::Command::Api::Engine => '/v1/commands'
  mount Yes::Read::Api::Engine    => '/v1/queries'

  mount PgEventstore::Web::Application => '/admin/eventstore'

  get '/health', to: ->(_env) { [200, { 'content-type' => 'text/plain' }, ['ok']] }
end
