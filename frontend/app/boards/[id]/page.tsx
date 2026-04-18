import { notFound } from 'next/navigation';
import Link from 'next/link';
import { getBoard, listTasks } from '@/lib/api';
import { buildToken, getCurrentUserId } from '@/lib/auth';
import { DEMO_USERS, userById } from '@/lib/users';
import { CreateTaskForm } from '@/app/_components/CreateTaskForm';
import { TaskCard } from '@/app/_components/TaskCard';
import { BoardSidePanel } from '@/app/_components/BoardSidePanel';
import { shortId } from '@/lib/format';
import type { TaskStatus } from '@/lib/types';

const COLUMNS: Array<{ status: TaskStatus; label: string; roman: string }> = [
  { status: 'todo', label: 'To do', roman: 'Ⅰ' },
  { status: 'in_progress', label: 'In progress', roman: 'Ⅱ' },
  { status: 'done', label: 'Done', roman: 'Ⅲ' },
  { status: 'cancelled', label: 'Cancelled', roman: 'Ⅳ' },
];

export default async function BoardPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const identityId = await getCurrentUserId();
  const token = buildToken(identityId);

  const board = await getBoard(token, id);
  if (!board) notFound();

  const tasks = await listTasks(token, id).catch(() => []);
  const owner = userById(board.owner_id);
  const boardMembers = DEMO_USERS.filter((u) => board.member_ids.includes(u.id));
  const isMember = board.member_ids.includes(identityId);

  return (
    <section>
      <div className="toolbar">
        <div>
          <Link href="/" className="backlink">
            Folio Index
          </Link>
          <p className="eyebrow">Stream · № {shortId(board.id)}</p>
          <h1 className="display">
            {board.title}
            {board.archived && (
              <span className="stamp stamp--archive" style={{ marginLeft: 16, verticalAlign: 'middle' }}>
                Archived
              </span>
            )}
          </h1>
          <p className="lede">
            {board.description || 'Without description.'} Curated by{' '}
            <span className="byline" style={{ display: 'inline-flex' }}>
              <span
                className="seal"
                style={{ ['--seal' as string]: owner.color } as React.CSSProperties}
                aria-hidden
              />
              {owner.name}
            </span>
            .
          </p>
        </div>
        {isMember && !board.archived && <CreateTaskForm boardId={board.id} />}
      </div>

      <div className="rule rule--double" style={{ marginTop: 36 }} />

      {!isMember && (
        <div className="notice" role="note">
          <span className="notice__label">Restricted</span>
          <span>
            You are not a signatory of this board. Task creation and edits are disabled — ask the
            owner to add you, or switch to a member from the masthead.
          </span>
        </div>
      )}

      <div className="ledger" style={{ marginTop: 24 }}>
        <div className="ledger__board">
          <ol className="columns" aria-label="Task streams">
            {COLUMNS.map(({ status, label, roman }) => {
              const columnTasks = tasks.filter((t) => t.status === status);
              return (
                <li key={status} className="column">
                  <header className="column__head">
                    <span className="column__roman">{roman}</span>
                    <h3 className="column__title">{label}</h3>
                    <span className="column__count">{columnTasks.length}</span>
                  </header>
                  <ul className="column__body">
                    {columnTasks.map((task) => (
                      <li key={task.id}>
                        <TaskCard task={task} boardMembers={boardMembers} />
                      </li>
                    ))}
                  </ul>
                </li>
              );
            })}
          </ol>
        </div>
        <BoardSidePanel board={board} currentUserId={identityId} />
      </div>
    </section>
  );
}
