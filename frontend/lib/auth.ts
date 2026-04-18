import { cookies } from 'next/headers';
import { DEFAULT_USER_ID, DEMO_USERS, userById } from './users';

export const USER_COOKIE = 'taskflow_user_id';

export async function getCurrentUserId(): Promise<string> {
  const store = await cookies();
  const id = store.get(USER_COOKIE)?.value;
  if (id && DEMO_USERS.some((u) => u.id === id)) return id;
  return DEFAULT_USER_ID;
}

export async function getCurrentUser() {
  return userById(await getCurrentUserId());
}

/**
 * Build the Base64-encoded JSON bearer token accepted by the Yes dev auth adapter.
 * Identity = user (demo has no separate identity).
 */
export function buildToken(userId: string): string {
  const payload = JSON.stringify({ identity_id: userId, user_id: userId });
  // Works both in Node (server components) and the browser.
  return Buffer.from(payload, 'utf8').toString('base64');
}
