'use server';

import { revalidatePath } from 'next/cache';
import { buildToken, getCurrentUserId } from '@/lib/auth';
import { runCommands } from '@/lib/api';

const CONTEXT = 'TaskFlow';
const SUBJECT = 'Task';

async function sendTaskCommand(
  command: string,
  taskId: string,
  extraData: Record<string, unknown> = {},
  boardId?: string,
) {
  const token = buildToken(await getCurrentUserId());
  const result = await runCommands(token, [
    {
      context: CONTEXT,
      subject: SUBJECT,
      command,
      data: { task_id: taskId, ...extraData },
    },
  ]);
  if (boardId) revalidatePath(`/boards/${boardId}`);
  return result.ok && !result.errors?.length
    ? { ok: true }
    : { error: result.errors?.[0]?.message ?? `Command failed (${result.status})` };
}

export async function createTaskAction(formData: FormData) {
  const token = buildToken(await getCurrentUserId());
  const title = String(formData.get('title') ?? '').trim();
  const boardId = String(formData.get('board_id') ?? '');
  const priority = String(formData.get('priority') ?? 'medium');
  if (!title || !boardId) return { error: 'Title and board_id are required' };

  const taskId = crypto.randomUUID();
  const result = await runCommands(token, [
    {
      context: CONTEXT,
      subject: SUBJECT,
      command: 'CreateTask',
      data: { task_id: taskId, board_id: boardId, title, priority },
    },
  ]);
  revalidatePath(`/boards/${boardId}`);
  return result.ok && !result.errors?.length
    ? { ok: true, taskId }
    : { error: result.errors?.[0]?.message ?? `Command failed (${result.status})` };
}

export async function startTaskAction(formData: FormData) {
  return sendTaskCommand('Start', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}

export async function completeTaskAction(formData: FormData) {
  return sendTaskCommand('Complete', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}

export async function reopenTaskAction(formData: FormData) {
  return sendTaskCommand('Reopen', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}

export async function cancelTaskAction(formData: FormData) {
  return sendTaskCommand('Cancel', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}

export async function changeTaskPriorityAction(formData: FormData) {
  return sendTaskCommand(
    'ChangePriority',
    String(formData.get('task_id')),
    { priority: String(formData.get('priority')) },
    String(formData.get('board_id')),
  );
}

export async function assignTaskAction(formData: FormData) {
  return sendTaskCommand(
    'AssignToMember',
    String(formData.get('task_id')),
    { assignee_id: String(formData.get('assignee_id')) },
    String(formData.get('board_id')),
  );
}

export async function unassignTaskAction(formData: FormData) {
  return sendTaskCommand('Unassign', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}

export async function removeTaskAction(formData: FormData) {
  return sendTaskCommand('Remove', String(formData.get('task_id')), {}, String(formData.get('board_id')));
}
