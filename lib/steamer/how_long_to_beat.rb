module Steamer::HowLongToBeat
  HOW_LONG_TO_BEAT_BASE_URL='https://howlongtobeat.com/'
  HOW_LONG_TO_BEAT_API_KEY=ENV.fetch('HOW_LONG_TO_BEAT_API_KEY')
  HOW_LONG_TO_BEAT_SEARCH_URL="#{HOW_LONG_TO_BEAT_BASE_URL}api/search/#{HOW_LONG_TO_BEAT_API_KEY}"

  class << self
    def search(game_name)
      headers = {
        'content-type' => 'application/json',
        'referer' => HOW_LONG_TO_BEAT_BASE_URL,
        'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0',
      }

      body = {
          'searchType': "games",
          'searchTerms': game_name.split,
          # 'searchPage': 1,
          # 'size': 20,
          # 'searchOptions': {
          #     'games': {
          #         'userId': 0,
          #         'platform': "",
          #         'sortCategory': "popular",
          #         'rangeCategory': "main",
          #         'rangeTime': {
          #             'min': 0,
          #             'max': 0
          #         },
          #         'gameplay': {
          #             'perspective': "",
          #             'flow': "",
          #             'genre': ""
          #         },
          #         'modifier': "",
          #     },
          #     'users': {
          #         'sortCategory': "postcount"
          #     },
          #     'filter': "",
          #     'sort': 0,
          #     'randomizer': 0
          # }
      }.to_json
      response = HTTP.post(HOW_LONG_TO_BEAT_SEARCH_URL, body:, headers:)
      JSON.parse(response.body)
    end
  end
end
