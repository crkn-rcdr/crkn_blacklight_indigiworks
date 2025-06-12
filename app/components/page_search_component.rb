require 'view_component/version'

class PageSearchComponent < ViewComponent::Base
    def initialize(documentId:, term:, prefix:)
        @documentId = documentId
        @term = term
        @prefix = prefix
        puts term.length
        if @term.length != 0
            rsolr = RSolr.connect :url => 'http://solr:8983/solr/page'
            if term != "*:*"
                @legacy_ocr_search_request= rsolr.get 'select', :params => {
                    :rows => 500,
                    :q => 'page_txt:' + term + ' AND ' + 'pkey:' + @documentId
                } 
                legacy_ocr_search_results_unsorted = []
                for hit in @legacy_ocr_search_request['response']['docs'] do
                    stripped=hit['id'].gsub(@documentId+'.', '')
                    legacy_ocr_search_results_unsorted.append(stripped.to_i)
                end
                @legacy_ocr_search_results = legacy_ocr_search_results_unsorted.sort
            else 
                puts "No"
            end
        end
    end
end