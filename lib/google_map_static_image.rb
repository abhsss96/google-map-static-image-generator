require "httparty"
require "openssl"
require "base64"
require "uri"
require_relative "google_map_static_image/version"

class GoogleMapStaticImage
  STATIC_MAP_URL = "https://maps.googleapis.com/maps/api/staticmap"
  VALID_MAP_TYPES = %w[roadmap satellite terrain hybrid].freeze

  class Configuration
    attr_accessor :signing_secret
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end

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

    request = HTTParty::Request.new(Net::HTTP::Get, STATIC_MAP_URL, query: query)
    url = request.uri.to_s

    secret = option[:signing_secret] || GoogleMapStaticImage.configuration.signing_secret
    if secret
      url = sign_url(url, secret)
    end

    if option[:url_only]
      return url
    end

    response = HTTParty.get(url)
    raise ApiError.new(response.code, response.body) unless response.code == 200
    response.parsed_response
  end

  private

  def sign_url(url, secret)
    decoded_key = decode_urlsafe_base64(secret)
    uri = URI.parse(url)
    path_and_query = uri.path + '?' + uri.query
    digest = OpenSSL::HMAC.digest('sha1', decoded_key, path_and_query)
    url + '&signature=' + Base64.urlsafe_encode64(digest)
  end

  def decode_urlsafe_base64(string)
    str = string.tr('-_', '+/').gsub('=', '')
    str = str.ljust((str.length + 3) / 4 * 4, '=')
    Base64.decode64(str)
  end
end
