# See: https://github.com/pulibrary/orangelight/blob/main/app/helpers/application_helper.rb
module ApplicationHelper
  def render_icon(var)
    "<span class='icon icon-#{var.parameterize}' aria-hidden='true'></span>".html_safe
  end
  def format_render(args)
    "<span class='format-text'>#{args[:document][args[:field]].join(', ')}</span>"
  end
  def format_icon(args)
    icon = render_icon(args[:document][args[:field]][0]).to_s
    formats = format_render(args)
    content_tag :ul do
      content_tag :li, " #{icon} #{formats} ".html_safe, class: 'blacklight-format', dir: 'ltr'
    end
  end
end
