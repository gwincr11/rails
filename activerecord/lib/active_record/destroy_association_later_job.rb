# frozen_string_literal: true

module ActiveRecord
  class DestroyAssociationLaterJob < ActiveJob::Base
    queue_as { ActiveRecord::Base.queues[:destroy] }

    discard_on ActiveJob::DeserializationError

    def perform(records)
      records.each do |r|
        r.destroy
      end
    end
  end
end
