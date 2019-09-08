# frozen_string_literal: true

require "models/destroy_later_parent"

class DlKeyedBelongsTo < ActiveRecord::Base
  self.primary_key = 'belongs_key'
  belongs_to :destory_later_parent, dependent: :destroy_async, foreign_key: :destroy_later_parent_id, primary_key: :parent_id, class_name: "DestroyLaterParent"
end
