# frozen_string_literal: true

# Read model for the TaskFlow::Board aggregate.
class Board < ApplicationRecord
  has_many :tasks, dependent: nil

  scope :not_removed, -> { where(removed_at: nil) }
  scope :by_ids, ->(ids) { where(id: ids) }
  scope :for_member, ->(identity_id) { where('? = ANY(member_ids)', identity_id) }
  scope :owned_by, ->(identity_id) { where(owner_id: identity_id) }

  def auth_attributes
    { owner_id:, member_ids: member_ids || [] }
  end
end
