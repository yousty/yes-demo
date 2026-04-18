import Link from 'next/link';
import { listBoards } from '@/lib/api';
import { buildToken, getCurrentUserId } from '@/lib/auth';
import { CreateBoardForm } from './_components/CreateBoardForm';
import { userById } from '@/lib/users';
import { shortId } from '@/lib/format';

export default async function BoardsPage() {
  const identityId = await getCurrentUserId();
  const token = buildToken(identityId);
  const boards = await listBoards(token, identityId).catch(() => []);

  return (
    <section>
      <div className="toolbar">
        <div>
          <p className="eyebrow">Folio · I · Boards in Circulation</p>
          <h1 className="display">
            Your <em>boards</em>
          </h1>
          <p className="lede">
            Every board is a stream of commands and events. Open one to read its ledger, or file a new
            one below.
          </p>
        </div>
        <CreateBoardForm />
      </div>

      <div className="rule rule--double" style={{ marginTop: 36 }} />

      {boards.length === 0 ? (
        <div className="empty">
          <p className="empty__mark">¶</p>
          <p className="empty__text">
            No boards have been filed under your name yet. Begin with the form above — a new stream
            awaits.
          </p>
        </div>
      ) : (
        <ol className="dossier-grid">
          {boards.map((board, idx) => {
            const owner = userById(board.owner_id);
            return (
              <li key={board.id} style={{ ['--i' as string]: idx } as React.CSSProperties}>
                <Link href={`/boards/${board.id}`} className={`dossier${board.archived ? ' archived' : ''}`}>
                  <div className="dossier__hd">
                    <span className="dossier__num">№ {shortId(board.id)}</span>
                    {board.archived && <span className="stamp stamp--archive">Archived</span>}
                  </div>
                  <h3 className="dossier__title">{board.title}</h3>
                  <p className="dossier__desc">
                    {board.description || <span style={{ color: 'var(--ink-faint)' }}>Without description.</span>}
                  </p>
                  <div className="dossier__ft">
                    <span className="byline">
                      <span
                        className="seal"
                        style={{ ['--seal' as string]: owner.color } as React.CSSProperties}
                        aria-hidden
                      />
                      {owner.name}
                    </span>
                    <span className="chip">
                      {board.member_ids.length} {board.member_ids.length === 1 ? 'member' : 'members'}
                    </span>
                  </div>
                </Link>
              </li>
            );
          })}
        </ol>
      )}
    </section>
  );
}
