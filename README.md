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
rails generate --asset-delivery-mode=importmap-rails blacklight_range_limit:install 
rake solr:marc:index MARC_FILE=test.mrc
RAILS_ENV=production rails vite:build
* ...

    "dev": "vite",
    "build": "vite build", 
    "preview": "vite preview" 


# Docs

https://workshop.projectblacklight.org/
https://github.com/projectblacklight/blacklight/wiki
https://github.com/projectblacklight/blacklight/wiki/Configuring-and-Customizing-Blacklight#custom-view-helpers