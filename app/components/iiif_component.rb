require 'view_component/version'

class IiifComponent < ViewComponent::Base
    def initialize(document:, term:)
        @document = document
        @term = term
    end
end