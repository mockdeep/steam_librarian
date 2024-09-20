module Steamer::Steam::Client
  STEAM_WEB_API_KEY=ENV.fetch('STEAM_WEB_API_KEY')
  STEAM_ID=ENV.fetch('STEAM_ID')

  class << self
    def fetch_games
      url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{STEAM_WEB_API_KEY}&steamid=#{STEAM_ID}&format=json&include_appinfo=1&include_played_free_games=1"
      response = HTTP.get(url)
      JSON.parse(response.body).deep_symbolize_keys[:response][:games]
    end
  end
end
