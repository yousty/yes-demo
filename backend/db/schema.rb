# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_13_000003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "boards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.uuid "member_ids", default: [], array: true
    t.uuid "owner_id"
    t.datetime "pending_update_since"
    t.datetime "removed_at"
    t.integer "revision", default: -1, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["id"], name: "idx_boards_one_pending_per_aggregate", unique: true, where: "(pending_update_since IS NOT NULL)"
    t.index ["member_ids"], name: "index_boards_on_member_ids", using: :gin
    t.index ["owner_id"], name: "index_boards_on_owner_id"
    t.index ["pending_update_since"], name: "idx_boards_pending_recovery", where: "(pending_update_since IS NOT NULL)"
    t.index ["removed_at"], name: "index_boards_on_removed_at"
  end

  create_table "tasks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assignee_id"
    t.uuid "board_id"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.string "description"
    t.date "due_date"
    t.datetime "pending_update_since"
    t.string "priority"
    t.datetime "removed_at"
    t.integer "revision", default: -1, null: false
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["board_id"], name: "index_tasks_on_board_id"
    t.index ["id"], name: "idx_tasks_one_pending_per_aggregate", unique: true, where: "(pending_update_since IS NOT NULL)"
    t.index ["pending_update_since"], name: "idx_tasks_pending_recovery", where: "(pending_update_since IS NOT NULL)"
    t.index ["removed_at"], name: "index_tasks_on_removed_at"
    t.index ["status"], name: "index_tasks_on_status"
  end
end
