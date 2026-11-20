"""The files AI assistants, AI crawlers and agents read, written into the built site:

  /llms.txt and /llms-full.txt     what the app is, in markdown (llms.txt v2)
  <page>/index.md                  a markdown copy of each English page, linked from the page
  /robots.txt                      every AI crawler and agent on the ai.robots.txt list, all allowed
  /.well-known/ard.json            Agentic Resource Discovery manifest, named in a robots.txt comment
  /.well-known/agent-skills/       an Agent Skill that teaches an agent to answer about the app
  /.well-known/security.txt        RFC 9116 contact
  /.nojekyll                       GitHub Pages serves the files above as they are

The same file is web/_generator/ai_files.py in the undirect and Cutling repos: change both.
What a site says about itself comes from its own ai_facts.py; this file only shapes it.

Sources, read 2026-11-20:
  llms.txt v2, https://llmstxt.org/index.md: an H1, a blockquote summary, markdown without
    headings, then H2 sections that list [name](url): note. rel="alternate" type="text/markdown"
    points at a page's markdown copy and rel="describedby" at the llms.txt that covers it.
  Chrome Lighthouse's Agentic Browsing category audits llms.txt and ARD:
    https://developer.chrome.com/docs/lighthouse/agentic-browsing/scoring
  ARD, https://agenticresourcediscovery.org/spec/ §4.2 and §5.1: entries carry identifier
    (urn:air:<domain>:...), displayName, type and one of url or data, plus 2 to 5
    representativeQueries, which registries index; found at /.well-known/ard.json, rel="ard"
    and a robots.txt comment naming it (an Agentmap: directive fails Lighthouse's robots.txt audit). Supabase and Cloudflare Docs publish one.
  Agent Skills discovery v0.2.0, https://github.com/cloudflare/agent-skills-discovery-rfc:
    /.well-known/agent-skills/index.json lists each skill's name, type, description, url and
    sha256 digest; SKILL.md follows https://agentskills.io/specification.
  robots.txt groups, RFC 9309. Content-Signal is Cloudflare's Content Signals Policy
    (https://blog.cloudflare.com/content-signals-policy/): search, ai-input, ai-train, yes or no.
  The AI crawler list is ai.robots.txt (https://github.com/ai-robots-txt/ai.robots.txt), read at
    build time; ai_agents.json beside this file is the copy used when the build is offline.
GitHub Pages runs Jekyll on gh-pages unless .nojekyll exists. Jekyll would turn index.md into a
second index.html and drop /.well-known/, so the site ships .nojekyll.
"""
import datetime
import hashlib
import html
import json
import re
import urllib.request
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import urljoin

AGENTS_URL = "https://raw.githubusercontent.com/ai-robots-txt/ai.robots.txt/main/robots.json"
AGENTS_COPY = Path(__file__).with_name("ai_agents.json")
# Search crawlers whose indexes AI answers draw on: Google's AI Overviews and Gemini, Bing's for
# Copilot and ChatGPT search. ai.robots.txt lists AI agents only, so these two are added here.
SEARCH_CRAWLERS = ["Googlebot", "bingbot"]
SIGNAL = "Content-Signal: search=yes, ai-input=yes, ai-train=yes"


def ai_agents():
    """ai.robots.txt's current list, or the stored copy when it cannot be read."""
    try:
        with urllib.request.urlopen(AGENTS_URL, timeout=15) as r:
            names = list(json.load(r))
        if len(names) > 50:
            return names, "read at build time"
    except Exception as e:
        print(f"WARNING: ai.robots.txt not read ({e}); using {AGENTS_COPY.name}")
    copy = json.loads(AGENTS_COPY.read_text(encoding="utf-8"))
    return copy["agents"], f"stored copy of {copy['read']}"


def robots_txt(site):
    """Everyone may read everything. Every AI crawler is named, so none falls back to a default."""
    agents, source = ai_agents()
    seen, names = set(), []
    for n in SEARCH_CRAWLERS + agents:
        if n.lower() not in seen:
            seen.add(n.lower())
            names.append(n)
    lines = ["# Search engines, AI assistants and AI agents are welcome to read, cite and learn from this site.",
             "User-agent: *", SIGNAL, "Allow: /", "",
             f"# {len(names) - len(SEARCH_CRAWLERS)} AI crawlers and agents from ai.robots.txt ({source}), and the search",
             "# crawlers AI answers draw on. A crawler that finds its own name reads this group, not the one above."]
    lines += [f"User-agent: {n}" for n in names]
    lines += [SIGNAL, "Allow: /", "",
              f"# Agentmap: {site}/.well-known/ard.json (a comment: Lighthouse fails robots.txt on directives it does not know; agents also find it at that path and by rel=\"ard\")", f"Sitemap: {site}/sitemap.xml", "",
              f"# A summary for AI assistants: {site}/llms.txt", f"# Everything in one file: {site}/llms-full.txt"]
    return "\n".join(lines) + "\n"


class _Markdown(HTMLParser):
    """The readable part of a page as markdown: headings, paragraphs, lists, links, tables, FAQ."""
    SKIP = {"script", "style", "svg", "video", "audio", "noscript", "template", "nav", "header", "footer",
            "picture", "iframe", "form", "button", "select", "dialog"}
    VOID = {"img", "br", "hr", "meta", "link", "input", "source", "wbr", "col", "area", "track", "embed"}
    BLOCK = {"p", "div", "section", "article", "main", "aside", "blockquote", "figure", "figcaption",
             "details", "dl", "dt", "dd", "ul", "ol", "li", "table", "h1", "h2", "h3", "h4", "h5", "h6"}

    def __init__(self, url, shift, campaign):
        super().__init__(convert_charrefs=True)
        self.url, self.shift, self.campaign = url, shift, campaign
        self.blocks, self.buf, self.prefix = [], [], ""
        self.skip_tag, self.skip_depth = None, 0
        self.lists, self.links = [], []
        self.table, self.row, self.cell_at = None, None, None
        self.video = ""

    def href(self, raw):
        if not raw or raw.startswith(("#", "javascript:")):
            return None
        out = urljoin(self.url, raw)
        if self.campaign and "apps.apple.com" in out:
            out = re.sub(r"([?&]ct=)[^&]*", r"\g<1>" + self.campaign, out)
        return out

    def flush(self, wrap=""):
        text = re.sub(r"[ \t\r\n]+", " ", "".join(self.buf)).replace(" \x00 ", "\x00").replace("\x00", "\n").strip()
        self.buf = []
        if text:
            self.blocks.append(self.prefix + (f"{wrap}{text}{wrap}" if wrap else text))

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if self.skip_tag:
            self.skip_depth += tag == self.skip_tag
            if self.skip_tag == "video" and tag == "source" and a.get("src"):
                self.blocks.append(f"[Video: {self.video}]({self.href(a['src'])})")
                self.video = ""
            return
        if tag == "video":
            self.video = a.get("aria-label") or "film"
            if a.get("src"):
                self.blocks.append(f"[Video: {self.video}]({self.href(a['src'])})")
        if tag in self.VOID:
            if tag == "br":
                self.buf.append(" \x00 ")
            elif tag == "img" and self.links and a.get("alt"):
                self.links[-1][2] = a["alt"]
            return
        if tag in self.SKIP or a.get("aria-hidden") == "true" or "skip" in (a.get("class") or "").split():
            self.skip_tag, self.skip_depth = tag, 1
            return
        in_cell = self.cell_at is not None
        if tag in self.BLOCK and not in_cell:
            self.flush()
        if tag in ("h1", "h2", "h3", "h4", "h5", "h6"):
            self.prefix = "#" * min(6, int(tag[1]) + self.shift) + " "
        elif tag in ("ul", "ol"):
            self.lists.append([tag, 0])
        elif tag == "li" and self.lists:
            self.lists[-1][1] += 1
            kind, n = self.lists[-1]
            self.prefix = "  " * (len(self.lists) - 1) + ("- " if kind == "ul" else f"{n}. ")
        elif tag == "table":
            self.table = []
        elif tag == "tr":
            self.row = []
        elif tag in ("td", "th") and self.row is not None:
            self.cell_at = len(self.buf)
        elif tag == "a":
            if self.buf and not self.buf[-1][-1:].isspace():
                self.buf.append(" ")
            self.links.append([self.href(a.get("href")), len(self.buf), ""])
        elif tag in ("strong", "b"):
            self.buf.append("**")
        elif tag in ("em", "i"):
            self.buf.append("*")
        elif tag in ("code", "kbd"):
            self.buf.append("`")

    def handle_endtag(self, tag):
        if self.skip_tag:
            if tag == self.skip_tag:
                self.skip_depth -= 1
                if not self.skip_depth:
                    self.skip_tag = None
            return
        if tag == "a" and self.links:
            href, at, alt = self.links.pop()
            text = re.sub(r"\s+", " ", "".join(self.buf[at:])).strip() or alt
            self.buf[at:] = [f"[{text}]({href})" if href and text else text]
        elif tag in ("strong", "b"):
            self.buf.append("**")
        elif tag in ("em", "i"):
            self.buf.append("*")
        elif tag in ("code", "kbd"):
            self.buf.append("`")
        elif tag in ("td", "th") and self.cell_at is not None and self.row is not None:
            cell = re.sub(r"\s+", " ", "".join(self.buf[self.cell_at:]).replace("\x00", " ")).strip()
            del self.buf[self.cell_at:]
            self.row.append(cell.replace("|", "\\|"))
            self.cell_at = None
        elif tag == "tr" and self.row is not None and self.table is not None:
            self.table.append(self.row)
            self.row = None
        elif tag == "table" and self.table is not None:
            rows, self.table = self.table, None
            if rows:
                width = max(len(r) for r in rows)
                rows = [r + [""] * (width - len(r)) for r in rows]
                md = ["| " + " | ".join(rows[0]) + " |", "|" + "---|" * width]
                md += ["| " + " | ".join(r) + " |" for r in rows[1:]]
                self.blocks.append("\n".join(md))
        elif tag == "summary":
            self.flush(wrap="**")
        elif tag in ("ul", "ol") and self.lists:
            self.flush()
            self.lists.pop()
            self.prefix = ""
        elif tag in self.BLOCK and self.cell_at is None:
            self.flush()
            self.prefix = ""

    def handle_data(self, data):
        if not self.skip_tag:
            self.buf.append(data)

    def markdown(self):
        """Blocks a blank line apart, except list items, which stay one per line."""
        self.flush()
        item = re.compile(r"\s*(- |\d+\. )")
        out = []
        for b in (b for b in self.blocks if b.strip()):
            if out and item.match(b) and item.match(out[-1].rsplit("\n", 1)[-1]):
                out[-1] += "\n" + b
            else:
                out.append(b)
        return "\n\n".join(out)


def page_markdown(page_html, url, shift=0, campaign=None):
    """The page's <main>, or its <body> when it has none, as markdown."""
    m = re.search(r"<main\b[^>]*>(.*)</main>", page_html, re.S) or re.search(r"<body\b[^>]*>(.*)</body>", page_html, re.S)
    p = _Markdown(url, shift, campaign)
    p.feed(m.group(1) if m else page_html)
    p.close()
    return p.markdown()


def page_title(page_html):
    m = re.search(r"<title>(.*?)</title>", page_html, re.S)
    return html.unescape(m.group(1)).strip() if m else ""


def skill_md(site, facts):
    """An Agent Skill (agentskills.io) that answers about the app from the same facts as llms.txt."""
    sk = facts["skill"]
    links = "\n".join(f"- [{label}]({site}/{rel}index.md): {note}" for label, note, rel in facts["pages"])
    return f"""---
name: {sk['name']}
description: {json.dumps(sk['description'], ensure_ascii=False)}
metadata:
  source: {site}/llms.txt
---

# {facts['name']}

{facts['summary']}

{facts['body'].strip()}

## Set it up

{sk['setup'].strip()}

## Read more

{links}
- [Everything in one file]({site}/llms-full.txt)
"""


def ard_manifest(site, facts):
    """Agentic Resource Discovery: the Agent Skill, with the questions it answers.

    ARD's standard types are agent resources (skills, MCP servers, agent cards). A text/plain or
    text/markdown document earns a conformance warning, so the documents stay in llms.txt."""
    host = site.split("//", 1)[1]
    sk = facts["skill"]
    return {"specVersion": "1.0",
            "host": {"displayName": facts["name"], "identifier": site, "documentationUrl": f"{site}/llms.txt"},
            "entries": [{"identifier": f"urn:air:{host}:skill:{sk['name']}", "displayName": f"{facts['name']} agent skill",
                         "type": "application/agent-skills+md", "url": f"{site}/.well-known/agent-skills/{sk['name']}/SKILL.md",
                         "description": sk["description"], "representativeQueries": facts["queries"][:5]}]}


def write(out, site, facts, page_file, campaign="llms"):
    """Writes every file listed at the top of this module into the built site at out.

    facts: from the site's ai_facts.py (name, summary, body, queries, pages, links, skill, email).
    page_file(rel): the built index.html of the English page at rel ("" is home) and its URL.
    """
    full = []
    head_tags = (f'<link rel="describedby" href="{site}/llms.txt">\n'
                 f'<link rel="ard" href="{site}/.well-known/ard.json">\n')
    for _, _, rel in facts["pages"]:
        path, url = page_file(rel)
        page_html = path.read_text(encoding="utf-8")
        path.with_name("index.md").write_text(page_markdown(page_html, url, campaign=campaign) + "\n", encoding="utf-8")
        tags = f'<link rel="alternate" type="text/markdown" href="{url}index.md">\n' + head_tags
        path.write_text(page_html.replace("</head>", tags + "</head>", 1), encoding="utf-8")
        full.append(f"Source: {url}\n\n" + page_markdown(page_html, url, shift=1, campaign=campaign))

    head = [f"# {facts['name']}", "", f"> {facts['summary']}", "", facts["body"].strip(), ""]
    index = head + ["## Pages", ""]
    index += [f"- [{label}]({page_file(rel)[1]}index.md): {note}" for label, note, rel in facts["pages"]]
    for section, links in facts.get("links", []):
        index += ["", f"## {section}", ""] + [f"- [{label}]({url}): {note}" for label, url, note in links]
    index += ["", "## For agents", "",
              f"- [Agent skill]({site}/.well-known/agent-skills/{facts['skill']['name']}/SKILL.md): {facts['skill']['description']}",
              f"- [Agentic Resource Discovery manifest]({site}/.well-known/ard.json): lists the skill for agent registries",
              "", "## Optional", "",
              f"- [Everything in one file]({site}/llms-full.txt): these facts and the full text of every page above"]
    (out / "llms.txt").write_text("\n".join(index) + "\n", encoding="utf-8")
    (out / "llms-full.txt").write_text("\n".join(head) + "\n---\n\n" + "\n\n---\n\n".join(full) + "\n", encoding="utf-8")
    (out / "robots.txt").write_text(robots_txt(site), encoding="utf-8")

    wk = out / ".well-known"
    skill_dir = wk / "agent-skills" / facts["skill"]["name"]
    skill_dir.mkdir(parents=True, exist_ok=True)
    skill = skill_md(site, facts).encode("utf-8")
    (skill_dir / "SKILL.md").write_bytes(skill)
    (wk / "agent-skills" / "index.json").write_text(json.dumps({
        "$schema": "https://schemas.agentskills.io/discovery/0.2.0/schema.json",
        "skills": [{"name": facts["skill"]["name"], "type": "skill-md", "description": facts["skill"]["description"],
                    "url": f"/.well-known/agent-skills/{facts['skill']['name']}/SKILL.md",
                    "digest": "sha256:" + hashlib.sha256(skill).hexdigest()}]}, indent=1) + "\n", encoding="utf-8")
    (wk / "ard.json").write_text(json.dumps(ard_manifest(site, facts), indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    expires = (datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=365)).strftime("%Y-%m-%dT00:00:00Z")
    (wk / "security.txt").write_text(f"Contact: mailto:{facts['email']}\nExpires: {expires}\nPreferred-Languages: en\n"
                                     f"Canonical: {site}/.well-known/security.txt\n", encoding="utf-8")
    (out / ".nojekyll").write_text("", encoding="utf-8")


if __name__ == "__main__":
    # python3 ai_files.py: refresh the stored copy of the ai.robots.txt list.
    with urllib.request.urlopen(AGENTS_URL, timeout=30) as r:
        names = list(json.load(r))
    AGENTS_COPY.write_text(json.dumps({"source": AGENTS_URL, "read": datetime.date.today().isoformat(),
                                       "agents": names}, indent=1) + "\n", encoding="utf-8")
    print(f"{len(names)} agents -> {AGENTS_COPY}")
