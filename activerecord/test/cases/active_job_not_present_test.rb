# frozen_string_literal: true

require "cases/helper"

require "models/pirate"

class ActiveJobNotPresentTest < ActiveRecord::TestCase
  test "destroy later raises exception when activejob is not present" do
    assert_raises ActiveRecord::ActiveJobRequiredError do
      Pirate.destroy_later after: 10.days
    end
    pirate = Pirate.create!(catchphrase: "Arr, matey!")
    assert_raises ActiveRecord::ActiveJobRequiredError do
      pirate.destroy_later after: 10.days
    end
  end
end
