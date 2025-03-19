# README
A docker compose demo that will allow you to spin up a test instance of blacklight v8.8 (marc) in a flash.

# Ruby version
3.4.1

# System dependencies
Docker, Docker-compose

# Services 
(job queues, cache servers, search engines, etc.)
  
# Configuration

`sudo mkdir /opt/bitnami/solr/server/solr/blacklight_marc/conf`

`sudo cp -r /opt/bitnami/solr/server/solr/configsets/_default/conf/* /opt/bitnami/solr/server/solr/blacklight_marc/conf/`

`cd /opt/bitnami/solr/server/solr/blacklight_marc/conf/`

`sudo rm solrconfig.xml`

`sudo vi solrconfig.xml`

`sudo rm managed-schema.xml`

`sudo vi managed-schema.xml`

`cd /opt/bitnami/solr/server/solr`

`sudo vi security.json`
```
{
  "authorization": {
    "class":"solr.RuleBasedAuthorizationPlugin",
    "permissions":[
      {
        "name":"read",
        "role":[
          "admin",
          "public"
        ],
      },
      {
        "name":"all",
        "role":"admin",
      }
    ],
    "user-role":{
      "admin":"admin",
      "public":"public",
      "manager":"admin"
    }
  }
}
```

`sudo /opt/bitnami/ctlscript.sh restart solr`

# Developing locally
`docker compose up --build --force-recreate`

# Deployment instructions
`docker tag crkn_canadiana_blacklight-web brilap/crkn`

`docker push brilap/crkn `

Restart the web app on azure

# Docs
See Blacklight Wiki and Tutorials:
- https://github.com/projectblacklight/blacklight/wiki/
- https://workshop.projectblacklight.org/

`rake solr:marc:index MARC_FILE=marc-file-name-here.mrc`

`rails generate --asset-delivery-mode=importmap-rails blacklight_range_limit:install`

`RAILS_ENV=production rails vite:build`

`curl -X POST -H 'Content-Type: application/json' 'http://localhost:8983/solr/blacklight_marc/update?commit=true' -d '{ "delete": {"query":"*:*"} }'`




