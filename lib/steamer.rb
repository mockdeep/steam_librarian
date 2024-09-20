# "https://steamspy.com/api.php?request=appdetails&appid=730"
# "https://store.steampowered.com/api/appdetails?appids=57690"
# "https://store.steampowered.com/appreviews/10?json=1&language=all"

# get list of games from steam
# get times for each game from HowLongToBeat

STEAM_WEB_API_KEY=ENV.fetch('STEAM_WEB_API_KEY')
STEAM_ID=ENV.fetch('STEAM_ID')
HOW_LONG_TO_BEAT_BASE_URL='https://howlongtobeat.com/'
HOW_LONG_TO_BEAT_API_KEY=ENV.fetch('HOW_LONG_TO_BEAT_API_KEY')
HOW_LONG_TO_BEAT_SEARCH_URL="#{HOW_LONG_TO_BEAT_BASE_URL}api/search/#{HOW_LONG_TO_BEAT_API_KEY}"

def steam_games
  url = "http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?key=#{STEAM_WEB_API_KEY}&steamid=#{STEAM_ID}&format=json&include_appinfo=1&include_played_free_games=1"
  response = HTTP.get(url)
  JSON.parse(response.body).deep_symbolize_keys[:response][:games]
end

# binding.irb
headers = {
  'content-type' => 'application/json',
  'referer' => HOW_LONG_TO_BEAT_BASE_URL,
  'User-Agent' => 'Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0',
}
body = {
    'searchType': "games",
    'searchTerms': steam_games.sample[:name].split,
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
# appid = steam_games.first[:appid]
# url = HOW_LONG_TO_BEAT_BASE_URL + appid.to_s
response = HTTP.post(HOW_LONG_TO_BEAT_SEARCH_URL, body:, headers:)
binding.irb
