import type { Metadata } from 'next';
import Link from 'next/link';
import { UserSwitcher } from './_components/UserSwitcher';
import { getCurrentUserId } from '@/lib/auth';
import { userById } from '@/lib/users';
import './globals.css';

export const metadata: Metadata = {
  title: 'TaskFlow — An Event-Sourced Ledger',
  description: 'A yes event-sourcing demo',
};

const DATELINE_FMT: Intl.DateTimeFormatOptions = {
  weekday: 'long',
  day: '2-digit',
  month: 'long',
  year: 'numeric',
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const currentId = await getCurrentUserId();
  const currentUser = userById(currentId);
  const adminUrl = (process.env.NEXT_PUBLIC_BACKEND_URL ?? 'http://localhost:3100') + '/admin/eventstore/';
  const dateline = new Date().toLocaleDateString('en-GB', DATELINE_FMT);

  return (
    <html lang="en">
      <body>
        <header className="masthead">
          <div className="masthead__inner">
            <Link href="/" className="masthead__brand" aria-label="TaskFlow — home">
              <span className="masthead__imprint">Event Ledger · Vol. 01</span>
              <span className="masthead__title">
                Task<span className="masthead__amp">&amp;</span>Flow
              </span>
            </Link>
            <div className="masthead__meta">
              <a className="masthead__link" href={adminUrl} target="_blank" rel="noreferrer">
                <span>Eventstore Admin</span>
                <span aria-hidden>↗</span>
              </a>
              <div className="masthead__divider" aria-hidden />
              <div className="masthead__user">
                <span
                  className="seal"
                  style={{ ['--seal' as string]: currentUser.color } as React.CSSProperties}
                  aria-hidden
                />
                <UserSwitcher currentId={currentId} />
              </div>
            </div>
          </div>
          <div className="masthead__dateline">
            <span>Folio · Ⅰ</span>
            <span>{dateline}</span>
            <span>Rails 8.1 · Next 16 · pg_eventstore</span>
          </div>
        </header>
        <main className="shell">{children}</main>
      </body>
    </html>
  );
}
