# frozen_string_literal: true

module TaskFlow
  module Board
    # Aggregate representing a collaborative Kanban board.
    #
    # Domain invariants (enforced by guards):
    #   - A board can only be created once (title is blank until created).
    #   - Members cannot be added to an archived board.
    #   - The owner cannot be removed from the member list.
    #   - Ownership can only be transferred to an existing member.
    #
    # Authorization:
    #   - Aggregate-level: any authenticated identity may issue non-privileged commands.
    #   - Privileged commands (archive/unarchive/remove_member/transfer_ownership)
    #     require the caller to be the current owner.
    class Aggregate < Yes::Core::Aggregate
      read_model :board

      removable

      authorize do
        next true if auth_data[:identity_id].present?

        raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
              'Authentication required'
      end

      attribute :title, :string
      attribute :description, :string
      attribute :owner_id, :uuid
      attribute :archived, :boolean
      attribute :member_ids, :uuids

      command :create_board do
        event :created

        payload title: :string,
                description: { type: :string, nullable: true },
                owner_id: :uuid

        guard(:no_change) { title.blank? }
        guard(:title_present) { payload.title.to_s.strip.size.positive? }

        update_state do
          title { payload.title }
          description { payload.description }
          owner_id { payload.owner_id }
          archived { false }
          member_ids { [payload.owner_id] }
        end
      end

      command :change, :title

      command :change_description do
        payload description: { type: :string, nullable: true }

        guard(:no_change) { description != payload.description }
      end

      command :archive do
        event :archived

        authorize do
          board = ::Board.find_by(id: command.board_id)
          next true if board && auth_data[:identity_id] == board.owner_id

          raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
                'Only the board owner can perform this action'
        end

        guard(:no_change) { !archived }

        update_state { archived { true } }
      end

      command :unarchive do
        event :unarchived

        authorize do
          board = ::Board.find_by(id: command.board_id)
          next true if board && auth_data[:identity_id] == board.owner_id

          raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
                'Only the board owner can perform this action'
        end

        guard(:no_change) { archived == true }

        update_state { archived { false } }
      end

      command :add_member do
        event :member_added

        payload member_id: :uuid

        guard(:not_archived) { !archived }
        guard(:no_change) { (member_ids || []).exclude?(payload.member_id) }

        update_state do
          member_ids { (member_ids || []) + [payload.member_id] }
        end
      end

      command :remove_member do
        event :member_removed

        payload member_id: :uuid

        authorize do
          board = ::Board.find_by(id: command.board_id)
          next true if board && auth_data[:identity_id] == board.owner_id

          raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
                'Only the board owner can perform this action'
        end

        guard(:not_owner) { payload.member_id != owner_id }
        guard(:is_member) { (member_ids || []).include?(payload.member_id) }

        update_state do
          member_ids { (member_ids || []) - [payload.member_id] }
        end
      end

      command :transfer_ownership do
        event :ownership_transferred

        payload new_owner_id: :uuid

        authorize do
          board = ::Board.find_by(id: command.board_id)
          next true if board && auth_data[:identity_id] == board.owner_id

          raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
                'Only the board owner can perform this action'
        end

        guard(:different_owner) { payload.new_owner_id != owner_id }
        guard(:new_owner_is_member) { (member_ids || []).include?(payload.new_owner_id) }

        update_state do
          owner_id { payload.new_owner_id }
        end
      end
    end
  end
end
