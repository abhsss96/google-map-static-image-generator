require "spec_helper"

RSpec.describe GoogleMapStaticImage do
  let(:api_key) { "test_api_key" }
  let(:map) { described_class.new }
  let(:static_map_url) { GoogleMapStaticImage::STATIC_MAP_URL }

  describe "#get_response" do
    context "with minimal options" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "PNG_IMAGE_DATA", headers: {})
      end

      it "calls the Google Static Maps API with key param" do
        map.get_response(api_key, nil)
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("key" => api_key, "size" => "1024x1024"))
      end

      it "returns the parsed response" do
        result = map.get_response(api_key, nil)
        expect(result).to eq("PNG_IMAGE_DATA")
      end
    end

    context "with markers" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes markers in the query" do
        map.get_response(api_key, nil, markers: [["48.8584,2.2945", "48.8606,2.3376"]])
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("key" => api_key))
      end
    end

    context "with path options" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes path styling in the query" do
        map.get_response(api_key, nil, path: { weight: 3, color: "blue" })
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("path" => "weight:3|color:blue"))
      end
    end

    context "with style options" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes map styles in the query" do
        map.get_response(api_key, nil, style: { feature: "all", visibility: "off" })
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("style" => "feature:all|visibility:off"))
      end
    end

    context "with center option" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes center in the query" do
        map.get_response(api_key, nil, center: "48.8584,2.2945")
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("center" => "48.8584,2.2945"))
      end
    end

    context "with zoom option" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes zoom in the query" do
        map.get_response(api_key, nil, zoom: 14)
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("zoom" => "14"))
      end
    end

    context "with map_type option" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 200, body: "IMAGE", headers: {})
      end

      it "includes maptype in the query for a valid type" do
        map.get_response(api_key, nil, map_type: "satellite")
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("maptype" => "satellite"))
      end

      it "ignores an invalid map_type" do
        map.get_response(api_key, nil, map_type: "invalid")
        expect(WebMock).not_to have_requested(:get, static_map_url)
          .with(query: hash_including("maptype" => anything))
      end
    end

    context "when the API returns a non-200 response" do
      before do
        stub_request(:get, static_map_url)
          .with(query: hash_including({}))
          .to_return(status: 403, body: "Request denied", headers: {})
      end

      it "raises an ApiError with the status and body" do
        expect { map.get_response(api_key, nil) }
          .to raise_error(GoogleMapStaticImage::ApiError) do |error|
            expect(error.status).to eq(403)
            expect(error.body).to eq("Request denied")
            expect(error.message).to include("403")
          end
      end
    end

    it "uses scale 2 by default" do
      stub_request(:get, static_map_url).with(query: hash_including({})).to_return(status: 200, body: "IMAGE", headers: {})
      map.get_response(api_key, nil)
      expect(WebMock).to have_requested(:get, static_map_url)
        .with(query: hash_including("scale" => "2"))
    end

    it "uses 1024x1024 size by default" do
      stub_request(:get, static_map_url).with(query: hash_including({})).to_return(status: 200, body: "IMAGE", headers: {})
      map.get_response(api_key, nil)
      expect(WebMock).to have_requested(:get, static_map_url)
        .with(query: hash_including("size" => "1024x1024"))
    end

    context "with url_only: true" do
      it "returns the constructed URL without making an HTTP request" do
        url = map.get_response(api_key, nil, center: "48.8584,2.2945", zoom: 14, url_only: true)
        expect(url).to eq("#{static_map_url}?key=#{api_key}&size=1024x1024&scale=2&center=48.8584%2C2.2945&zoom=14")
        expect(WebMock).not_to have_requested(:get, /.*/)
      end
    end
  end

  describe "ApiError" do
    it "is a subclass of StandardError" do
      expect(GoogleMapStaticImage::ApiError.ancestors).to include(StandardError)
    end

    it "exposes status and body attributes" do
      error = GoogleMapStaticImage::ApiError.new(404, "Not Found")
      expect(error.status).to eq(404)
      expect(error.body).to eq("Not Found")
    end

    it "includes status in the message" do
      error = GoogleMapStaticImage::ApiError.new(500, "Server Error")
      expect(error.message).to eq("Google Maps Static API error 500: Server Error")
    end
  end

  describe "configuration" do
    after do
      GoogleMapStaticImage.configure do |c|
        c.signing_secret = nil
      end
    end

    it "allows configuring the signing secret globally" do
      GoogleMapStaticImage.configure do |c|
        c.signing_secret = "global_secret"
      end
      expect(GoogleMapStaticImage.configuration.signing_secret).to eq("global_secret")
    end
  end

  describe "digital signatures" do
    let(:secret) { "vodaW7inH256mF516598m2Fw=" }
    let(:google_example_signature) { "N8Te_E-QyWk46Xs_XSsTlUlAAiA=" }
    let(:expected_signature) { "t_9kvnGF7jCxECljbOFuDsVDpCQ=" }

    after do
      GoogleMapStaticImage.configure do |c|
        c.signing_secret = nil
      end
    end

    describe "URL signing helper" do
      it "correctly signs a URL matching Google's example documentation" do
        url = "https://maps.googleapis.com/maps/api/staticmap?center=40.714728,-73.998672&zoom=12&size=400x400&key=YOUR_API_KEY"
        signed_url = map.send(:sign_url, url, secret)
        expect(signed_url).to eq("#{url}&signature=#{google_example_signature}")
      end
    end

    context "with global configuration" do
      before do
        GoogleMapStaticImage.configure do |c|
          c.signing_secret = secret
        end
      end

      it "appends the signature in url_only mode" do
        url = map.get_response("YOUR_API_KEY", nil, center: "40.714728,-73.998672", zoom: 12, url_only: true)
        expect(url).to include("signature=#{expected_signature}")
      end

      it "makes the HTTP request with the signature" do
        stub_request(:get, /#{Regexp.escape(static_map_url)}/)
          .to_return(status: 200, body: "IMAGE_DATA")

        map.get_response("YOUR_API_KEY", nil, center: "40.714728,-73.998672", zoom: 12)

        expect(WebMock).to have_requested(:get, /.*/)
          .with(query: hash_including("signature" => expected_signature))
      end
    end

    context "with per-request option" do
      it "appends the signature in url_only mode" do
        url = map.get_response("YOUR_API_KEY", nil, center: "40.714728,-73.998672", zoom: 12, url_only: true, signing_secret: secret)
        expect(url).to include("signature=#{expected_signature}")
      end

      it "makes the HTTP request with the signature" do
        stub_request(:get, /#{Regexp.escape(static_map_url)}/)
          .to_return(status: 200, body: "IMAGE_DATA")

        map.get_response("YOUR_API_KEY", nil, center: "40.714728,-73.998672", zoom: 12, signing_secret: secret)

        expect(WebMock).to have_requested(:get, /.*/)
          .with(query: hash_including("signature" => expected_signature))
      end

      it "prefers per-request secret over global secret" do
        GoogleMapStaticImage.configure do |c|
          c.signing_secret = "global_secret_which_is_different"
        end

        url = map.get_response("YOUR_API_KEY", nil, center: "40.714728,-73.998672", zoom: 12, url_only: true, signing_secret: secret)
        expect(url).to include("signature=#{expected_signature}")
      end
    end
  end
end
