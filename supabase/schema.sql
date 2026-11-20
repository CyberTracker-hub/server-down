-- SERVER DOWN: shared leaderboard for Server Survival, with Solana wallet sign-in.
-- Run this once in the Supabase SQL editor (Dashboard > SQL Editor > New query > Run).
-- Before it is useful: enable the Web3 Wallet provider (Solana) under
-- Authentication > Sign In / Providers, and add the site address under
-- Authentication > URL Configuration > Redirect URLs.

create table if not exists public.scores (
  id          bigint generated always as identity primary key,
  user_id     uuid        not null references auth.users (id) on delete cascade,
  wallet      text        not null check (wallet ~ '^[1-9A-HJ-NP-Za-km-z]{32,44}$'),
  name        text        not null check (name ~ '^[A-Za-z0-9_-]{3,16}$'),
  score       integer     not null check (score between 1 and 50000),
  difficulty  text        not null check (difficulty in ('easy','normal','chaos')),
  character   text        not null check (character in ('error-01','firewall-03','ping','reboot')),
  seconds     integer     not null check (seconds between 1 and 7200),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (user_id, difficulty)            -- one best score per wallet and difficulty
);
create index if not exists scores_board_idx on public.scores (difficulty, score desc, updated_at);

-- Every submission attempt, used only for rate limiting.
create table if not exists public.score_attempts (
  id         bigint generated always as identity primary key,
  user_id    uuid        not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);
create index if not exists score_attempts_idx on public.score_attempts (user_id, created_at);

-- Row Level Security: visitors may read the board and nothing else.
alter table public.scores         enable row level security;
alter table public.score_attempts enable row level security;   -- no policies: closed to the browser

drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores
  for select to anon, authenticated using (true);

revoke all on public.scores, public.score_attempts from anon, authenticated;
grant select (name, wallet, score, difficulty, character, updated_at) on public.scores to anon, authenticated;

-- The only way to add a score. The caller must be signed in with a wallet.
-- The wallet address is read from the verified sign-in, never from the browser.
create or replace function public.submit_score(
  p_name text, p_score integer, p_difficulty text, p_character text, p_seconds integer
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid    uuid := auth.uid();
  v_wallet text;
  v_recent integer;
begin
  if v_uid is null then
    raise exception 'wallet login required';
  end if;

  select coalesce(
           i.identity_data -> 'custom_claims' ->> 'address',
           i.identity_data ->> 'address',
           nullif(split_part(i.provider_id, ':', 3), ''),
           i.provider_id)
    into v_wallet
    from auth.identities i
   where i.user_id = v_uid
   order by i.created_at
   limit 1;

  if v_wallet is null or v_wallet !~ '^[1-9A-HJ-NP-Za-km-z]{32,44}$' then
    raise exception 'wallet login required';
  end if;

  if p_name is null or p_name !~ '^[A-Za-z0-9_-]{3,16}$' then
    raise exception 'invalid name';
  end if;
  if p_score is null or p_seconds is null or p_score < 1 or p_seconds < 1 then
    raise exception 'invalid score';
  end if;
  if p_score > p_seconds * 80 + 100 then
    raise exception 'score not plausible';
  end if;

  select count(*) into v_recent
    from public.score_attempts
   where user_id = v_uid and created_at > now() - interval '10 minutes';
  if v_recent >= 10 then
    raise exception 'rate limit';
  end if;
  insert into public.score_attempts (user_id) values (v_uid);

  insert into public.scores (user_id, wallet, name, score, difficulty, character, seconds)
  values (v_uid, v_wallet, p_name, p_score, p_difficulty, p_character, p_seconds)
  on conflict (user_id, difficulty) do update
     set score = excluded.score, name = excluded.name, character = excluded.character,
         seconds = excluded.seconds, updated_at = now()
   where excluded.score > public.scores.score;
end;
$$;

revoke all on function public.submit_score(text, integer, text, text, integer) from public, anon;
grant execute on function public.submit_score(text, integer, text, text, integer) to authenticated;
