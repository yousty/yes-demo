import type { Board, CommandBatchResult, CommandRequest, Task } from './types';

const BACKEND_URL = process.env.BACKEND_URL ?? 'http://localhost:3000';

async function authorizedFetch(token: string, path: string, init: RequestInit = {}): Promise<Response> {
  const headers = new Headers(init.headers);
  headers.set('authorization', `Bearer ${token}`);
  headers.set('accept', 'application/json');
  if (init.body && !headers.has('content-type')) {
    headers.set('content-type', 'application/json');
  }
  return fetch(`${BACKEND_URL}${path}`, { ...init, headers, cache: 'no-store' });
}

export type JsonApiDoc<T> = {
  data: Array<{ id: string; type: string; attributes: T }> | { id: string; type: string; attributes: T };
};

function unwrapMany<T>(doc: JsonApiDoc<T>): Array<T & { id: string }> {
  const list = Array.isArray(doc.data) ? doc.data : [doc.data];
  return list.map((entry) => ({ ...entry.attributes, id: entry.id }));
}

export async function listBoards(token: string, memberId?: string): Promise<Board[]> {
  const qs = new URLSearchParams({ 'page[size]': '100' });
  if (memberId) qs.set('filters[member_id]', memberId);
  const res = await authorizedFetch(token, `/v1/queries/boards?${qs.toString()}`);
  if (!res.ok) throw new Error(`listBoards failed: ${res.status}`);
  const doc = (await res.json()) as JsonApiDoc<Omit<Board, 'id'>>;
  return unwrapMany(doc) as Board[];
}

export async function getBoard(token: string, id: string): Promise<Board | null> {
  // Single-board lookup deliberately skips the member_id filter so a non-member
  // can still see the board metadata (and the UI shows a "not a member" banner).
  const res = await authorizedFetch(token, `/v1/queries/boards?filters[ids]=${id}`);
  if (!res.ok) return null;
  const doc = (await res.json()) as JsonApiDoc<Omit<Board, 'id'>>;
  const list = unwrapMany(doc) as Board[];
  return list[0] ?? null;
}

export async function listTasks(token: string, boardId: string): Promise<Task[]> {
  const res = await authorizedFetch(token, `/v1/queries/tasks?filters[board_id]=${boardId}&page[size]=200`);
  if (!res.ok) throw new Error(`listTasks failed: ${res.status}`);
  const doc = (await res.json()) as JsonApiDoc<Omit<Task, 'id'>>;
  return unwrapMany(doc) as Task[];
}

export async function runCommands(token: string, commands: CommandRequest[]): Promise<CommandBatchResult> {
  const res = await authorizedFetch(token, '/v1/commands', {
    method: 'POST',
    body: JSON.stringify({ commands }),
  });
  const body = await res.json().catch(() => ({}));
  return {
    ok: res.ok,
    status: res.status,
    body,
    errors: extractErrors(body),
  };
}

function extractErrors(body: unknown): Array<{ command: string; message: string }> | undefined {
  if (!body || typeof body !== 'object') return undefined;
  const responses = (body as { responses?: unknown }).responses;
  if (!Array.isArray(responses)) return undefined;
  const out: Array<{ command: string; message: string }> = [];
  for (const resp of responses) {
    if (resp && typeof resp === 'object' && 'error' in resp) {
      const r = resp as { command?: string; error?: { message?: string } };
      out.push({ command: r.command ?? 'unknown', message: r.error?.message ?? 'error' });
    }
  }
  return out.length ? out : undefined;
}
