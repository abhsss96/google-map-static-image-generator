require "httparty"
require_relative "google_map_static_image/version"

class GoogleMapStaticImage
  STATIC_MAP_URL = "https://maps.googleapis.com/maps/api/staticmap"

  def get_response(api_key, markers, option = {})
    query = {}
    query[:api_key] = api_key
    query[:size]    = "1024x1024"
    query[:scale]   = 2
    query[:style]   = option[:style].map { |key, val| "#{key}:#{val}" }.join("|") unless option[:style].nil?
    query[:path]    = option[:path].map { |key, val| "#{key}:#{val}" }.join("|") unless option[:path].nil?
    unless option[:location].nil?
      query[:path] = [query[:path], option[:location].map { |_key, val| val.to_s }.join("|")].join("|")
    end
    query[:markers] = option[:markers].map { |val| val.join("|") } unless option[:markers].nil?

    response = HTTParty.get(STATIC_MAP_URL, query: query)
    response.parsed_response
  end
end
