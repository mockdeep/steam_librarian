# "https://steamspy.com/api.php?request=appdetails&appid=730"
# "https://store.steampowered.com/api/appdetails?appids=57690"
# "https://store.steampowered.com/appreviews/10?json=1&language=all"

# get list of games from steam
# get times for each game from HowLongToBeat

module Steamer

  class << self
    def call
      games = Steamer::Steam::Client.fetch_games

      # binding.irb
      # appid = steam_games.first[:appid]
      # url = HOW_LONG_TO_BEAT_BASE_URL + appid.to_s
      game = games.sample
      result = Steamer::HowLongToBeat.search(game[:name])
      binding.irb
    end
  end
end

require_relative "steamer/how_long_to_beat"
require_relative "steamer/steam"
