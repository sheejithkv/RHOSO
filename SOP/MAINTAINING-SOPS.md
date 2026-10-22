# SOP-MAINTAINERS — Exact update procedure

> **Current implementation (verified 2026-10-22):** Markdown SOPs and the visual HTML viewer are **independent, manually maintained copies**. Editing a Markdown SOP does **not** update the styled viewer. GitHub Actions validates that the two HTML copies match, but does **not** check that HTML and Markdown descriptions agree. This distinction must be checked in every PR.

## 1. Update an existing SOP

1. Open [the SOP catalogue](README.md). Choose `operations/`, `incidents/`, `maintenance/` or `recovery/`.
2. Edit the applicable **authoritative** Markdown procedure (for example `incidents/vm-build-failure.md`) on a new branch from current `main`.
3. Update document control (version, status, RHOSO micro-release, owner/approver, verified date), purpose/scope, prerequisites, execution context, controller ownership, risks, step/command/expected/interpretation matrix, decision tree, acceptance test, stop conditions, rollback, references and revision history.
4. Check every new command against the exact RHOSO/CLI release and deployed topology; mark commands `UNVERIFIED` until tested. Never copy live credentials, internal addresses, tenant IDs, or unredacted logs.
5. Update the category's `EXAMPLE.md` if its walkthrough is affected; label hypothetical evidence **SIMULATED**.
6. **Manually synchronize the visual viewer** using section 3 below.
7. Update `SOP/CHANGELOG.md`; update `SOP/README.md` when its catalogue link or summary changed.
8. Open PR, verify checks/rendering, request review and merge only after the gates in section 5.

## 2. Add a new SOP

1. Create a branch from up-to-date `main`, e.g. `docs/sop-inc-002`; do not edit `main` directly.
2. Copy [TEMPLATE.md](TEMPLATE.md) into the right category with a stable, unique ID and descriptive slug, e.g. `SOP/incidents/nova-compute-down.md` / `SOP-INC-002`.
3. Populate every section, marking unknown facts **UNKNOWN**, placeholders explicitly, and any examples **SIMULATED**. Never infer root cause from an error status alone.
4. The current category `EXAMPLE.md` is a **single shared example**, not an automatically generated example for each SOP. Either revise it to illustrate the new procedure or create a uniquely named example, e.g. `SOP/incidents/examples/nova-compute-down.md`, and link it from the new SOP and catalogue. Do not overwrite another SOP's worked example silently.
5. Add the new SOP to `SOP/README.md` with the appropriate example link.
6. Add an entry for the SOP in the HTML viewer's `docs` JavaScript object and test the navigation (section 3).
7. Update `SOP/CHANGELOG.md` and submit a PR.

## 3. Keep the visual SOP up to date (mandatory for displayed SOPs)

The **source of truth for procedure content is its Markdown file**. The visual interface contains a **separate summary**, and should never be the sole location for a technical fix.

1. Edit `SOP/visual/index.html`; locate `const docs = {` and the entry `incident`, `operations`, `maintenance` or `recovery`. Update the matching `number`, `title`, `category`, `purpose`, `scope`, `pre`, `risk`, `outcome`, `flow`, `steps`, `validation`, `issues`, `rollback`, `reference`, `example` values.
2. A step is a **five-value array**: `[action, context, command, expected result, interpretation]`. Preserve the exact position of each value and escape quotation marks/newlines as needed in JavaScript strings.
3. For a new SOP, add a **unique key** to the `docs` object. The sidebar is built from `Object.entries(docs)`; verify the new entry appears and opens correctly.
4. Copy the completed `SOP/visual/index.html` **byte-for-byte** to `docs/sop/index.html`. The GitHub workflow currently checks this with `cmp -s`.
5. Open `SOP/visual/index.html` locally in Chrome/Edge/Firefox. Check sidebar SOP selection, eleven section anchors, command columns, wrapping on narrow screens, and Print/PDF output. Do not assume GitHub's file preview renders an HTML page.
6. Check the visual summary against its authoritative Markdown SOP: commands, contexts, risks, validation, rollback, version, status and simulated examples **must not contradict it**. The current CI cannot enforce this semantic parity.
7. Update the schematic `SOP/visual/sop-preview.svg` **only if the layout design changes**. This is a schematic, not a generated screenshot. Update `SOP/visual/README.md` if viewing directions change.

### Local validation from repository root

~~~bash
# Syntax check for the standalone read-only health-check script
bash -n scripts/rhoso-healthcheck.sh

# Visual copies must match exactly
cmp -s SOP/visual/index.html docs/sop/index.html

# HTML structure and inline JS syntax (requires Python 3 and Node.js)
python3 - <<'PY'
from pathlib import Path
from html.parser import HTMLParser
html = Path('SOP/visual/index.html').read_text(encoding='utf-8')
for marker in ('id="selector"', 'id="anchors"', 'id="main"', 'DRAFT', 'SIMULATED', 'Detailed procedure', 'Rollback'):
    assert marker in html, marker
class ValidateHTML(HTMLParser): pass
ValidateHTML().feed(html)
assert '<script>' in html and '</script>' in html
Path('/tmp/rhoso-sop-viewer.js').write_text(html.split('<script>',1)[1].split('</script>',1)[0],encoding='utf-8')
PY
node --check /tmp/rhoso-sop-viewer.js

# Review the exact diff before creating a PR
git diff --check
git diff --stat
~~~

**Limit:** Syntax/static checks do not validate RHOSO CLI behavior or browser rendering. CI currently does not derive HTML from Markdown. The HTML renderer includes illustrative commands and must be verified independently.

## 4. Git workflow for engineers

~~~bash
git clone https://github.com/sheejithkv/RHOSO.git
cd RHOSO
git switch main
git pull --ff-only origin main
git switch -c docs/sop-update-<ticket>

# Edit SOP Markdown, any example, visual HTML copies, index and changelog.
git status --short
git diff --check
git add SOP/ docs/sop/index.html
git commit -m "docs(sop): update <SOP-ID> for <reason>"
git push -u origin docs/sop-update-<ticket>
~~~

Open a Pull Request to `main` using the repository's SOP checklist. **Do not paste placeholder branch names literally**; replace `<ticket>`, `<SOP-ID>` and `<reason>`.

## 5. PR review and approval gates

- [ ] The SOP and related example have clear unique IDs, status, owner, version, and review dates
- [ ] Official Red Hat docs and deployed RHOSO micro-release are checked; unsupported/unknown syntax is flagged
- [ ] Distinguishes **PROVEN HEALTHY**, **PROVEN BROKEN**, **INFERENCE**, **HYPOTHESIS**, **UNKNOWN**
- [ ] For writes: controller/source-of-truth, change approval, impact, stop criteria, rollback and original-transaction validation are defined
- [ ] `SOP/visual/index.html` and `docs/sop/index.html` match byte-for-byte
- [ ] Visual command/context/expected-result content is consistent with the authoritative Markdown
- [ ] New SOP appears in `SOP/README.md` and viewer navigation; relevant worked example linked
- [ ] `SOP/CHANGELOG.md` and SOP document revision history updated
- [ ] Browser/mobile/print review and GitHub Actions pass; no secrets/unredacted diagnostic files
- [ ] Human technical approval and **real target-environment verification** recorded before changing status to APPROVED

**Merge vs. operational approval:** a merged documentation PR does not itself authorize executing change commands or turn DRAFT into APPROVED. If site verification is not complete, retain DRAFT.

## 6. Quick GitHub web-only update

1. Navigate to the required `.md` file under [SOP/](README.md) and choose **Edit**.
2. Select **Create a new branch for this commit and start a pull request**, not commit directly to `main`.
3. Edit the corresponding SOP visual data in [visual/index.html](visual/index.html) on **that same branch**.
4. Synchronize [../docs/sop/index.html](../docs/sop/index.html) on the same branch (easiest with a local git checkout; GitHub web UI does not automatically copy files).
5. Update worked example, `CHANGELOG.md`, catalogue links, and open/review the PR.

## Future recommended improvement

Replace the duplicated JavaScript SOP data with a **generated viewer from structured Markdown/frontmatter**, with a CI semantic check. Until that pipeline is actually implemented and tested, **do not claim Markdown updates automatically appear in the visual SOP**.
