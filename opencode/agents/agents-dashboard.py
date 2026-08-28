#!/usr/bin/env python3
"""Two-pane TUI (Textual) for spawned opencode agents.

Left pane:  all headless agents, arrow keys / mouse to select.
Right pane: live headless output of the selected agent (scrollable,
            follows the tail unless you scroll up), or its completion
            summary rendered as markdown.

    Dashboard keys: up/down select · space multi-select · b broadcast
      i info · e session · d diff · a take over · r resume · s stop
      R reload · q quit

Theme: catppuccin-macchiato by default (OPENCODE_DASHBOARD_THEME overrides).

Theme: catppuccin-frappé by default (OPENCODE_DASHBOARD_THEME overrides).

Self-bootstraps a venv (.opencode-agents/.venv) with textual on first run.
Env overrides: OPENCODE_AGENTS_DIR, OPENCODE_AGENTS_WT, OPENCODE_AGENTS_LOCK.
"""
import glob
import hashlib
import os
import re
import shutil
import socket
import subprocess
import sys
import time

from rich.text import Text

ROOT = subprocess.run(
    ["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True
).stdout.strip()
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.environ.get("OPENCODE_AGENTS_DIR", os.path.join(ROOT, ".opencode-agents"))
WORKTREES = os.environ.get(
    "OPENCODE_AGENTS_WT", os.path.join(os.path.dirname(ROOT), "headstad-agents")
)
TASK_DIR = os.path.join(DATA_DIR, "tasks")
REPORT_DIR = os.path.join(DATA_DIR, "reports")
STALL_SECS = 180
POLL_SECS = 1.5

STATE_STYLE = {
    "RUNNING": "#a6da95",          # catppuccin macchiato green
    "RETRYING": "#c6a0f6",         # mauve
    "STALLED": "#eed49f",          # yellow
    "DEAD": "#ed8796",             # red
    "STOPPED": "dim #ed8796",
    "DONE": "bold #a6da95",
}


def resolve_session(name):
    """Return the agent's opencode session id ('' if unresolvable)."""
    try:
        r = subprocess.run([f"{SCRIPT_DIR}/agent-session.sh", name],
                           capture_output=True, text=True, timeout=60)
        return r.stdout.strip()
    except subprocess.TimeoutExpired:
        return ""


def fetch_transcript(port, sid, max_bytes=200000):
    """Fetch a session transcript from the server as markdown."""
    import json
    import urllib.request
    with urllib.request.urlopen(
            f"http://localhost:{port}/session/{sid}/message", timeout=20) as resp:
        msgs = json.load(resp)
    chunks = []
    for msg in msgs:
        info = msg.get("info") or msg
        role = info.get("role")
        if role not in ("user", "assistant"):
            continue
        text = " ".join(
            p.get("text", "") for p in msg.get("parts", [])
            if isinstance(p, dict) and p.get("type") == "text").strip()
        if text:
            chunks.append(f"### {role}\n\n{text}")
    md = "\n\n---\n\n".join(chunks) if chunks else "*no messages yet*"
    return md[-max_bytes:]


DIFF_LINE_STYLES = (
    ("diff --git", "bold #cad3f5"),
    ("+++ ", "bold #a6da95"),
    ("--- ", "bold #ed8796"),
    ("@@", "bold #85c1dc"),
    ("index ", "dim italic"),
    ("new file mode", "dim italic"),
    ("deleted file mode", "dim italic"),
    ("old mode", "dim italic"),
    ("new mode", "dim italic"),
    ("similarity index", "dim italic"),
    ("rename from", "dim italic"),
    ("rename to", "dim italic"),
    ("Binary files", "dim italic"),
)


def _diff_style(line):
    """Style for one unified-diff line (macchiato-tinted, delta-like)."""
    for prefix, style in DIFF_LINE_STYLES:
        if line.startswith(prefix):
            return style
    if line.startswith("+"):
        return "#a6da95 on #26332b"          # added: green tint
    if line.startswith("-"):
        return "#ed8796 on #38262c"          # removed: red tint
    return ""


def branch_diff(name, max_bytes=120000):
    """Whole-branch diff vs merge-base for both repos, as styled Text."""
    wt = os.path.join(WORKTREES, name)
    nx = os.path.join(wt, "packages", "nexura")
    nx_main = os.path.join(ROOT, "packages", "nexura")

    def git(path, *args):
        try:
            r = subprocess.run(["git", "-C", path, *args],
                               capture_output=True, text=True, timeout=30)
            return r.stdout
        except (OSError, subprocess.TimeoutExpired):
            return ""

    def resolve_base(path, candidates, fork_repo=None):
        """Find a usable base rev; submodules usually lack test refs, so
        fall back to the fork tip recorded in the main clone."""
        for c in candidates:
            if git(path, "rev-parse", "-q", "--verify", c).strip():
                return c
        if fork_repo:
            fork = git(fork_repo, "rev-parse", "-q", "--verify",
                       f"feature/{name}").strip()
            if fork and git(path, "merge-base", fork, "HEAD").strip():
                return fork
        return ""

    out = Text()
    wrote = False
    budget = max_bytes
    repos = (("headstad", wt, ("origin/test", "test"), None),
             ("nexura", nx, ("test", "origin/test"), nx_main))
    for label, path, candidates, fork_repo in repos:
        if not os.path.isdir(path) or budget <= 200:
            continue
        base = resolve_base(path, candidates, fork_repo)
        stat = git(path, "diff", "--stat", base).strip() if base else ""
        patch = git(path, "diff", base).rstrip("\n") if base else ""
        dirty = len(git(path, "status", "--short").splitlines())
        if base and not stat and not patch:
            continue
        if wrote:
            out.append("\n\n" + "─" * 40 + "\n\n", style="dim")
        out.append(f"■ {label} — feature/{name}\n", style="bold #b8c0e0")
        if not base:
            out.append("(base ref not found — uncommitted changes only)\n",
                       style="dim italic")
            if dirty:
                patch = git(path, "diff", "HEAD").rstrip("\n")
                stat = git(path, "diff", "--stat", "HEAD").strip()
        out.append((stat or "(no committed changes)") + "\n", style="dim")
        limit = max(0, budget - len(stat) - 100)
        truncated = False
        if len(patch) > limit:
            patch = patch[:limit].rsplit("\n", 1)[0]
            truncated = True
        for ln in patch.splitlines():
            out.append(ln + "\n", style=_diff_style(ln))
        if truncated:
            out.append("… diff truncated …\n", style="dim italic")
        budget -= len(stat) + len(patch)
        wrote = True
    if not wrote:
        out.append("no branch changes yet", style="dim italic")
    return out


def send_user_message(name, sid, text):
    """POST a user message to the session. Returns (ok, error)."""
    import json
    import urllib.request
    s = agent_state(name)
    body = json.dumps({"parts": [{"type": "text", "text": text}]}).encode()
    req = urllib.request.Request(
        f"http://localhost:{s['port']}/session/{sid}/message",
        data=body, headers={"content-type": "application/json"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=20) as resp:
            resp.read()
        return True, None
    except Exception as e:
        return False, str(e)


def run(cmd, cwd=None):
    return subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, timeout=5).stdout.strip()


def names():
    return sorted(
        os.path.basename(t).removesuffix(".md") for t in glob.glob(os.path.join(TASK_DIR, "*.md"))
    )


def alive(port):
    try:
        socket.create_connection(("localhost", int(port)), timeout=1).close()
        return True
    except (OSError, ValueError):
        return False


def agent_state(name):
    wt = os.path.join(WORKTREES, name)
    nx = os.path.join(wt, "packages", "nexura")
    task_file = os.path.join(TASK_DIR, f"{name}.md")

    try:
        task_text = open(task_file).read()
    except OSError:
        task_text = ""
    m = re.search(r"Status:\s*(\S+)", task_text)
    status = m.group(1) if m else "unknown"

    pid, model = None, None
    ps = subprocess.Popen(["ps", "-eo", "pid,args"], stdout=subprocess.PIPE, text=True)
    for line in ps.stdout:
        if "opencode" in line and f"tasks/{name}.md" in line and "bash -c" not in line[:20]:
            pid = int(line.split(None, 1)[0])
            mm = re.search(r"-m opencode/(\S+)", line)
            model = mm.group(1) if mm else "default"
            break
    ps.stdout.close()
    ps.wait(timeout=2)

    def facts(path, base):
        if not os.path.exists(path) or not run(["git", "rev-parse", "--git-dir"], cwd=path):
            return "-", 0, 0
        branch = run(["git", "branch", "--show-current"], cwd=path)
        dirty = len(run(["git", "status", "--short"], cwd=path).splitlines())
        commits = len(run(["git", "log", "--oneline", f"{base}..HEAD"], cwd=path).splitlines())
        return branch or "-", dirty, commits

    branch, dirty, commits = facts(wt, "origin/test")
    nx_branch, nx_dirty, nx_commits = facts(nx, "test")

    mtimes = []
    report = os.path.join(REPORT_DIR, f"{name}.md")
    if os.path.exists(report):
        mtimes.append(os.path.getmtime(report))
    dlog = os.path.join(REPORT_DIR, f"{name}.driver.log")
    if os.path.exists(dlog):
        mtimes.append(os.path.getmtime(dlog))
    idle_secs = time.time() - max(mtimes) if mtimes else None

    if status == "completed":
        state = "DONE"
    elif status == "stopped":
        state = "STOPPED"
    elif pid:
        if idle_secs is not None and idle_secs < STALL_SECS:
            state = "RUNNING"
        else:
            retrying = False
            if os.path.exists(dlog):
                try:
                    retrying = time.time() - os.path.getmtime(dlog) < STALL_SECS
                except OSError:
                    pass
            state = "RETRYING" if retrying else "STALLED"
    else:
        state = "DEAD"

    pct, step = 0, "queued"
    if os.path.isdir(wt):
        pct, step = 15, "setup"
    if dirty + nx_dirty > 0:
        pct, step = max(pct, 45), "building"
    if commits + nx_commits > 0:
        pct, step = max(pct, 75), "review/verify"
    if status == "completed":
        pct, step = 100, "done"

    last = ""
    if os.path.exists(report):
        lines = [l for l in open(report).read().splitlines() if l.strip()]
        last = lines[-1][:90] if lines else ""

    idle_str = f"{int(idle_secs // 60)}m" if idle_secs is not None else "?"
    port = ""
    pf = os.path.join(DATA_DIR, f"{name}.port")
    if os.path.exists(pf):
        port = open(pf).read().strip()

    preview_port = ""
    ppf = os.path.join(DATA_DIR, f"{name}.preview-port")
    if os.path.exists(ppf):
        preview_port = open(ppf).read().strip()

    return {
        "state": state, "pid": pid, "model": model, "idle": idle_str,
        "pct": pct, "step": step, "branch": branch, "dirty": dirty,
        "commits": commits, "nx_branch": nx_branch, "nx_dirty": nx_dirty,
        "nx_commits": nx_commits, "last": last, "port": port,
        "preview_port": preview_port,
    }


def read_report(name):
    try:
        return open(os.path.join(REPORT_DIR, f"{name}.md"), errors="replace").read()
    except OSError:
        return ""


def summary_md(name):
    """Return the summary block (## Summary heading to end of report)."""
    m = re.search(r"^##\s*Summary\b.*\Z", read_report(name), re.M | re.S)
    return m.group(0).strip() if m else None


def take_over(name):
    """Kill the driver loop (server stays up); return attach command.

    The attach resumes the agent's own session (-s) so prior history and
    any manual instructions stay in one continuous conversation.
    Returns (attach_cmd or None, warning_or_None).
    """
    subprocess.run(["pkill", "-f", f"tasks/{name}\\.md"], capture_output=True)
    s = agent_state(name)
    if not s["port"] or not alive(s["port"]):
        return None, "server down — press r to start"
    cmd = ["opencode", "attach", f"http://localhost:{s['port']}"]
    try:
        r = subprocess.run(
            [f"{SCRIPT_DIR}/agent-session.sh", name],
            capture_output=True, text=True, timeout=60)
        sid = r.stdout.strip()
    except subprocess.TimeoutExpired:
        sid = ""
    if sid:
        cmd += ["-s", sid]
    return cmd, (None if sid else
                 "session unknown — opened fresh; history stays in driver logs")


def act(action, name):
    if action == "stop":
        subprocess.run([f"{SCRIPT_DIR}/agent-stop.sh", name], capture_output=True)
    elif action == "resume":
        subprocess.run([f"{SCRIPT_DIR}/agent-start.sh", name], capture_output=True)


def snapshot():
    """Non-interactive one-shot listing (rich only, no venv needed)."""
    from rich.console import Console

    c = Console()
    ns = names()
    if not ns:
        c.print("no agents spawned — use ~/.config/opencode/agents/spawn-agent.sh", style="dim")
        return
    for n in ns:
        s = agent_state(n)
        style = STATE_STYLE.get(s["state"], "white")
        mark = "✓" if summary_md(n) else " "
        c.print(Text.assemble(
            (f"▸ {n}", "bold"),
            (f"\n{mark}   {s['state']}", style),
            (f" {s['pct']:>3}%  idle {s['idle']}  "
             f"{s['branch']} +{s['commits']}/{s['nx_commits']}", "dim")))
        if s["last"]:
            c.print(Text(f"      last: {s['last']}", style="italic dim"))


def _ensure_textual():
    """Re-exec under the project venv, bootstrapping it if needed."""
    try:
        import textual  # noqa: F401
        return
    except ModuleNotFoundError:
        pass
    venv_dir = os.path.join(DATA_DIR, ".venv")
    venv_py = os.path.join(venv_dir, "bin", "python")
    if not os.path.exists(venv_py):
        uv = shutil.which("uv") or os.path.expanduser("~/.local/bin/uv")
        if not os.path.exists(uv):
            subprocess.run(["bash", "-c",
                            "curl -LsSf https://astral.sh/uv/install.sh | sh"],
                           check=False)
        uv = shutil.which("uv") or os.path.expanduser("~/.local/bin/uv")
        if not os.path.exists(uv):
            sys.exit("error: textual missing and uv unavailable — install uv or textual")
        subprocess.run([uv, "venv", venv_dir], check=True)
        subprocess.run([uv, "pip", "install", "--python", venv_py, "textual"],
                       check=True)
    os.execv(venv_py, [venv_py, os.path.abspath(__file__)] + sys.argv[1:])


def _run_tui():
    from textual.app import App, ComposeResult
    from textual.binding import Binding
    from textual.containers import Horizontal, Vertical, VerticalScroll
    from textual.widgets import Footer, Input, Markdown, OptionList, Static
    from textual.widgets.option_list import Option

    class ScrollPane:
        """Shared keyboard scrolling for the right-side panes."""

        can_focus = True

        def _nudge(self, rows):
            self.scroll_to(y=self.scroll_offset.y + rows, animate=False)

        def on_key(self, event):
            page = lambda: self.scroll_page_down(animate=False)  # noqa: E731
            handlers = {
                "pageup": lambda: self.scroll_page_up(animate=False),
                "pagedown": page,
                "home": lambda: self.scroll_home(animate=False),
                "end": lambda: self.scroll_end(animate=False),
                "space": page,
                "up": lambda: self._nudge(-2),
                "down": lambda: self._nudge(2),
            }
            fn = handlers.get(event.key)
            if fn is None:
                return
            fn()
            event.stop()
            event.prevent_default()

    class FocusMarkdown(ScrollPane, Markdown):
        """Summary/session pane: click to focus, then scroll with keys."""

    class DiffWrap(ScrollPane, VerticalScroll):
        """Scrollable wrapper hosting the styled whole-branch diff."""

    class Dashboard(App):
        TITLE = "headstad agents"

        CSS = """
        #main { height: 1fr; }
        #agents { width: 34; border: round $accent; padding: 0 1; }
        #agents:focus { border: round $success; }
        #detail { border: round $panel-lighten-2; margin-left: 1; padding: 0 1; }
        #meta { height: auto; color: $text-muted; }
        #info { height: 1fr; background: $surface; scrollbar-size: 1 1; overflow-y: auto; }
        #diffwrap { height: 1fr; background: $surface; scrollbar-size: 1 1;
                    display: none; }
        #diffview { padding: 0 1; }
        #chat { height: auto; display: none; }
        #broadcast { height: auto; display: none; }
        """

        BINDINGS = [
            Binding("i", "info", "info"),
            Binding("e", "session", "session"),
            Binding("d", "diff", "diff"),
            Binding("a", "take_over", "take over"),
            Binding("o", "open_preview", "preview"),
            Binding("r", "resume", "resume"),
            Binding("s", "stop", "stop"),
            Binding("space", "toggle_select", "select", show=False),
            Binding("b", "broadcast", "broadcast"),
            Binding("R", "reload", "reload app"),
            Binding("q", "quit", "quit"),
            Binding("pageup", "page_up", "pgup", show=False, priority=True),
            Binding("pagedown", "page_down", "pgdn", show=False, priority=True),
        ]

        def __init__(self):
            super().__init__()
            self.selected = None
            self.mode = "info"            # info | session | diff
            self.sig = None               # option-list signature cache
            self.info_hash = None         # markdown content cache
            self._sids = {}               # name -> resolved session id ("" unknown)
            self.transcripts = {}         # name -> last good transcript md
            self._diff_cache = {}         # name -> branch diff md
            self._cur_tag = None          # which view produced current md
            self._selected_agents = set() # multi-select for broadcast
            self._broadcast_mode = False  # broadcast input focused

        def compose(self) -> ComposeResult:
            with Horizontal(id="main"):
                yield OptionList(id="agents")
                with Vertical(id="detail"):
                    yield Static("", id="meta")
                    yield FocusMarkdown("", id="info")
                    with DiffWrap(id="diffwrap"):
                        yield Static("", id="diffview", markup=False)
                    yield Input(
                        placeholder="type to the agent — enter sends (pauses driver) · esc agents",
                        id="chat")
                    yield Input(
                        placeholder="broadcast to all selected — enter sends · esc cancel",
                        id="broadcast")
            yield Footer()

        def on_mount(self):
            self.set_interval(POLL_SECS, self.poll)
            self.query_one("#agents").focus()
            self.poll()

        def poll(self):
            ns = names()
            states = {n: agent_state(n) for n in ns}
            if self.selected not in ns:
                self.selected = ns[0] if ns else None

            ol = self.query_one("#agents", OptionList)
            sig = tuple(
                (n, states[n]["state"], states[n]["pct"], states[n]["idle"],
                 n in self._selected_agents)
                for n in ns)
            if sig != self.sig:
                self.sig = sig
                ol.clear_options()
                for n in ns:
                    s = states[n]
                    st_style = STATE_STYLE.get(s["state"], "white")
                    mark = "✓" if summary_md(n) else " "
                    sel = "•" if n in self._selected_agents else " "
                    prompt = Text.assemble(
                        (f"{sel}{n}  [{mark}]", "bold"),
                        Text(f"\n   {s['state']}", style=st_style),
                        (f" {s['pct']:>3}%  idle {s['idle']}", "dim"))
                    ol.add_option(Option(prompt, id=n))
                if self.selected in ns:
                    ol.highlighted = ns.index(self.selected)

            meta = self.query_one("#meta", Static)
            if self.selected:
                s = states[self.selected]
                srv = (f":{s['port']}" if s["port"] and alive(s["port"])
                       else f":{s['port']} down" if s["port"] else "no server")
                preview = ""
                if s["preview_port"]:
                    preview = f" · preview :{s['preview_port']}"
                sel_count = len(self._selected_agents)
                sel_str = f" · {sel_count} selected" if sel_count else ""
                meta.update(Text.assemble(
                    (s["state"], STATE_STYLE.get(s["state"], "white")),
                    Text(f" · pid {s['pid'] or '—'} · {srv} · idle {s['idle']}{preview}"
                         f"\n{s['branch']} +{s['commits']}/{s['nx_commits']} commits"
                         f" · {s['dirty']}+{s['nx_dirty']} changed · now: "
                         f"{s['step']}{sel_str}"),
                ))
            else:
                meta.update("")

            info = self.query_one("#info", Markdown)
            dw = self.query_one("#diffwrap", DiffWrap)
            dstat = self.query_one("#diffview", Static)
            chat = self.query_one("#chat", Input)
            bcast = self.query_one("#broadcast", Input)
            diff_mode = self.mode == "diff"
            dw.display = diff_mode
            info.display = not diff_mode
            chat.display = self.mode == "session"
            bcast.display = self._broadcast_mode
            if diff_mode and self.selected:
                cached = self._diff_cache.get(self.selected)
                if cached is None:
                    cached = branch_diff(self.selected)
                    self._diff_cache[self.selected] = cached
                    dstat.update(cached)
            elif self.selected:
                if self.mode == "diff":
                    md = self._diff_cache.get(self.selected)
                    if md is None:
                        md = branch_diff_md(self.selected)
                        self._diff_cache[self.selected] = md
                    tag = "diff"
                elif self.mode == "session":
                    s = states[self.selected]
                    if not (s["port"] and alive(s["port"])):
                        md = "*server down — press r to start*"
                    else:
                        if self.selected not in self._sids:
                            self._sids[self.selected] = resolve_session(self.selected)
                        sid = self._sids[self.selected]
                        if not sid:
                            md = "*no session found for this agent*"
                        else:
                            try:
                                md = fetch_transcript(s["port"], sid)
                                self.transcripts[self.selected] = md
                            except Exception:
                                md = (self.transcripts.get(self.selected)
                                      or "*could not load transcript — retrying…*")
                    tag = "session"
                else:
                    summ = summary_md(self.selected)
                    md = (summ if summ else
                          "> no `## Summary` yet — written when the agent"
                          " completes\n\n" + read_report(self.selected))
                    tag = "info"
                h = hashlib.sha256(md.encode()).hexdigest() + ":" + tag
                if h != self.info_hash:
                    self._cur_tag = tag
                    self.info_hash = h
                    y = info.scroll_offset.y
                    at_bottom = y >= info.max_scroll_y
                    info.update(md)
                    if at_bottom:
                        info.scroll_end(animate=False)
                    elif y:
                        info.scroll_to(y=y, animate=False)

        def action_page_up(self):
            self._active_pane().scroll_page_up(animate=False)

        def action_page_down(self):
            self._active_pane().scroll_page_down(animate=False)

        def _active_pane(self):
            return (self.query_one("#diffwrap") if self.mode == "diff"
                    else self.query_one("#info"))

        # -- events ---------------------------------------------------------

        def _snap_top(self):
            self.info_hash = None
            self._cur_tag = None
            for sel in ("#info", "#diffwrap"):
                try:
                    self.query_one(sel).scroll_home(animate=False)
                except Exception:
                    pass

        def on_option_list_option_highlighted(self, event):
            nid = event.option_id
            if nid and nid != self.selected:
                self.selected = nid
                self.mode = "info"
                self._snap_top()

        # -- actions --------------------------------------------------------

        def action_info(self):
            self.mode = "info"
            self.poll()
            self._snap_top()

        def action_session(self):
            self.mode = "session" if self.mode != "session" else "info"
            self.poll()
            if self.mode == "session":
                self.query_one("#chat", Input).focus()
            else:
                self._snap_top()

        def action_diff(self):
            self.mode = "diff" if self.mode != "diff" else "info"
            self.poll()
            self._snap_top()

        def on_key(self, event):
            if event.key == "escape":
                chat = self.query_one("#chat", Input)
                bcast = self.query_one("#broadcast", Input)
                if bcast.has_focus:
                    self._broadcast_mode = False
                    self.query_one("#agents").focus()
                elif chat.has_focus:
                    self.query_one("#agents").focus()

        def on_input_submitted(self, event):
            if event.input.id == "broadcast":
                self._handle_broadcast(event)
                return
            if event.input.id != "chat" or not self.selected:
                return
            text = event.value.strip()
            if not text:
                return
            s = agent_state(self.selected)
            if not (s["port"] and alive(s["port"])):
                self.notify("server down — press r to start", severity="warning")
                return
            sid = self._sids.get(self.selected) or resolve_session(self.selected)
            if sid:
                self._sids[self.selected] = sid
            if not sid:
                self.notify("no session found for this agent", severity="warning")
                return
            # pause autonomous driver so it doesn't fight the manual message
            subprocess.run(["pkill", "-f", f"tasks/{self.selected}\\.md"],
                           capture_output=True)
            ok, err = send_user_message(self.selected, sid, text)
            if ok:
                event.input.value = ""
                self.transcripts.pop(self.selected, None)  # force refetch
                self.info_hash = None
                self.notify("sent — driver paused (r resumes)")
                self.poll()
            else:
                self.notify(f"send failed: {err}", severity="error", timeout=8)

        def _handle_broadcast(self, event):
            """Send the message to all selected agents."""
            text = event.value.strip()
            if not text:
                return
            if not self._selected_agents:
                self.notify("no agents selected", severity="warning")
                return
            ok_count = 0
            fail_count = 0
            for name in list(self._selected_agents):
                s = agent_state(name)
                if not (s["port"] and alive(s["port"])):
                    fail_count += 1
                    continue
                sid = self._sids.get(name) or resolve_session(name)
                if sid:
                    self._sids[name] = sid
                if not sid:
                    fail_count += 1
                    continue
                # pause autonomous driver
                subprocess.run(["pkill", "-f", f"tasks/{name}\\.md"],
                               capture_output=True)
                ok, _err = send_user_message(name, sid, text)
                if ok:
                    ok_count += 1
                    self.transcripts.pop(name, None)
                else:
                    fail_count += 1
            event.input.value = ""
            self.info_hash = None
            self._broadcast_mode = False
            self.query_one("#agents").focus()
            parts = []
            if ok_count:
                parts.append(f"sent to {ok_count}")
            if fail_count:
                parts.append(f"{fail_count} failed")
            msg = " · ".join(parts) if parts else "nothing sent"
            severity = "warning" if fail_count else "information"
            self.notify(f"broadcast: {msg} — driver paused (r resumes)",
                        severity=severity)
            self.poll()

        def _run_blocking(self, cmd):
            with self.suspend():
                subprocess.run(cmd)
            self.poll()

        def action_take_over(self):
            if not self.selected:
                return
            cmd, warn = take_over(self.selected)
            if cmd is None:
                self.notify(warn or "cannot take over", severity="warning")
                return
            self._run_blocking(cmd)
            if warn:
                self.notify(warn, severity="warning", timeout=6)

        def action_resume(self):
            if not self.selected:
                return
            act("resume", self.selected)
            self.notify(f"resuming driver {self.selected}…")
            self.poll()

        def action_stop(self):
            if not self.selected:
                return
            act("stop", self.selected)
            self.notify(f"stopping {self.selected}…")
            self.poll()

        def action_open_preview(self):
            """Start quasar dev for the selected agent and open in browser."""
            if not self.selected:
                return
            preview_script = os.path.join(SCRIPT_DIR, "agent-preview.sh")
            # Get or start the server
            r = subprocess.run(
                [preview_script, self.selected, "url"],
                capture_output=True, text=True, timeout=30)
            port = r.stdout.strip()
            if port:
                url = f"http://localhost:{port}"
                self.notify(f"opening {url}")
                # Use xdg-open on Linux for reliable localhost opening
                subprocess.Popen(["xdg-open", url],
                                 stdout=subprocess.DEVNULL,
                                 stderr=subprocess.DEVNULL)
            else:
                self.notify("failed to start preview server", severity="error")

        def action_toggle_select(self):
            """Toggle multi-select on the highlighted agent."""
            ol = self.query_one("#agents", OptionList)
            if ol.highlighted is None:
                return
            ns = names()
            if ol.highlighted >= len(ns):
                return
            name = ns[ol.highlighted]
            if name in self._selected_agents:
                self._selected_agents.discard(name)
            else:
                self._selected_agents.add(name)
            self.sig = None  # force re-render with new selection
            self.poll()
            count = len(self._selected_agents)
            if count:
                self.notify(f"{count} agent{'s' if count != 1 else ''} selected")
            else:
                self.notify("selection cleared")

        def action_broadcast(self):
            """Focus the broadcast input."""
            if not self._selected_agents:
                self.notify("select agents first (space to toggle)", severity="warning")
                return
            self._broadcast_mode = True
            self.poll()
            self.query_one("#broadcast", Input).focus()

        def _exec_self(self):
            """Replace this process with a fresh dashboard (same tty)."""
            with self.suspend():
                os.execv(sys.executable,
                         [sys.executable, os.path.abspath(__file__), *sys.argv[1:]])

        def action_reload(self):
            self.notify("reloading…")
            self._exec_self()

    app = Dashboard()
    app.theme = os.environ.get("OPENCODE_DASHBOARD_THEME", "catppuccin-macchiato")
    return app


def main():
    once = "--once" in sys.argv
    if once:
        snapshot()
        return 0

    if not sys.stdin.isatty():
        print("interactive dashboard requires a tty (use --once for a snapshot)",
              file=sys.stderr)
        return 1

    import fcntl

    # zellij strips COLORTERM → 256-color approximation washes out frappé;
    # modern terminals handle truecolor, so default it on.
    os.environ.setdefault("COLORTERM", "truecolor")

    lock_path = os.environ.get(
        "OPENCODE_AGENTS_LOCK", "/tmp/opencode-agents-dashboard.lock")
    lock_file = open(lock_path, "w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        print("dashboard already running", file=sys.stderr)
        return 1

    _ensure_textual()
    _run_tui().run()
    return 0


if __name__ == "__main__":
    sys.exit(main())
