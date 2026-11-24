# SuiteStream Docker stack

**NOT VERIFIED.** These files were written in Sprint 010 without Docker or
Authentik on the machine. Only the Dart server in `../server` is tested (with
fakes: `cd ../server && dart test`). Expect first-run fixes.

## Parts
- `app`: one small image (`../server/Dockerfile`) with the Flutter web build and
  the API, compiled from `../server`.
- `db`: Postgres 16, databases `suitestream` and `authentik` (the second is
  created by `initdb/10-authentik.sql` on first start).
- `authentik`, `authentik_worker`: the identity provider. Redis is not in this
  file: Authentik 2025.10 and later do not need it (from memory, check the
  release notes of the tag you pin; older tags need a redis service).
- `watchtower`: updates only the `app` container (label-enable), only when the
  app calls its HTTP API with the token; no port is published.

## Start
1. `cp .env.example .env`, then replace every `CHANGE_ME` (`openssl rand -hex 32`).
2. `docker compose up -d --build` in this folder.
3. Open Authentik (`http://<host>:9000/if/flow/initial-setup/`) and create the
   first administrator. Create an OAuth2/OpenID provider (confidential) and an
   application with slug `suitestream`; redirect URI `PUBLIC_URL/auth/callback`;
   scopes openid, profile, email. Put its client id, secret and issuer in
   `.env`, then `docker compose up -d` again.
4. Open `PUBLIC_URL` and sign in.

## How sign-in works
`/auth/login` sends the browser to Authentik (authorization code with state and
PKCE). Authentik returns to `/auth/callback`; the server exchanges the code,
reads the user from the userinfo endpoint and sets an HttpOnly session cookie.
Settings are saved per user in Postgres through `/api/settings`. Contract:
`scrum/sprints/sprint010/handoffs.md`, "API contract".

## Not verified
- The Docker build (Flutter image tag `stable` is unpinned; Dart runtime copy).
- Starting the stack, the Authentik tag in `.env.example`, whether Redis is needed.
- Sign-in against a real Authentik (the issuer must be reachable from the app
  container, so `localhost` will not work; use a real host name).
- The Postgres store (no Postgres here), Watchtower's update call and its image.
- Signing out does not end the Authentik session yet (ACC-02.c is partial).
