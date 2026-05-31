class GoogleMapStaticImage
  require "httparty"
  require "debugger"
  def get_response(api_key,markers,option={})
    
    
    url = "https://maps.googleapis.com/maps/api/staticmap"
    url1= "http://192.168.0.19:3041"
    
    query = Hash.new
    query[:api_key]   = api_key
    query[:size]      = "1024x1024"
    query[:scale]     = 2
    query[:style]     = option[:style].map {|key,val| "#{key}:#{val}"}.join("|")                                       unless option[:style].nil?
    query[:path]      = option[:path].map {|key,val| "#{key}:#{val}"}.join("|")                                        unless option[:path].nil?  
    query[:path]      = [query[:path],option[:location].map {|key,val| "#{val}"}.join("|")].join("|")                  unless option[:location].nil?
    query[:markers]   = option[:markers].map { |val| val.join("|")}                                                    unless option[:markers].nil? 
                               
    response = HTTParty.get("#{url1}", :query=>query)
    response = HTTParty.get("#{url}", :query=>query)
    return response.parsed_response

  end 

end
