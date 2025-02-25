FROM ruby:3.4.1

RUN apt-get update; \
    apt-get install -y curl gnupg; \
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -; \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y nodejs npm
RUN npm install -g yarn@2.4.3

WORKDIR /app

COPY Gemfile .

RUN bundle install

#RUN rails generate blacklight:install --marc --skip-solr --bootstrap-version=5

COPY . .

RUN yarn install

#RUN bundle binstub vite_ruby
RUN RAILS_ENV=production rails vite:build

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]