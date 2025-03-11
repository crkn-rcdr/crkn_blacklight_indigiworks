# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
`docker compose up --build --force-recreate`
`rails generate --asset-delivery-mode=importmap-rails blacklight_range_limit:install`
`rake solr:marc:index MARC_FILE=1.mrc && rake solr:marc:index MARC_FILE=2.mrc && rake solr:marc:index MARC_FILE=3.mrc && rake solr:marc:index MARC_FILE=4.mrc && rake solr:marc:index MARC_FILE=5.mrc && rake solr:marc:index MARC_FILE=6.mrc && rake solr:marc:index MARC_FILE=7.mrc && rake solr:marc:index MARC_FILE=8.mrc && rake solr:marc:index MARC_FILE=9.mrc && rake solr:marc:index MARC_FILE=10.mrc && rake solr:marc:index MARC_FILE=11.mrc && rake solr:marc:index MARC_FILE=12.mrc && rake solr:marc:index MARC_FILE=13.mrc && rake solr:marc:index MARC_FILE=14.mrc && rake solr:marc:index MARC_FILE=issues_1.mrc && rake solr:marc:index MARC_FILE=issues_2.mrc && rake solr:marc:index MARC_FILE=issues_3.mrc && rake solr:marc:index MARC_FILE=issues_4.mrc && rake solr:marc:index MARC_FILE=issues_5.mrc`

`RAILS_ENV=production rails vite:build`
`curl -X POST -H 'Content-Type: application/json' 'http://localhost:8983/solr/blacklight_marc/update?commit=true' -d '{ "delete": {"query":"*:*"} }'`
# Docs
https://workshop.projectblacklight.org/

https://github.com/projectblacklight/blacklight/wiki

https://github.com/projectblacklight/blacklight/wiki/

Configuring-and-Customizing-Blacklight#custom-view-helpers
