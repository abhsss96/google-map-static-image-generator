# google-map-static-image-generator

A Ruby gem that wraps the [Google Maps Static API](https://developers.google.com/maps/documentation/maps-static/overview) to generate customizable static map images in Rails applications.

## Installation

Add this line to your `Gemfile`:

```ruby
gem 'google-map-static-image-generator'
```

Then run:

```bash
bundle install
```

## Usage

```ruby
map = GoogleMapStaticImage.new

response = map.get_response(
  "YOUR_GOOGLE_API_KEY",
  markers,           # array of marker coordinate strings
  style:    { feature: "all", element: "labels", visibility: "off" },
  path:     { weight: 3, color: "blue" },
  location: { lat: "48.8584", lng: "2.2945" },
  markers:  [["48.8584,2.2945"], ["48.8606,2.3376"]]
)

# Or to just get the URL without making a request:
url = map.get_response(
  "YOUR_GOOGLE_API_KEY",
  nil,
  center: '48.8584,2.2945',
  zoom: 14,
  url_only: true
)
# => "https://maps.googleapis.com/maps/api/staticmap?key=YOUR_GOOGLE_API_KEY&size=1024x1024&scale=2&center=48.8584,2.2945&zoom=14"
```

The response is the raw parsed response from the Google Static Maps API — typically image binary data or a redirect URL depending on your usage. If `url_only: true` is passed, the response is just the constructed URL string.

## Options

| Option | Description |
|--------|-------------|
| `style` | Map style rules as a hash (`key: value` pairs joined with `\|`) |
| `path` | Path styling options (weight, color, etc.) |
| `location` | Hash of `lat`/`lng` to append to the path |
| `markers` | Array of marker groups; each group is an array of coordinate strings |
| `url_only` | If `true`, returns the full URL string instead of making an HTTP request |

The default image size is `1024x1024` at scale `2`.

## Dependencies

- [httparty](https://github.com/jnunemaker/httparty)
