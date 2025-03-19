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

# Developing Locally
Ensure docker and docker compose are installed. Then, enter the directory in your terminal, and run:

`docker compose up --build --force-recreate`

# Deployment Instructions
Run the following to push the image to docker hub:

`docker tag crkn_canadiana_blacklight-web brilap/crkn`

`docker push brilap/crkn `

Then restart the web app on [Azure](https://portal.azure.com/#@crkn.ca/resource/subscriptions/1bf1b056-be1d-4b1c-991f-2f154caf3061/resourceGroups/CRKN-demo-test/providers/Microsoft.Web/sites/canadiana-beta/appServices) to pull the new docker image.

# Docs
See Blacklight Wiki and Tutorials:
- https://github.com/projectblacklight/blacklight/wiki/
- https://workshop.projectblacklight.org/

To index a marc record from the terminal, you can enter the container on Docker Desktop (or through the docker exec command in your terminal) and run: 

`rake solr:marc:index MARC_FILE=marc-file-name-here.mrc`

A quick command to clear the solr index is:

`curl -X POST -H 'Content-Type: application/json' 'http://username:password@host/solr/blacklight_marc/update?commit=true' -d '{ "delete": {"query":"*:*"} }'`

I ran these commands and saved the app directory as a mapped volume, so you shouldn't have to:

`rails generate --asset-delivery-mode=importmap-rails blacklight_range_limit:install`

`RAILS_ENV=production rails vite:build`





