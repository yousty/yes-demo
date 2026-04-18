# frozen_string_literal: true

class CreateBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :boards, id: :uuid do |t|
      t.string   :title
      t.string   :description
      t.uuid     :owner_id
      t.boolean  :archived, default: false, null: false
      t.uuid     :member_ids, array: true, default: []
      t.datetime :removed_at

      t.integer  :revision, null: false, default: -1
      t.datetime :pending_update_since

      t.timestamps
    end

    add_index :boards, :owner_id
    add_index :boards, :removed_at
    add_index :boards, :member_ids, using: :gin
    add_index :boards, :pending_update_since,
              where: 'pending_update_since IS NOT NULL',
              name: 'idx_boards_pending_recovery'
    add_index :boards, :id,
              unique: true,
              where: 'pending_update_since IS NOT NULL',
              name: 'idx_boards_one_pending_per_aggregate'
  end
end
