# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
    Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                                  Custom::LinkToFacetProcessor,
                                                  Custom::LinkToSearchValueProcessor,
                                                  Blacklight::Rendering::Join,
                                                  Blacklight::Rendering::Microdata]
  end