# frozen_string_literal: true

require "cases/helper"

require "models/pirate"
require "models/book"
require "models/essay"

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

  test "has_one dependent destroy_later requires activejob" do
    assert_raises ActiveRecord::ActiveJobRequiredError do
      Book.has_one :content, dependent: :destroy_later
    end
  end

  test "has_many dependent destroy_later requires activejob" do
    assert_raises ActiveRecord::ActiveJobRequiredError do
      Book.has_many :essays, dependent: :destroy_later
    end
  end

  test "belong_to dependent destroy_later requires activejob" do
    assert_raises ActiveRecord::ActiveJobRequiredError do
      Essay.belongs_to :books, dependent: :destroy_later
    end
  end
end
