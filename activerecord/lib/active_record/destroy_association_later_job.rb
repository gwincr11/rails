# frozen_string_literal: true

module ActiveRecord
  class DestroyAssociationLaterJob < ActiveJob::Base
    queue_as { ActiveRecord::Base.queues[:destroy] }

    discard_on ActiveJob::DeserializationError

    def perform(model_name, model_id, assoc_class, assoc_ids)
      puts "in perform"
      assoc_model = assoc_class.constantize

      puts assoc_model
      assoc_model.where(id: assoc_ids).each do |r|
        r.destroy
      end
      puts "done"
    end
  end
end
