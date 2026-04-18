FROM public.ecr.aws/docker/library/ruby:3.4

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    LANG=C.UTF-8 \
    RAILS_ENV=development

RUN apt-get update -qq \
 && apt-get install -y --no-install-recommends \
      build-essential \
      git \
      libpq-dev \
      postgresql-client \
      tzdata \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install gems first for better Docker cache hits.
COPY Gemfile Gemfile.lock* ./
RUN gem install bundler -v '~> 2.5' \
 && bundle install

COPY . .

RUN chmod +x bin/docker-entrypoint bin/rails bin/rake

EXPOSE 3000

ENTRYPOINT ["bin/docker-entrypoint"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
