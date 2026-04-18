export type TaskStatus = 'todo' | 'in_progress' | 'done' | 'cancelled';
export type TaskPriority = 'low' | 'medium' | 'high';

export type Board = {
  id: string;
  title: string;
  description: string | null;
  owner_id: string;
  archived: boolean;
  member_ids: string[];
  removed: boolean;
  created_at: string;
  updated_at: string;
};

export type Task = {
  id: string;
  title: string;
  description: string | null;
  status: TaskStatus;
  priority: TaskPriority;
  due_date: string | null;
  assignee_id: string | null;
  board_id: string;
  completed_at: string | null;
  removed: boolean;
  created_at: string;
  updated_at: string;
};

export type CommandRequest = {
  context: string;
  subject: string;
  command: string;
  data: Record<string, unknown>;
  metadata?: Record<string, unknown>;
};

export type CommandBatchResult = {
  ok: boolean;
  status: number;
  body: unknown;
  errors?: Array<{ command: string; message: string }>;
};
