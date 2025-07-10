# See: https://github.com/pulibrary/orangelight/blob/main/app/helpers/application_helper.rb
require 'cgi'  # For URL escaping

module ApplicationHelper
  def render_icon(var)
    "<span title='#{var.parameterize}' class='icon icon-#{var.parameterize}' aria-hidden='true'></span>"
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
    value_str = Array(args[:document][args[:field]]).join(', ')
    content_tag :a, "#{value_str}".html_safe, href: value_str, dir: 'ltr'
  end
  def format_text(args)
    args[:document][args[:field]].map! do |item|
      item.gsub(/https?:\/\/\S+/) do |url|
        "<a href=\"#{url}\" target=\"_blank\">#{url}</a>"
      end
    end
    value_str = Array(args[:document][args[:field]]).join('<br/>')
    value_str.sub!(/<br\/>$/, '')
    content_tag :p, "#{value_str}".html_safe, dir: 'ltr'
  end
  def format_facet(args)
    field = args[:field].to_s
    args[:document][args[:field]].map! do |value|
      escaped_value = CGI.escape(value.to_s)
      "<a href=\"/?f%5B#{field}_str%5D%5B%5D=#{escaped_value}&q=&search_field=all_fields\">#{value}</a>"
    end
    value_str = Array(args[:document][args[:field]]).join('<br/>')
    value_str.sub!(/<br\/>$/, '')
    content_tag :p, "#{value_str}".html_safe, dir: 'ltr'
  end
  def format_date(args)
    Time.parse(args[:document][args[:field]].to_s).strftime("%Y-%m-%d")
  rescue
    args[:document][args[:field]].to_s # Fallback to original if parsing fails
  end
end
