# frozen_string_literal: true

# Register custom Yes attribute types used by TaskFlow aggregates.
Yes::Core::Types.register(
  :task_status,
  Yes::Core::Types::String.enum('todo', 'in_progress', 'done', 'cancelled')
)

Yes::Core::Types.register(
  :task_priority,
  Yes::Core::Types::String.enum('low', 'medium', 'high')
)

# yes-core ships `:date_value` (a formatted date string). For this demo we
# alias `:date` to the same underlying type so aggregate definitions read naturally.
Yes::Core::Types.register(:date, Yes::Core::Types::DateValue)
