# frozen_string_literal: true

# Read model for the TaskFlow::Task aggregate.
class Task < ApplicationRecord
  belongs_to :board, optional: true

  scope :not_removed, -> { where(removed_at: nil) }
  scope :by_ids, ->(ids) { where(id: ids) }
  scope :by_board, ->(board_id) { where(board_id:) }
  scope :by_status, ->(status) { where(status:) }
  scope :assigned_to, ->(assignee_id) { where(assignee_id:) }

  def auth_attributes
    { board_id: }
  end
end
