export type DemoUser = {
  id: string;
  name: string;
  color: string;
};

// Stable UUIDs so switching user is reproducible across sessions.
export const DEMO_USERS: ReadonlyArray<DemoUser> = [
  { id: '11111111-1111-4111-8111-111111111111', name: 'Alice', color: '#ec4899' },
  { id: '22222222-2222-4222-8222-222222222222', name: 'Bob', color: '#3b82f6' },
  { id: '33333333-3333-4333-8333-333333333333', name: 'Carol', color: '#10b981' },
];

export const DEFAULT_USER_ID = DEMO_USERS[0].id;

export function userById(id: string | undefined): DemoUser {
  return DEMO_USERS.find((u) => u.id === id) ?? DEMO_USERS[0];
}
