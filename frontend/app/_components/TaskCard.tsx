'use client';

import { useTransition } from 'react';
import {
  assignTaskAction,
  cancelTaskAction,
  completeTaskAction,
  removeTaskAction,
  reopenTaskAction,
  startTaskAction,
  unassignTaskAction,
} from '@/app/_actions/tasks';
import type { Task } from '@/lib/types';
import type { DemoUser } from '@/lib/users';
import { shortId } from '@/lib/format';

type Props = { task: Task; boardMembers: DemoUser[] };

export function TaskCard({ task, boardMembers }: Props) {
  const [pending, start] = useTransition();
  const assignee = boardMembers.find((m) => m.id === task.assignee_id);

  const run = (
    action: (fd: FormData) => Promise<{ ok?: boolean; error?: string }>,
    extra?: Record<string, string>,
  ) => {
    const fd = new FormData();
    fd.set('task_id', task.id);
    fd.set('board_id', task.board_id);
    Object.entries(extra ?? {}).forEach(([k, v]) => fd.set(k, v));
    start(() => {
      void action(fd);
    });
  };

  return (
    <article className="dispatch" data-status={task.status} data-priority={task.priority}>
      <div className="dispatch__head">
        <span className="dispatch__num">№ {shortId(task.id)}</span>
        <span className={`priority priority--${task.priority}`}>{task.priority}</span>
      </div>
      <h4 className="dispatch__title">{task.title}</h4>

      <dl className="dispatch__meta">
        <div>
          <dt>Assignee</dt>
          <dd className={assignee ? '' : 'muted'}>
            {assignee ? (
              <>
                <span
                  className="seal"
                  style={{ ['--seal' as string]: assignee.color } as React.CSSProperties}
                  aria-hidden
                />
                {assignee.name}
              </>
            ) : (
              'Unassigned'
            )}
          </dd>
        </div>
        {task.due_date && (
          <div>
            <dt>Due</dt>
            <dd>{task.due_date}</dd>
          </div>
        )}
      </dl>

      <footer className="dispatch__actions">
        <div className="dispatch__actions-row">
          {task.status === 'todo' && (
            <button className="secondary" disabled={pending} onClick={() => run(startTaskAction)}>
              Start
            </button>
          )}
          {task.status === 'in_progress' && (
            <button disabled={pending} onClick={() => run(completeTaskAction)}>
              Complete
            </button>
          )}
          {task.status === 'done' && (
            <button className="secondary" disabled={pending} onClick={() => run(reopenTaskAction)}>
              Reopen
            </button>
          )}
          {task.status !== 'done' && task.status !== 'cancelled' && (
            <button className="secondary" disabled={pending} onClick={() => run(cancelTaskAction)}>
              Cancel
            </button>
          )}
        </div>

        <div className="dispatch__actions-row">
          {task.assignee_id ? (
            <button className="secondary" disabled={pending} onClick={() => run(unassignTaskAction)}>
              Unassign
            </button>
          ) : (
            <select
              aria-label="Assign task"
              defaultValue=""
              onChange={(e) => {
                if (e.target.value) run(assignTaskAction, { assignee_id: e.target.value });
              }}
            >
              <option value="">Assign to…</option>
              {boardMembers.map((m) => (
                <option key={m.id} value={m.id}>
                  {m.name}
                </option>
              ))}
            </select>
          )}
          <button className="danger" disabled={pending} onClick={() => run(removeTaskAction)}>
            Delete
          </button>
        </div>
      </footer>
    </article>
  );
}
