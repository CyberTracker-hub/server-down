# SERVER DOWN

A satirical digital universe where the internet keeps breaking and a small angry
server robot called ERROR-01 keeps making it worse. Everything on the site is
fiction. No real outages, incidents or systems are shown.

## What is in this repo

| File | What it is |
| --- | --- |
| `index.html` | The whole site: home, game, glitch lab (meme maker) and leaderboard. No build step. |
| `config.js` | Public settings for the shared leaderboard (Supabase URL and anon key). |
| `supabase/schema.sql` | Database tables, access rules and the functions that accept scores, memes and votes. |
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

## How the two boards work

- The site has four pages: Home, Game, Glitch Lab and Leaderboard.
- To post a score, enter a meme or vote, a visitor signs in with a Solana wallet
  (Phantom or Solflare). The wallet signs a text message. No transaction is sent
  and no funds can move. Supabase Auth verifies the signature, and the wallet
  address is read from that verified sign-in, never from the browser.
- Score board: one row per wallet and difficulty. A new score only replaces a
  lower one. Scores that are not possible in the time played are rejected.
- Meme board: a meme is stored as its recipe (texts, character, background,
  seed), not as an image, so nobody can upload an arbitrary picture. Up to 5
  entries per wallet per day. One vote per wallet per meme, no votes on your own
  meme, and voting again removes the vote.
- Visitors can only read the boards. All writes go through `submit_score`,
  `submit_meme` and `vote_meme`.
- Moderation: open the `memes` table in the Supabase table editor and set
  `hidden` to true to take a meme off the board. Delete rows in `scores` to
  remove a score.

## Before you offer prizes

- The game runs in the browser. A determined person can send a made-up score
  that passes the checks. Wallets are free to create, so one person can also
  hold several places or vote many times.
- Do not pay out automatically from the board. Review the top scores by hand,
  state in the rules that suspicious scores are removed, and remove rows in the
  Supabase table editor.
- A board that money depends on needs the game to be validated on a server.
  That is not built.
- Prize competitions have legal rules that differ by country. Check them first.

## Not included

Token data is not built. There is no $DOWN token.
