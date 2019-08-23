# frozen_string_literal: true

require "cases/helper"

require "models/book"
require "models/tag"
require "models/tagging"
require "models/essay"
require "models/category"
require "models/post"
require "models/content"

class DestroyAssociationLaterTest < ActiveRecord::TestCase
  include ActiveJob::TestHelper

  fixtures :books, :tags

  test "destroying a book enqueues the has_many through tags to be deleted" do
    tag = Tag.create!(name: "Der be treasure")
    tag2 = Tag.create!(name: "Der be rum")
    book = Book.create!(name: "Arr, matey!")
    book.tags << [tag, tag2]
    book.save!
    book.destroy
    assert_enqueued_with job: ActiveRecord::DestroyAssociationLaterJob

    assert_difference -> { Tag.count }, -2 do
      perform_enqueued_jobs only: ActiveRecord::DestroyAssociationLaterJob
    end
  end

  test "belongs to" do
    essay = Essay.create!(name: "Der be treasure")
    book = Book.create!(name: "Arr, matey!")
    essay.book = book
    essay.save!
    essay.destroy
    assert_enqueued_with job: ActiveRecord::DestroyAssociationLaterJob

    assert_difference -> { Book.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyAssociationLaterJob
    end
  end

  test "has_one" do
    content = Content.create(title: "hello")
    book = Book.create!(name: "Arr, matey!")
    book.content = content
    book.save!
    book.destroy
    assert_enqueued_with job: ActiveRecord::DestroyAssociationLaterJob

    assert_difference -> { Content.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyAssociationLaterJob
    end
  end

  test "has_many" do
    essay = Essay.create!(name: "Der be treasure")
    essay2 = Essay.create!(name: "Der be rum")
    book = Book.create!(name: "Arr, matey!")
    book.essays << [essay, essay2]
    book.save!
    book.destroy
    assert_enqueued_with job: ActiveRecord::DestroyAssociationLaterJob

    assert_difference -> { Essay.count }, -2 do
      perform_enqueued_jobs only: ActiveRecord::DestroyAssociationLaterJob
    end
  end
end
