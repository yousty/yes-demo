'use client';

import { useState, useTransition } from 'react';
import { createTaskAction } from '@/app/_actions/tasks';

export function CreateTaskForm({ boardId }: { boardId: string }) {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  return (
    <form
      className="inline-form"
      onSubmit={(e) => {
        e.preventDefault();
        const fd = new FormData(e.currentTarget);
        fd.set('board_id', boardId);
        e.currentTarget.reset();
        start(async () => {
          const res = await createTaskAction(fd);
          setError('error' in res ? res.error ?? null : null);
        });
      }}
    >
      <input name="title" placeholder="Task headline" required />
      <select name="priority" defaultValue="medium" aria-label="Priority">
        <option value="low">Low</option>
        <option value="medium">Medium</option>
        <option value="high">High</option>
      </select>
      <button type="submit" disabled={pending}>
        {pending ? 'Filing…' : 'File task'}
      </button>
      {error && <span className="form-error">{error}</span>}
    </form>
  );
}
