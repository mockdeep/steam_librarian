module SteamLibrarian::HowLongToBeat::Client
  BASE_URL='https://howlongtobeat.com'
  SEARCH_URL="#{BASE_URL}/api/search"
  EDIT_DATA_URL="#{BASE_URL}/_next/data/<build_id>/game/<game_id>.json"

  HEADERS = {
    'content-type' => 'application/json',
    'referer' => BASE_URL,
    'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0',
  }

  class << self
    def search(game, mutex:)
      name = SteamLibrarian.normalize(game.name)
      body = {
          'searchType': "games",
          'searchTerms': name.split,
          'searchPage': 1,
          'size': 20,
          'searchOptions': {
              'games': {
                  'userId': 0,
                  'platform': "",
                  'sortCategory': "popular",
                  'rangeCategory': "main",
                  'rangeTime': {
                      'min': 0,
                      'max': 0
                  },
                  'gameplay': {
                      'perspective': "",
                      'flow': "",
                      'genre': ""
                  },
                  'modifier': "",
              },
              'users': {
                  'sortCategory': "postcount"
              },
              'filter': "",
              'sort': 0,
              'randomizer': 0
          }
      }.to_json
      response = post_with_backoff(body, mutex:)
      result = JSON.parse(response.body).deep_symbolize_keys

      if result[:data].empty?
        puts "No matches for game: #{game.name}"
        return
      end

      matching_data = result[:data].detect do |game_data|
        SteamLibrarian.normalize(game_data[:game_name]) == name ||
          SteamLibrarian.normalize(game_data[:game_alias]) == name
      end

      return matching_data if matching_data && confirm(game, matching_data, mutex:)

      matching_data = result[:data].detect do |game_data|
        confirm(game, game_data, mutex:)
      end

      # mutex.synchronize { binding.irb } unless matching_data

      matching_data
    end

    def confirm(game, game_data, mutex:)
      edit_url = edit_data_url(game_data)
      page_data = JSON.parse(HTTP.get(edit_url, headers: HEADERS).body).deep_symbolize_keys
      edit_game_data = page_data[:pageProps][:game][:data][:game].first

      mutex.synchronize { binding.irb } unless edit_game_data
      edit_game_data[:profile_steam] == game.steam_appid ||
        edit_game_data[:profile_steam_alt] == game.steam_appid
    end

    def post_with_backoff(body, retry_count: 0, mutex:)
      url = "#{SEARCH_URL}/#{mutex.synchronize { api_key }}"
      raise "Too many retries" if retry_count > 5

      response = HTTP.post(url, body:, headers: HEADERS)
      return response if response.status.success?

      @request_info = nil if response.status == 403

      puts "Retrying #{url} #{retry_count}"
      sleep 2 ** retry_count
      post_with_backoff(body, retry_count: retry_count + 1, mutex:)
    end

    def edit_data_url(game_data)
      EDIT_DATA_URL.sub('<build_id>', build_id).gsub('<game_id>', game_data[:game_id].to_s)
    end

    def api_key
      request_info[:api_key]
    end

    def build_id
      request_info[:build_id]
    end

    def request_info
      @request_info ||= begin
        session = Capybara::Session.new(:selenium_headless)
        session.visit(BASE_URL)
        build_id = JSON.parse(session.find('#__NEXT_DATA__', visible: false).text(:all))['buildId']
        scripts = session.all("script", visible: false)

        src = scripts.map { |s| s['src'] }.detect { |s| s.include?('_app') }
        session.visit(src)

        api_key = session.text.match(%r{/api/search/".concat\("([[:alnum:]]+)"\)})[1]

        { api_key:, build_id: }
      ensure
        session.quit
      end
    end
  end
end
