# frozen_string_literal: true

module ReadModels
  module Task
    # Filter scopes exposed via GET /v1/queries/tasks.
    class Filter < Yes::Core::ReadModel::Filter
      has_scope :not_removed, default: true, type: :boolean, allow_blank: true do |_ctrl, scope, value|
        value ? scope.not_removed : scope.all
      end

      has_scope :ids do |_ctrl, scope, value|
        scope.by_ids(value.to_s.split(','))
      end

      has_scope :board_id do |_ctrl, scope, value|
        scope.by_board(value)
      end

      has_scope :status do |_ctrl, scope, value|
        scope.by_status(value)
      end

      has_scope :assignee_id do |_ctrl, scope, value|
        scope.assigned_to(value)
      end

      private

      def read_model_class
        ::Task
      end
    end
  end
end
