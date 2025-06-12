require 'view_component/version'

class CollectionItemsComponent < ViewComponent::Base

    def initialize(documentId:)
        @documentId = documentId
        #https://dolphin-app-p9llh.ondigitalocean.app/solr//select?indent=true&q.op=OR&q=%3Aoocihm.8_01278&useParams=

        rsolr = RSolr.connect :url => 'http://solr:8983/solr/blacklight_marc'

        @response_data = rsolr.get 'select', :params => {
            :rows => 500,
            :q => 'serial_key:' + @documentId
        } 
        @collection_items = @response_data['response']['docs']

    end
end