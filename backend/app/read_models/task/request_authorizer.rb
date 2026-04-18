# frozen_string_literal: true

module ReadModels
  module Task
    # Gates read access to the Task read model.
    # - Requires an authenticated identity.
    # - Requires `filters[board_id]` so the query is always scoped to a
    #   single board, and the caller must be a member of that board.
    class RequestAuthorizer
      NotAuthorized = Yes::Core::Authorization::ReadRequestAuthorizer::NotAuthorized

      def self.call(filter_options, auth_data)
        identity_id = auth_data && auth_data[:identity_id]
        raise NotAuthorized, 'Authentication required to query tasks' if identity_id.blank?

        board_id = filter_options.dig(:filters, :board_id) ||
                   filter_options.dig('filters', 'board_id')
        raise NotAuthorized, 'Tasks must be scoped to a board (filters[board_id])' if board_id.blank?

        board = ::Board.find_by(id: board_id)
        return if board.present? && board.member_ids.to_a.include?(identity_id.to_s)

        raise NotAuthorized, 'You are not a member of this board'
      end
    end
  end
end
