'use server';

import { revalidatePath } from 'next/cache';
import { cookies } from 'next/headers';
import { buildToken, getCurrentUserId, USER_COOKIE } from '@/lib/auth';
import { runCommands } from '@/lib/api';
import { DEMO_USERS } from '@/lib/users';

const CONTEXT = 'TaskFlow';
const SUBJECT = 'Board';

export async function switchUserAction(formData: FormData): Promise<void> {
  const id = String(formData.get('user_id') ?? '');
  if (!DEMO_USERS.some((u) => u.id === id)) return;
  const store = await cookies();
  store.set(USER_COOKIE, id, { path: '/', httpOnly: false, sameSite: 'lax' });
  revalidatePath('/', 'layout');
}

export async function createBoardAction(formData: FormData) {
  const token = buildToken(await getCurrentUserId());
  const title = String(formData.get('title') ?? '').trim();
  const description = String(formData.get('description') ?? '').trim() || null;
  if (!title) return { error: 'Title is required' };

  const boardId = crypto.randomUUID();
  const result = await runCommands(token, [
    {
      context: CONTEXT,
      subject: SUBJECT,
      command: 'CreateBoard',
      data: { board_id: boardId, title, description, owner_id: await getCurrentUserId() },
    },
  ]);
  revalidatePath('/');
  return result.ok && !result.errors?.length
    ? { ok: true, boardId }
    : { error: result.errors?.[0]?.message ?? `Command failed (${result.status})` };
}

async function sendBoardCommand(command: string, boardId: string, extraData: Record<string, unknown> = {}) {
  const token = buildToken(await getCurrentUserId());
  const result = await runCommands(token, [
    {
      context: CONTEXT,
      subject: SUBJECT,
      command,
      data: { board_id: boardId, ...extraData },
    },
  ]);
  revalidatePath(`/boards/${boardId}`);
  revalidatePath('/');
  return result.ok && !result.errors?.length
    ? { ok: true }
    : { error: result.errors?.[0]?.message ?? `Command failed (${result.status})` };
}

export async function changeBoardTitleAction(formData: FormData) {
  return sendBoardCommand('ChangeTitle', String(formData.get('board_id')), {
    title: String(formData.get('title') ?? ''),
  });
}

export async function archiveBoardAction(formData: FormData) {
  return sendBoardCommand('Archive', String(formData.get('board_id')));
}

export async function unarchiveBoardAction(formData: FormData) {
  return sendBoardCommand('Unarchive', String(formData.get('board_id')));
}

export async function addMemberAction(formData: FormData) {
  return sendBoardCommand('AddMember', String(formData.get('board_id')), {
    member_id: String(formData.get('member_id')),
  });
}

export async function removeMemberAction(formData: FormData) {
  return sendBoardCommand('RemoveMember', String(formData.get('board_id')), {
    member_id: String(formData.get('member_id')),
  });
}

export async function transferOwnershipAction(formData: FormData) {
  return sendBoardCommand('TransferOwnership', String(formData.get('board_id')), {
    new_owner_id: String(formData.get('new_owner_id')),
  });
}
