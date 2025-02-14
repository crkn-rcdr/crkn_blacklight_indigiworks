# frozen_string_literal: true

ActiveSupport::Reloader.to_prepare do
    Blacklight::Rendering::Pipeline.operations = [Blacklight::Rendering::HelperMethod,
                                                  Custom::LinkToFacetProcessor,
                                                  Blacklight::Rendering::Join,
                                                  Blacklight::Rendering::Microdata]
  end