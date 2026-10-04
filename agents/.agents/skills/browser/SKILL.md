---
name: Shared Browser (agents Chrome)
description: Browser automation via the shared agents Chrome (CDP :9222). Use for ANY browser task on machines where it is set up — attach instead of launching throwaway browsers. Also use when a plain web fetch of a page returns a captcha, bot check, or access-denied page — a real browser with real cookies gets through. Companion to the playwright-cli skill, which owns command syntax.
---

# Shared Browser: agents Chrome

Shared instance: **agents Chrome** — headed, CDP port `9222`, profile `~/.local/share/chrome-agents` (all logins live here). Binary: `google-chrome-stable` on Linux, `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` on macOS.

## Rules

1. `playwright-cli list` and `curl -s --max-time 2 http://localhost:9222/json/version` before anything.
2. A usable session already exists → work in it; never `open` again.
3. Chrome down → bring it up, wait for the port:
   ```sh
   nohup google-chrome-stable --remote-debugging-port=9222 --no-first-run --no-default-browser-check --user-data-dir="$HOME/.local/share/chrome-agents" >/dev/null 2>&1 &
   for i in $(seq 30); do curl -s --max-time 2 http://localhost:9222/json/version >/dev/null && break; sleep 1; done
   ```
4. Attach with a task-named session — never the `default` session, other agents may be using it:
   ```sh
   playwright-cli -s=<task> attach --cdp=http://localhost:9222
   ```
5. First act after attach: `tab-list`, then `tab-new` for your own tab unless the task targets an existing one. Never assume which tab you're on — other agents share this tab strip, and commands aimed at the same tab interleave (races).
6. Site demands login and the session isn't authenticated → the profile lacks cookies. Ask the user to log in manually in the agents Chrome window (it's headed); do not automate the login.
7. Before detaching: `tab-close` your scratch tabs (detached tabs linger in the shared browser).
8. Done → `detach` (leaves Chrome running). **Never** `close`, `close-all`, or `kill-all` — they can kill the shared instance and everyone's session with it.

## Escape hatch (isolation)

When you need a clean context — logins NOT shared with agents Chrome, one-off scraping, parallel isolation — spawn an isolated headless browser with its own profile (headless is the default for `open`):

```sh
playwright-cli -s=<task>-iso open --browser=chrome --profile="$HOME/.local/share/chrome-profiles/<task>"
```

Prefer the shared Chrome; use this only when isolation is actually required.
