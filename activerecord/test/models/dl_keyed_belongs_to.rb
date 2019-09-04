# frozen_string_literal: true

class DlBelongsTo < ActiveRecord::Base
  self.primary_key = 'belongs_key'
  belongs_to :destory_later_parent, dependent: :destroy_async
end
