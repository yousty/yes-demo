# frozen_string_literal: true

module TaskFlow
  module Task
    # Aggregate representing a single task on a Kanban board.
    #
    # Domain invariants (enforced by guards):
    #   - A task can only be created once (title is blank until created).
    #   - A task cannot be created on, assigned within, or started on an archived board.
    #   - An assignee must be a member of the task's board.
    #   - Status transitions follow: todo -> in_progress -> done
    #                                todo/in_progress -> cancelled
    #                                done -> todo (reopen)
    #
    # Authorization: the caller must be a member of the task's board.
    class Aggregate < Yes::Core::Aggregate
      read_model :task

      parent :board, command: false
      removable

      authorize do
        # Resolve the board id from either the create payload or the persisted
        # task read model, so this single authorizer covers both first-time
        # create_task commands and all subsequent task commands.
        bid = command.try(:board_id) || ::Task.find_by(id: command.task_id)&.board_id
        board = bid.present? ? ::Board.find_by(id: bid) : nil
        next true if board.present? && board.member_ids.to_a.include?(auth_data[:identity_id])

        raise Yes::Core::Authorization::CommandAuthorizer::CommandNotAuthorized,
              'You must be a member of this board'
      end

      attribute :title, :string
      attribute :description, :string
      attribute :status, :task_status
      attribute :priority, :task_priority
      attribute :due_date, :date
      attribute :assignee_id, :uuid
      attribute :completed_at, :datetime

      command :create_task do
        event :created

        payload board_id: :uuid,
                title: :string,
                priority: { type: :task_priority, default: 'medium', optional: true }

        guard(:no_change) { title.blank? }
        guard(:title_present) { payload.title.to_s.strip.size.positive? }
        guard(:board_exists_and_open) do
          board = ::Board.find_by(id: payload.board_id)
          board.present? && !board.archived
        end

        update_state do
          board_id { payload.board_id }
          title { payload.title }
          priority { payload.priority }
          status { 'todo' }
        end
      end

      command :change, :title

      command :change_description do
        payload description: { type: :string, nullable: true }

        guard(:no_change) { description != payload.description }
      end

      command :change, :priority, :task_priority

      command :set_due_date do
        event :due_date_set

        payload due_date: { type: :date, nullable: true }

        # due_date attribute is a Date object (from the AR column) while payload.due_date
        # is a string (:date_value is a formatted string). Normalize both to strings.
        guard(:no_change) { due_date&.to_s != payload.due_date.to_s }
      end

      command :assign_to_member do
        event :member_assigned

        payload assignee_id: :uuid

        guard(:no_change) { assignee_id != payload.assignee_id }
        guard(:assignee_is_board_member) do
          board = ::Board.find_by(id: board_id)
          board.present? && !board.archived && board.member_ids.to_a.include?(payload.assignee_id)
        end

        update_state do
          assignee_id { payload.assignee_id }
        end
      end

      command :unassign do
        event :unassigned

        guard(:currently_assigned) { assignee_id.present? }

        update_state do
          assignee_id { nil }
        end
      end

      command :start do
        event :started

        guard(:status_is_todo) { status == 'todo' }
        guard(:board_not_archived) do
          board = ::Board.find_by(id: board_id)
          board.present? && !board.archived
        end

        update_state do
          status { 'in_progress' }
        end
      end

      command :complete do
        event :completed

        guard(:status_is_in_progress) { status == 'in_progress' }

        update_state do
          status { 'done' }
          completed_at { Time.current }
        end
      end

      command :reopen do
        event :reopened

        guard(:status_is_done) { status == 'done' }

        update_state do
          status { 'todo' }
          completed_at { nil }
        end
      end

      command :cancel do
        event :cancelled

        guard(:not_already_cancelled) { status != 'cancelled' }
        guard(:not_done) { status != 'done' }

        update_state do
          status { 'cancelled' }
        end
      end
    end
  end
end
