class Steamer::Game
  attr_accessor :steam_appid, :name, :hltb_game_id, :seconds_to_complete, :review_score

  def self.load(**attrs)
    game = allocate

    attrs.each do |key, value|
      game.send("#{key}=", value)
    end

    game
  end

  def initialize(appid:, name:, **)
    self.steam_appid = appid
    self.name = name
  end

  def add_times(game_id:, comp_100:, review_score:, **)
    self.hltb_game_id = game_id
    self.seconds_to_complete = comp_100
    self.review_score = review_score
  end

  def achievement_data_complete?
    true # for now
  end

  def hltb_data_complete?
    hltb_game_id && seconds_to_complete && review_score
  end

  def to_h
    {
      steam_appid:,
      name:,
      hltb_game_id:,
      seconds_to_complete:,
      review_score:,
    }
  end
end
