README
A docker compose demo that will allow you to spin up a test instance of blacklight v8.8 (marc) in a flash.

* Ruby version
3.4.1

* System dependencies
Docker, Docker-compose

* Configuration
`docker compose up --build --force-recreate`
`rails generate --asset-delivery-mode=importmap-rails blacklight_range_limit:install`
`rake solr:marc:index MARC_FILE=marc-file-name-here.mrc`
`RAILS_ENV=production rails vite:build`
`curl -X POST -H 'Content-Type: application/json' 'http://localhost:8983/solr/blacklight_marc/update?commit=true' -d '{ "delete": {"query":"*:*"} }'`

sudo mkdir /opt/bitnami/solr/server/solr/blacklight_marc/conf
sudo cp -r /opt/bitnami/solr/server/solr/configsets/_default/conf/* /opt/bitnami/solr/server/solr/blacklight_marc/conf/
cd /opt/bitnami/solr/server/solr
sudo vi security.json
{
  "authorization": {
    "class": "solr.RuleBasedAuthorizationPlugin",
    "permissions": [
      {
        "name": "read",
        "role": ["admin", "public"]  // Grant read access to both admin and public roles
      },
      {
        "name": "security-edit",
        "role": "admin"  // Only admin can edit security settings
      }
    ],
    "user-role": {
      "admin": "admin",  // Map admin user
      "public": "public"  // Map public user
    }
  }
}

$ sudo rm solrconfig.xml
$ sudo vi solrconfig.xml
$ sudo rm managed-schema.xml
$ sudo vi managed-schema.xml

sudo /opt/bitnami/ctlscript.sh restart solr

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions
`docker compose up --build --force-recreate`
`docker tag crkn_canadiana_blacklight-web brilap/crkn`
`docker push brilap/crkn `

# Docs
https://workshop.projectblacklight.org/
https://github.com/projectblacklight/blacklight/wiki/

Configuring-and-Customizing-Blacklight#custom-view-helpers




