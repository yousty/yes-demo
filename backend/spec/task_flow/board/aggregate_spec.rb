# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskFlow::Board::Aggregate, type: :aggregate do
  subject { described_class }

  let(:other_id) { SecureRandom.uuid }
  let(:owner_id) { SecureRandom.uuid }

  it { is_expected.to have_authorizer }
  it { is_expected.to have_read_model_class(Board) }

  command 'create_board' do
    let(:command_data) { { title: 'Sprint 42', description: 'Q2 goals', owner_id: } }
    let(:expected_event_type) { 'TaskFlow::BoardCreated' }
    let(:success_attributes) do
      { title: 'Sprint 42', description: 'Q2 goals', owner_id:, archived: false, member_ids: [owner_id] }
    end

    success

    no_change
  end

  command 'change_title' do
    let(:command_data) { { title: 'New Title' } }

    success do
      setup { aggregate.create_board(title: 'Original', description: nil, owner_id:) }
    end

    no_change do
      setup do
        aggregate.create_board(title: 'Original', description: nil, owner_id:)
        aggregate.change_title(title: 'New Title')
      end
    end
  end

  command 'change_description' do
    let(:command_data) { { description: 'Updated' } }

    success do
      setup { aggregate.create_board(title: 'Board', description: 'Old', owner_id:) }
    end

    no_change do
      setup do
        aggregate.create_board(title: 'Board', description: 'Updated', owner_id:)
      end
    end
  end

  command 'archive' do
    let(:command_data) { {} }
    let(:success_attributes) { { archived: true } }

    success do
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end

    no_change do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.archive
      end
    end
  end

  command 'unarchive' do
    let(:command_data) { {} }
    let(:success_attributes) { { archived: false } }

    success do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.archive
      end
    end

    no_change do
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end
  end

  command 'add_member' do
    let(:command_data) { { member_id: other_id } }
    let(:success_attributes) { {} }

    success do
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }

      it 'appends the member id' do
        subject
        expect(aggregate.member_ids).to include(owner_id, other_id)
      end
    end

    no_change do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.add_member(member_id: other_id)
      end
    end

    invalid 'board is archived' do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.archive
      end
    end
  end

  command 'remove_member' do
    let(:command_data) { { member_id: other_id } }
    let(:success_attributes) { {} }

    success do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.add_member(member_id: other_id)
      end

      it 'removes the member id' do
        subject
        expect(aggregate.member_ids).not_to include(other_id)
        expect(aggregate.member_ids).to include(owner_id)
      end
    end

    invalid 'user is the owner' do
      let(:command_data) { { member_id: owner_id } }
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end

    invalid 'user is not a member' do
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end
  end

  command 'transfer_ownership' do
    let(:command_data) { { new_owner_id: other_id } }
    let(:success_attributes) { { owner_id: other_id } }

    success do
      setup do
        aggregate.create_board(title: 'Board', description: nil, owner_id:)
        aggregate.add_member(member_id: other_id)
      end
    end

    invalid 'new owner is not a member' do
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end

    invalid 'new owner is already the owner' do
      let(:command_data) { { new_owner_id: owner_id } }
      setup { aggregate.create_board(title: 'Board', description: nil, owner_id:) }
    end
  end
end
