# frozen_string_literal: true

class IndexTitleComponent < Blacklight::DocumentTitleComponent
    def title
      helpers.link_to_document presenter.document, title_text, counter: @counter, itemprop: 'name', style: title_style, dir: ''
    end
  
    def transliterated_title
      helpers.link_to_document presenter.document, transliterated_title_text, counter: @counter, itemprop: 'name', dir: ''
    end
  
    private
  
      attr_reader :document
  
      def title_text
        document['title_vern_ssm'] || document['title_ssm'][0] || document['id']
      end
  
      def transliterated_title_text
        @transliterated_title_text ||= document['title_ssm'] if document['title_vern_ssm'].present?
      end
  
      def title_style
        return ''
      end
  
      def title_has_been_transliterated?
        document['title_ssm'].present? && document['title_vern_ssm'].present?
      end
  end