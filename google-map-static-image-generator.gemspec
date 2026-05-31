require_relative "lib/google_map_static_image/version"

Gem::Specification.new do |spec|
  spec.name          = "google-map-static-image-generator"
  spec.version       = GoogleMapStaticImage::VERSION
  spec.authors       = ["Abhishek Sharma"]
  spec.email         = ["abhsss96@gmail.com"]
  spec.summary       = "Generate static map images using the Google Maps Static API"
  spec.description   = "Wraps the Google Maps Static API to generate customizable static map images with markers, paths, and styles."
  spec.homepage      = "https://github.com/abhsss96/google-map-static-image-generator"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.files         = Dir["lib/**/*", "README.md", "*.gemspec"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", ">= 0.14"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.0"
end
