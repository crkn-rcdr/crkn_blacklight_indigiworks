require 'view_component/version'

class CollectionItemsComponent < ViewComponent::Base

    def initialize(documentId:)
        @documentId = documentId
        
        rsolr = RSolr.connect :url => 'http://public:hdwi389e8d!ds@4.204.49.142/solr/blacklight_marc'

        @response_data = rsolr.get 'select', :params => {
            :rows => 500,
            :q => 'serial_key:' + @documentId
        } 
        @collection_items = @response_data['response']['docs']

    end
end