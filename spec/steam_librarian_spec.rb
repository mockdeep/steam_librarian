# frozen_string_literal: true

RSpec.describe SteamLibrarian do
  it "has a version number" do
    expect(SteamLibrarian::VERSION).not_to be nil
  end
end
