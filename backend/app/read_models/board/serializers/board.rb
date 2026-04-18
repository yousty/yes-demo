# frozen_string_literal: true

module ReadModels
  module Board
    module Serializers
      # JSON:API serializer for the Board read model.
      class Board
        include JSONAPI::Serializer

        set_type :boards

        attributes :title, :description, :owner_id, :archived, :member_ids, :created_at, :updated_at

        attribute :removed do |record|
          record.removed_at.present?
        end
      end
    end
  end
end
