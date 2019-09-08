# frozen_string_literal: true

module ActiveRecord
  class DestroyAssociationLaterError < StandardError
  end

  class DestroyAssociationLaterJob < ActiveJob::Base
    queue_as { ActiveRecord::Base.queues[:destroy] }

    discard_on ActiveJob::DeserializationError

    def perform(model_name, model_id, assoc_class, assoc_ids, primary_key_column)
      assoc_model = assoc_class.constantize
      owner_class = model_name.constantize
      owner = owner_class
        .where(owner_class.primary_key.to_sym => model_id)

      if !owner.empty?
        raise DestroyAssociationLaterError, "owner record not destroyed"
      end
      assoc_model.where(primary_key_column => assoc_ids).find_each do |r|
        r.destroy
      end
    end
  end
end
