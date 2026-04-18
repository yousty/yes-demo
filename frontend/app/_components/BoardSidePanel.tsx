'use client';

import { useTransition } from 'react';
import {
  addMemberAction,
  archiveBoardAction,
  removeMemberAction,
  transferOwnershipAction,
  unarchiveBoardAction,
} from '@/app/_actions/boards';
import type { Board } from '@/lib/types';
import { DEMO_USERS, type DemoUser } from '@/lib/users';

type Props = { board: Board; currentUserId: string };

export function BoardSidePanel({ board, currentUserId }: Props) {
  const [pending, start] = useTransition();
  const isOwner = currentUserId === board.owner_id;

  const run = (action: (fd: FormData) => Promise<unknown>, extra?: Record<string, string>) => {
    const fd = new FormData();
    fd.set('board_id', board.id);
    Object.entries(extra ?? {}).forEach(([k, v]) => fd.set(k, v));
    start(() => {
      void action(fd);
    });
  };

  const memberUsers: DemoUser[] = board.member_ids
    .map((id) => DEMO_USERS.find((u) => u.id === id))
    .filter((x): x is DemoUser => Boolean(x));

  const candidates = DEMO_USERS.filter((u) => !board.member_ids.includes(u.id));

  return (
    <aside className="register">
      <section className="register__block">
        <p className="eyebrow eyebrow--plain">Members of Record</p>
        <h2 className="register__title">Signatories</h2>
        <ol className="register__list">
          {memberUsers.map((m) => {
            const ownerBadge = m.id === board.owner_id;
            const canAct = isOwner && !ownerBadge;
            return (
              <li key={m.id}>
                <span
                  className="seal seal--lg"
                  style={{ ['--seal' as string]: m.color } as React.CSSProperties}
                  aria-hidden
                />
                <span className="register__name">{m.name}</span>
                {ownerBadge && <span className="stamp stamp--owner">Owner</span>}
                {canAct && (
                  <div className="register__actions">
                    <button
                      className="secondary"
                      disabled={pending}
                      onClick={() => run(removeMemberAction, { member_id: m.id })}
                    >
                      Remove
                    </button>
                    <button
                      className="secondary"
                      disabled={pending}
                      onClick={() => run(transferOwnershipAction, { new_owner_id: m.id })}
                    >
                      Transfer
                    </button>
                  </div>
                )}
              </li>
            );
          })}
        </ol>

        {candidates.length > 0 && (
          <div className="register__add">
            <select
              aria-label="Add member"
              defaultValue=""
              onChange={(e) => {
                if (e.target.value) run(addMemberAction, { member_id: e.target.value });
              }}
            >
              <option value="">Add member…</option>
              {candidates.map((u) => (
                <option key={u.id} value={u.id}>
                  {u.name}
                </option>
              ))}
            </select>
          </div>
        )}
      </section>

      {isOwner && (
        <section className="register__block register__block--danger">
          <p className="eyebrow eyebrow--plain">Owner Only</p>
          <h2 className="register__title">Classified</h2>
          <p className="register__note">
            Archival removes this board from circulation but preserves its event stream. The operation
            is fully reversible.
          </p>
          {board.archived ? (
            <button className="secondary" disabled={pending} onClick={() => run(unarchiveBoardAction)}>
              Restore from archive
            </button>
          ) : (
            <button className="danger" disabled={pending} onClick={() => run(archiveBoardAction)}>
              Archive board
            </button>
          )}
        </section>
      )}
    </aside>
  );
}
