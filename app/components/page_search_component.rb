require 'view_component/version'
require 'net/http'
require 'uri'
require 'json'
require 'cgi'

class PageSearchComponent < ViewComponent::Base
  def initialize(docId:, arkUrl:, term:)
    @documentId = docId
    @arkUrl = arkUrl
    @term = (term || '').to_s

    @legacy_ocr_search_results = []

    return if @term.strip.empty? || @term == '*:*' || @arkUrl.blank?

    ark = @arkUrl.gsub('https://n2t.net/ark:/', '')
    query = CGI.escape(@term)
    base_search = Rails.configuration.x.iiif_content_search_base
    content_search_endpoint = "#{base_search}/#{ark}?q=#{query}"

    begin
      annotations = fetch_content_search_items(content_search_endpoint)
      canvas_to_index = fetch_manifest_canvas_index_map(ark)

      indices = annotations.map do |ann|
        target = ann['target'] || ann['on'] # v2 sometimes uses 'on'
        next unless target
        canvas_url = target.split('#').first
        # try exact match first
        index = canvas_to_index[canvas_url]
        # fallback: match by trailing canvas id segment
        if index.nil?
          trailing = canvas_url.to_s.split('/').last
          index = canvas_to_index.find { |k, _| k.to_s.end_with?("/#{trailing}") }&.last
        end
        index
      end.compact.uniq.sort

      @legacy_ocr_search_results = indices
    rescue => e
      Rails.logger.warn("PageSearchComponent: content search failed: #{e.class}: #{e.message}") if defined?(Rails)
      @legacy_ocr_search_results = []
    end
  end

  private

  def http_get_json(uri_str)
    uri = URI.parse(uri_str)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', open_timeout: 3, read_timeout: 5) do |http|
      res = http.get(uri.request_uri, { 'Accept' => 'application/json' })
      raise "HTTP #{res.code}" unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end
  end

  def fetch_content_search_items(endpoint)
    json = http_get_json(endpoint)
    items = json['items'] || []
    # In case of IIIF Search v1 (resources)
    items = json['resources'] if items.empty? && json['resources'].is_a?(Array)
    items
  end

  def fetch_manifest_canvas_index_map(ark)
    manifest_url = "#{Rails.configuration.x.iiif_manifest_base}/#{ark}"
    json = http_get_json(manifest_url)
    canvases = if json['items'].is_a?(Array)
                 json['items'] # IIIF v3
               elsif json.dig('sequences', 0, 'canvases').is_a?(Array)
                 json['sequences'][0]['canvases'] # IIIF v2
               else
                 []
               end
    map = {}
    canvases.each_with_index do |c, idx|
      id = c['id'] || c['@id']
      next unless id
      map[id] = idx + 1 # 1-based page index for UI
    end
    map
  end
end
