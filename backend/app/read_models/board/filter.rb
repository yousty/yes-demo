# frozen_string_literal: true

module ReadModels
  module Board
    # Filter scopes exposed via GET /v1/queries/boards.
    class Filter < Yes::Core::ReadModel::Filter
      has_scope :not_removed, default: true, type: :boolean, allow_blank: true do |_ctrl, scope, value|
        value ? scope.not_removed : scope.all
      end

      has_scope :ids do |_ctrl, scope, value|
        scope.by_ids(value.to_s.split(','))
      end

      has_scope :owner_id do |_ctrl, scope, value|
        scope.owned_by(value)
      end

      has_scope :member_id do |_ctrl, scope, value|
        scope.for_member(value)
      end

      private

      def read_model_class
        ::Board
      end
    end
  end
end
