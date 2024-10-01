module Steamer::HowLongToBeat::Client
  HOW_LONG_TO_BEAT_BASE_URL='https://howlongtobeat.com/'
  HOW_LONG_TO_BEAT_API_KEY=ENV.fetch('HOW_LONG_TO_BEAT_API_KEY')
  HOW_LONG_TO_BEAT_SEARCH_URL="#{HOW_LONG_TO_BEAT_BASE_URL}api/search/#{HOW_LONG_TO_BEAT_API_KEY}"

  class << self
    def search(name)
      headers = {
        'content-type' => 'application/json',
        'referer' => HOW_LONG_TO_BEAT_BASE_URL,
        'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0',
      }

      body = {
          'searchType': "games",
          'searchTerms': name.split,
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
      response = post_with_backoff(HOW_LONG_TO_BEAT_SEARCH_URL, body, headers)
      result = JSON.parse(response.body).deep_symbolize_keys
      game = result[:data].detect do |game|
        Steamer.normalize(game[:game_name]) == name ||
          Steamer.normalize(game[:game_alias]) == name
      end

      unless game
        puts "Game not found #{name}"

        # raise "no matches for game: #{game}" if result[:data].empty?
        return if result[:data].empty?

        puts "Found alternatives:"
        result[:data].each_with_index do |game_data, index|
          game_string = "#{game_data[:game_id]} #{game_data[:game_name]} (#{game_data[:game_alias]})"
          puts "#{index + 1}. #{game_string}"
        end

        game_index = gets
        p game_index
        game = result[:data][Integer(game_index.strip) - 1] if game_index
      end

      game
    end

    def post_with_backoff(url, body, headers, retry_count: 0)
      raise "Too many retries" if retry_count > 5

      response = HTTP.post(url, body:, headers:)
      return response if response.status.success?

      puts "Retrying #{url} #{retry_count}"
      sleep 2 ** retry_count
      post_with_backoff(url, body, headers, retry_count: retry_count + 1)
    end
  end
end
