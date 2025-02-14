# frozen_string_literal: true

module Custom
  class LinkToFacetProcessor < Blacklight::Rendering::LinkToFacet
    def link(field, v)
      context.link_to(v, search_path(field+"_str", v) + "&q=&search_field=all_fields", class: 'search-name', 'data-original_title' => "Search: #{v}")
    end
  end
end