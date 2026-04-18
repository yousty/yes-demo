# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFlow::Task::Aggregate, type: :aggregate do
  subject { described_class }

  let(:board)    { FactoryBot.create(:board, owner_id:, member_ids: [owner_id]) }
  let(:owner_id) { SecureRandom.uuid }

  it { is_expected.to have_authorizer }
  it { is_expected.to have_read_model_class(Task) }
  it { is_expected.to have_parent('board') }

  command 'create_task' do
    let(:command_data) { { board_id: board.id, title: 'Write tests', priority: 'high' } }
    let(:expected_event_type) { 'TaskFlow::TaskCreated' }
    let(:success_attributes) { { board_id: board.id, title: 'Write tests', priority: 'high', status: 'todo' } }

    success

    no_change do
      setup { aggregate.create_task(board_id: board.id, title: 'Write tests', priority: 'high') }
    end

    invalid 'board is archived' do
      setup { board.update!(archived: true) }
    end
  end

  command 'change_title' do
    let(:command_data) { { title: 'New Title' } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'Original', priority: 'medium') }
    end

    no_change do
      setup do
        aggregate.create_task(board_id: board.id, title: 'Original', priority: 'medium')
        aggregate.change_title(title: 'New Title')
      end
    end
  end

  command 'change_description' do
    let(:command_data) { { description: 'Helpful text' } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end

    no_change do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.change_description(description: 'Helpful text')
      end
    end
  end

  command 'change_priority' do
    let(:command_data) { { priority: 'high' } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end

    no_change do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'high')
      end
    end
  end

  command 'set_due_date' do
    let(:due_date) { '2026-12-31' }
    let(:command_data) { { due_date: } }
    # the AR read model column coerces the string payload to a Date object
    let(:success_attributes) { { due_date: Date.new(2026, 12, 31) } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end

    no_change do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.set_due_date(due_date:)
      end
    end
  end

  command 'assign_to_member' do
    let(:other_id) { SecureRandom.uuid }
    let(:command_data) { { assignee_id: other_id } }

    success do
      setup do
        board.update!(member_ids: [owner_id, other_id])
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
      end
    end

    invalid 'assignee is not a board member' do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
      end
    end
  end

  command 'unassign' do
    let(:other_id) { SecureRandom.uuid }
    let(:command_data) { {} }

    success do
      setup do
        board.update!(member_ids: [owner_id, other_id])
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.assign_to_member(assignee_id: other_id)
      end
    end

    invalid 'task is not assigned' do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end
  end

  command 'start' do
    let(:command_data) { {} }
    let(:success_attributes) { { status: 'in_progress' } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end

    invalid 'task is not in todo' do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.start
      end
    end
  end

  command 'complete' do
    let(:command_data) { {} }
    let(:success_attributes) { { status: 'done' } }

    success do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.start
      end
    end

    invalid 'task is not in progress' do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end
  end

  command 'reopen' do
    let(:command_data) { {} }
    let(:success_attributes) { { status: 'todo' } }

    success do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.start
        aggregate.complete
      end
    end

    invalid 'task is not done' do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end
  end

  command 'cancel' do
    let(:command_data) { {} }
    let(:success_attributes) { { status: 'cancelled' } }

    success do
      setup { aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium') }
    end

    invalid 'task is done' do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.start
        aggregate.complete
      end
    end

    invalid 'task is already cancelled' do
      setup do
        aggregate.create_task(board_id: board.id, title: 'T', priority: 'medium')
        aggregate.cancel
      end
    end
  end
end
