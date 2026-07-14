require_relative "lib/google_map_static_image/version"

Gem::Specification.new do |spec|
  spec.name          = "google-map-static-image-generator"
  spec.version       = GoogleMapStaticImage::VERSION
  spec.authors       = ["Abhishek Sharma"]
  spec.email         = ["abhsss96@gmail.com"]
  spec.summary       = "Generate customizable static map images via the Google Maps Static API"
  spec.description   = <<~DESC
    google-map-static-image-generator is a Ruby wrapper around the Google Maps Static
    API that generates PNG map images on the fly — no JavaScript required.

    Features:
    - Add custom markers at any coordinates
    - Draw paths with custom weight and colour
    - Apply map styles (hide labels, change colours, etc.)
    - Set center + zoom for marker-free maps
    - Choose map type: roadmap, satellite, terrain, or hybrid
    - Default 1024x1024 at scale 2 (retina-friendly)
    - Raises GoogleMapStaticImage::ApiError on non-200 responses (invalid key, quota exceeded, etc.)

    Useful for generating map thumbnails in emails, PDFs, admin dashboards, and anywhere
    an interactive JavaScript map is not practical.
  DESC
  spec.homepage      = "https://github.com/abhsss96/google-map-static-image-generator"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.metadata = {
    "homepage_uri"    => "https://github.com/abhsss96/google-map-static-image-generator",
    "source_code_uri" => "https://github.com/abhsss96/google-map-static-image-generator",
    "bug_tracker_uri" => "https://github.com/abhsss96/google-map-static-image-generator/issues",
    "changelog_uri"   => "https://github.com/abhsss96/google-map-static-image-generator/releases",
    "tags"            => "google-maps, static-maps, maps-api, image-generation, map-thumbnail, geolocation, httparty, rails"
  }

  spec.files         = Dir["lib/**/*", "README.md", "*.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", ">= 0.14"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.0"
end
