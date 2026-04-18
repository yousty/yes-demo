'use client';

import { useState, useTransition } from 'react';
import { createBoardAction } from '@/app/_actions/boards';

export function CreateBoardForm() {
  const [pending, start] = useTransition();
  const [error, setError] = useState<string | null>(null);

  return (
    <form
      className="inline-form"
      onSubmit={(e) => {
        e.preventDefault();
        const fd = new FormData(e.currentTarget);
        e.currentTarget.reset();
        start(async () => {
          const res = await createBoardAction(fd);
          setError('error' in res ? res.error ?? null : null);
        });
      }}
    >
      <input name="title" placeholder="Title of the new board" required minLength={1} />
      <input name="description" placeholder="Description (optional)" />
      <button type="submit" disabled={pending}>
        {pending ? 'Filing…' : 'File board'}
      </button>
      {error && <span className="form-error">{error}</span>}
    </form>
  );
}
