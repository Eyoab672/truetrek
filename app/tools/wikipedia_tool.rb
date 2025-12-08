require 'open-uri'
class WikipediaTool < RubyLLM::Tool
  description "Gets a summary of the place"
  param :place_name, desc: "name of the place"

  def execute(place_name:)
    url = "https://en.wikipedia.org/api/rest_v1/page/summary/#{place_name}"

    response = URI.parse(url).read
    data = JSON.parse(response)

    { success: true, data: data }
  rescue StandardError => e
    { success: false, reason: "wikipedia_unavailable", error: e.message }
  end
end
