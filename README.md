# SERVER DOWN

A satirical digital universe where the internet keeps breaking and a small angry
server robot called ERROR-01 keeps making it worse. Everything on the site is
fiction. No real outages, incidents or systems are shown.

## What is in this repo

| File | What it is |
| --- | --- |
| `index.html` | The whole site: home, dashboard, 20 characters, terminal, meme lab, game, archives, token page. No build step. |
| `config.js` | Public settings for the shared leaderboard (Supabase URL and anon key). |
| `supabase/schema.sql` | Database table, access rules and the `submit_score` function. |
| `.nojekyll` | Tells GitHub Pages to serve the files as they are. |

## Run it locally

Open `index.html` in a browser. Everything works except the shared leaderboard,
which needs the two values in `config.js`.

## Set up the backend (Supabase, free tier)

1. Create a project at https://supabase.com.
2. Open **SQL Editor**, paste the contents of `supabase/schema.sql`, press **Run**.
3. Open **Authentication > Sign In / Providers** and enable **Web3 Wallet** with Solana.
4. Open **Authentication > URL Configuration**. Set **Site URL** to the address of the
   live site and add the same address with `/**` at the end under **Redirect URLs**,
   for example `https://<user>.github.io/<repo>/**`. Wallet sign-in is refused from
   any address that is not listed.
5. Open **Project Settings > API**. Copy the **Project URL** and the **anon public** key
   into `config.js`.

Never put the `service_role` key in this repo. The site does not need it.

## Publish on GitHub Pages

1. Create a new public repository on GitHub and upload all files in this folder.
2. Open **Settings > Pages**. Under **Build and deployment** choose
   **Deploy from a branch**, branch `main`, folder `/ (root)`. Save.
3. After a minute the site is live at `https://<user>.github.io/<repo>/`.

## How the leaderboard works

- To post a score a visitor signs in with a Solana wallet (Phantom or Solflare).
  The wallet signs a text message. No transaction is sent and no funds can move.
- Supabase Auth verifies the signature. The wallet address stored with a score is
  read from that verified sign-in, never from the browser.
- One row per wallet and difficulty: a new score only replaces a lower one.
- Visitors can read `name, wallet, score, difficulty, character, updated_at` and
  nothing else. They cannot insert, update or delete rows directly.
- `submit_score` checks the name format and rejects scores that are not possible
  in the time played. Each wallet is limited to 10 submissions per 10 minutes.

## Before you offer prizes

- The game runs in the browser. A determined person can send a made-up score
  that passes the checks. Wallets are free to create, so one person can also
  hold several places.
- Do not pay out automatically from the board. Review the top scores by hand,
  state in the rules that suspicious scores are removed, and remove rows in the
  Supabase table editor.
- A board that money depends on needs the game to be validated on a server.
  That is not built.
- Prize competitions have legal rules that differ by country. Check them first.

## Not included

Wallet connect, token data and user accounts are not built. There is no $DOWN
token. See the Token page on the site.
