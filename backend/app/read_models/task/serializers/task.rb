# frozen_string_literal: true

module ReadModels
  module Task
    module Serializers
      # JSON:API serializer for the Task read model.
      class Task
        include JSONAPI::Serializer

        set_type :tasks

        attributes :title, :description, :status, :priority, :due_date, :assignee_id,
                   :board_id, :completed_at, :created_at, :updated_at

        attribute :removed do |record|
          record.removed_at.present?
        end
      end
    end
  end
end
