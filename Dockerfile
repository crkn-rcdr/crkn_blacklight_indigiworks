FROM ruby:3.4.1

RUN apt-get update; \
    apt-get install -y curl gnupg; \
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -; \
    curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -; \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list; \
    apt-get install -y nodejs yarn; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile .

RUN bundle install

RUN rails generate blacklight:install --marc --skip-solr --bootstrap-version=5

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]