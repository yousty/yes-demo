# frozen_string_literal: true

FactoryBot.define do
  factory :board do
    id { SecureRandom.uuid }
    title { 'Sprint Planning' }
    description { 'Our current sprint' }
    owner_id { SecureRandom.uuid }
    archived { false }
    member_ids { [owner_id] }
  end

  factory :task do
    id { SecureRandom.uuid }
    title { 'Write the spec' }
    status { 'todo' }
    priority { 'medium' }
    association :board
    board_id { board.id }
  end
end
