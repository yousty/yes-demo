# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks, id: :uuid do |t|
      t.string   :title
      t.string   :description
      t.string   :status
      t.string   :priority
      t.date     :due_date
      t.uuid     :assignee_id
      t.uuid     :board_id
      t.datetime :completed_at
      t.datetime :removed_at

      t.integer  :revision, null: false, default: -1
      t.datetime :pending_update_since

      t.timestamps
    end

    add_index :tasks, :board_id
    add_index :tasks, :assignee_id
    add_index :tasks, :status
    add_index :tasks, :removed_at
    add_index :tasks, :pending_update_since,
              where: 'pending_update_since IS NOT NULL',
              name: 'idx_tasks_pending_recovery'
    add_index :tasks, :id,
              unique: true,
              where: 'pending_update_since IS NOT NULL',
              name: 'idx_tasks_one_pending_per_aggregate'
  end
end
