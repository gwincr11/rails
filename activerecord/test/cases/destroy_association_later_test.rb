# frozen_string_literal: true

require "cases/helper"

require "models/book"
require "models/tag"
require "models/tagging"

class DestroyAssociationLaterTest < ActiveRecord::TestCase
  include ActiveJob::TestHelper

  fixtures :books, :tags

  test "destroying a book enqueues the tags to be deleted" do
    tag = Tag.create!(name: "Der be treasure")
    tag2 = Tag.create!(name: "Der be rum")
    book = Book.create!(name: "Arr, matey!")
    book.tags << [tag, tag2]
    book.save!
    book.destroy
    assert_enqueued_with job: ActiveRecord::DestroyAssociationLaterJob

    assert_difference -> { Tagging.count }, -2 do
      perform_enqueued_jobs only: ActiveRecord::DestroyAssociationLaterJob
    end
  end
end
