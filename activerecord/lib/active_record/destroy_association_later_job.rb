# frozen_string_literal: true

module ActiveRecord
  class DestroyAssociationLaterJob < ActiveJob::Base
    queue_as { ActiveRecord::Base.queues[:destroy] }

    discard_on ActiveJob::DeserializationError

    def perform(model_name, model_id, assoc_class, assoc_ids, primary_key_column)
      assoc_model = assoc_class.constantize

      assoc_model.where(primary_key_column => assoc_ids).find_each do |r|
        r.destroy
      end
    end
  end
end
