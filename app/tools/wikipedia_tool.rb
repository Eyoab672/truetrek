require 'open-uri'
class WikipediaTool < RubyLLM::Tool
  description "Gets a summary of the place"
  param :place_name "name of the place"
  

  def execute(:place_name)
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/#{:place_name}"

    response = URI.parse(url).read
    JSON.parse(response)
  rescue => e
    { error: e.message }
  end
end