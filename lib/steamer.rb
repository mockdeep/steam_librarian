# "https://steamspy.com/api.php?request=appdetails&appid=730"
# "https://store.steampowered.com/api/appdetails?appids=57690"
# "https://store.steampowered.com/appreviews/10?json=1&language=all"

# get list of games from steam
# get times for each game from HowLongToBeat

require 'json'

module Steamer

  class << self
    def call
      games = fetch_games

      games.each do |game|
        p game.name
        fetch_achievements(game) unless game.achievement_data_complete?
        fetch_game_times(game) unless game.hltb_data_complete?
        write_to_file(games)
      end


      binding.irb
    end

    def read_from_file
      return [] unless File.exist?("games.json")

      JSON.parse(File.read("games.json")).map do |game|
        Steamer::Game.load(**game)
      end
    end

    def fetch_games
      saved_games = read_from_file.index_by(&:steam_appid)
      steam_games = Steamer::Steam::Client.fetch_games.index_by(&:steam_appid)
      steam_games.merge(saved_games).values
    end

    def fetch_achievements(game)
      # fetch achievements
    end

    def fetch_game_times(game)
      p "fetching game times for #{game.name}"
      result = Steamer::HowLongToBeat::Client.search(normalize(game.name))

      game.add_times(**result)
    end

    def write_to_file(games)
      File.write("games.json", JSON.pretty_generate(games.map(&:to_h)))
    end

    def normalize(name)
      name.gsub(/\W/, ' ').downcase.squish
    end
  end
end

require_relative "steamer/how_long_to_beat"
require_relative "steamer/steam"
require_relative "game"
