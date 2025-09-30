# frozen_string_literal: true

require 'net/http'
require 'json'
require 'uri'

class NativeLandController < ApplicationController
  class NativeLandError < StandardError
    attr_reader :status

    def initialize(message, status = :bad_request)
      super(message)
      @status = status
    end
  end

  DEFAULT_BASE_URL = 'https://native-land.ca/api/index.php'
  CACHE_TTL = 12.hours
  MAX_REDIRECTS = 5
  DEFAULT_BBOX = '-172,7,-52,83'

  def territories
    render json: retrieve_payload
  rescue NativeLandError => e
    render json: { error: e.message }, status: e.status
  rescue StandardError => e
    Rails.logger.error("Native Land proxy failure: #{e.class}: #{e.message}")
    render json: { error: 'Native Land API request failed' }, status: :bad_gateway
  end

  private

  def retrieve_payload
    api_key = params[:key].presence || Rails.configuration.x.native_land_api_key
    raise NativeLandError.new('Native Land API key missing', :bad_request) unless api_key.present?

    uri = build_uri(api_key)

    body = Rails.cache.fetch(cache_key(uri), expires_in: CACHE_TTL) do
      response = perform_request(uri)
      unless response.is_a?(Net::HTTPSuccess)
        raise NativeLandError.new("Native Land API request failed with status #{response.code}", :bad_gateway)
      end
      response.body
    end

    JSON.parse(body)
  rescue JSON::ParserError => e
    Rails.logger.error("Native Land proxy JSON parse error: #{e.message}")
    raise NativeLandError.new('Native Land API returned invalid JSON', :bad_gateway)
  end

  def build_uri(api_key)
    base = ENV.fetch('NATIVE_LAND_API_URL', DEFAULT_BASE_URL)
    uri = URI.parse(base)
    query = URI.decode_www_form(uri.query.to_s)
    maps = params[:maps].presence || 'territories'
    query.reject! { |(key, _)| %w[maps key poly bbox].include?(key) }
    query << ['maps', maps]
    additional = permitted_passthrough_params
    poly = additional.delete('poly') { '1' }
    bbox = additional.delete('bbox') { DEFAULT_BBOX }
    query << ['poly', poly] if poly.present?
    query << ['bbox', bbox] if bbox.present?
    query << ['key', api_key]
    additional.each { |key, value| query << [key, value] }
    uri.query = URI.encode_www_form(query)
    uri
  end

  def permitted_passthrough_params
    params.permit(:poly, :bbox, :utm, :lang).to_h.transform_keys(&:to_s).compact
  end

  def perform_request(uri)
    current_uri = uri
    redirects = 0

    loop do
      http = Net::HTTP.new(current_uri.host, current_uri.port)
      http.use_ssl = current_uri.scheme == 'https'
      http.open_timeout = 5
      http.read_timeout = 20
      request = Net::HTTP::Get.new(current_uri)
      request['Accept'] = 'application/json'

      response = http.request(request)
      return response unless response.is_a?(Net::HTTPRedirection)

      location = response['location']
      raise NativeLandError.new('Native Land API redirection missing location header', :bad_gateway) unless location.present?

      current_uri = URI.parse(location)
      redirects += 1
      raise NativeLandError.new('Native Land API redirected too many times', :bad_gateway) if redirects > MAX_REDIRECTS
    end
  end

  def cache_key(uri)
    [self.class.name, uri.to_s]
  end
end
