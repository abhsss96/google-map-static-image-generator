require "httparty"
require_relative "google_map_static_image/version"

class GoogleMapStaticImage
  STATIC_MAP_URL = "https://maps.googleapis.com/maps/api/staticmap"
  VALID_MAP_TYPES = %w[roadmap satellite terrain hybrid].freeze

  class ApiError < StandardError
    attr_reader :status, :body
    def initialize(status, body)
      @status = status
      @body   = body
      super("Google Maps Static API error #{status}: #{body}")
    end
  end

  def get_response(api_key, markers, option = {})
    query = {}
    query[:key]     = api_key
    query[:size]    = "1024x1024"
    query[:scale]   = 2
    query[:center]  = option[:center]                                          unless option[:center].nil?
    query[:zoom]    = option[:zoom]                                            unless option[:zoom].nil?
    query[:maptype] = option[:map_type] if VALID_MAP_TYPES.include?(option[:map_type].to_s)
    query[:style]   = option[:style].map { |k, v| "#{k}:#{v}" }.join("|")    unless option[:style].nil?
    query[:path]    = option[:path].map { |k, v| "#{k}:#{v}" }.join("|")     unless option[:path].nil?
    unless option[:location].nil?
      query[:path] = [query[:path], option[:location].map { |_k, v| v.to_s }.join("|")].join("|")
    end
    query[:markers] = option[:markers].map { |val| val.join("|") }            unless option[:markers].nil?

    response = HTTParty.get(STATIC_MAP_URL, query: query)
    raise ApiError.new(response.code, response.body) unless response.code == 200
    response.parsed_response
  end
end
