class ApplicationController < ActionController::Base
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  layout :determine_layout if respond_to? :layout

  around_action :switch_locale

  private

  def switch_locale(&action)
    locale = extract_locale_from_tld || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def extract_locale_from_tld
    tld = request.host.split('.').last
    case tld
    when 'fr'
      'fr'
    when 'ca'
      'en'
    else
      nil
    end
  end
end
