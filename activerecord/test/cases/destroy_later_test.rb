# frozen_string_literal: true

require File.expand_path("../../../activejob/lib/active_job", File.dirname(__FILE__))
require "cases/helper"

require "models/destroy_later_parent"
require "models/content"
require "models/book_destroy_later"
require "models/essay_destroy_later"
require "models/dl_keyed_belongs_to"
require "models/dl_keyed_belongs_to_soft_delete"
require "models/dl_keyed_has_one"
require "models/dl_keyed_join"
require "models/dl_keyed_has_many"
require "models/dl_keyed_has_many_through"
require "models/tag"
require "models/tagging"

class DestroyLaterTest < ActiveRecord::TestCase
  include ActiveJob::TestHelper


  test "creating a destroy later parent enqueues it for unconditional destruction 10 days later" do
    freeze_time

    dl_parent = DestroyLaterParent.create!()
    assert_enqueued_with job: ActiveRecord::DestroyJob, args: [ dl_parent, ensuring: nil ], at: 10.days.from_now

    travel 10.days

    assert_difference -> { DestroyLaterParent.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyJob
    end
  end

  test "updating a destroy later parent does not enqueue it for destruction" do
    dl_parent = DestroyLaterParent.create!()
    assert_no_enqueued_jobs only: ActiveRecord::DestroyJob do
      dl_parent.update!(name: "Hello")
    end
  end

  test "updating a destroy later parent does not prevent its scheduled destruction" do
    freeze_time

    dl_parent = DestroyLaterParent.create!()
    assert_enqueued_with job: ActiveRecord::DestroyJob, args: [ dl_parent, ensuring: nil ], at: 10.days.from_now

    travel 2.days

    dl_parent.update!(name: "Hello")

    travel 8.days

    assert_difference -> { DestroyLaterParent.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyJob
    end
  end

  test "publishing a book destroy later enqueues it for destruction 30 days later" do
    freeze_time
    book = BookDestroyLater.create

    assert_enqueued_with job: ActiveRecord::DestroyJob, args: [ book, ensuring: :published? ], at: 30.days.from_now do
      book.published!
    end

    travel 30.days

    assert_difference -> { BookDestroyLater.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyJob
    end
  end

  test "creating a published book destroy later enqueues it for destruction 30 days later" do
    freeze_time

    book = BookDestroyLater.create!(status: :published)
    assert_enqueued_with job: ActiveRecord::DestroyJob, args: [ book, ensuring: :published? ], at: 30.days.from_now

    travel 30.days

    assert_difference -> { BookDestroyLater.count }, -1 do
      perform_enqueued_jobs only: ActiveRecord::DestroyJob
    end
  end

  test "unpublishing a book prevents its scheduled destruction" do
    freeze_time

    book = BookDestroyLater.create
    assert_enqueued_with job: ActiveRecord::DestroyJob, args: [ book, ensuring: :published? ], at: 30.days.from_now do
      book.published!
    end

    travel 10.days

    assert_no_enqueued_jobs do
      book.proposed!
    end

    travel 20.days

    assert_no_difference -> { BookDestroyLater.count } do
      perform_enqueued_jobs only: ActiveRecord::DestroyJob
    end
  end

  test "writing a book does not enqueue it for destruction" do
    book = BookDestroyLater.create
    assert_no_enqueued_jobs do
      book.written!
    end
  end
end
