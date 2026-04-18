# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('CORS_ORIGINS', 'http://localhost:3001').split(',').map(&:strip)

    resource '*',
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: ['x-total-count'],
             max_age: 600
  end
end
