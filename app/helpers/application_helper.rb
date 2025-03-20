# See: https://github.com/pulibrary/orangelight/blob/main/app/helpers/application_helper.rb
module ApplicationHelper
  def render_icon(var)
    "<span class='icon icon-#{var.parameterize}' aria-hidden='true'></span>"
  end
  def format_render(var)
    "<span class='format-text'>#{var.parameterize}</span>"
  end
  def format_icon(args)
    format_str = args[:document][args[:field]].join(', ').to_s
    if format_str.include?('Serial')
      if args[:document][:id].include?('N')
        format_str = 'newspaper-issue'
      else
        format_str = 'journal-issue'
      end
    end
    icon = render_icon(format_str)
    formats = format_render(format_str)
    content_tag :ul do
      content_tag :li, " #{icon} #{formats} ".html_safe, class: 'blacklight-format', dir: 'ltr'
    end
  end
  def value_link(args)
    value_str = args[:document][args[:field]].join(', ').to_s
    content_tag :a, "#{value_str}".html_safe, href: value_str, dir: 'ltr'
  end
end
