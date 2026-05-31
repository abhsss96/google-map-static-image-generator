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

      it "calls the Google Static Maps API" do
        map.get_response(api_key, nil)
        expect(WebMock).to have_requested(:get, static_map_url)
          .with(query: hash_including("api_key" => api_key, "size" => "1024x1024"))
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
          .with(query: hash_including("api_key" => api_key))
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
  end
end
