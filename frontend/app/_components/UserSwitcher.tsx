'use client';

import { useTransition } from 'react';
import { switchUserAction } from '@/app/_actions/boards';
import { DEMO_USERS } from '@/lib/users';

export function UserSwitcher({ currentId }: { currentId: string }) {
  const [pending, start] = useTransition();

  return (
    <form className="user-switcher">
      <label htmlFor="user_id">Signed as</label>
      <select
        id="user_id"
        name="user_id"
        defaultValue={currentId}
        disabled={pending}
        onChange={(e) => {
          const fd = new FormData();
          fd.set('user_id', e.currentTarget.value);
          start(() => {
            void switchUserAction(fd);
          });
        }}
      >
        {DEMO_USERS.map((u) => (
          <option key={u.id} value={u.id}>
            {u.name}
          </option>
        ))}
      </select>
    </form>
  );
}
