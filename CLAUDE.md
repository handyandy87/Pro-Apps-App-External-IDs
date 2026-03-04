# CLAUDE.md — AI Assistant Guide for Pro-Apps-App-External-IDs

## Project Overview

This is a **community-maintained data repository** that maps Apple Mac App Store application versions to their corresponding **App External IDs**. These IDs are required to install specific older versions of Apple Pro Apps and productivity apps via a patched MAS CLI tool.

**This is not a software project.** There is no build system, no package manager, no test suite, and no CI/CD pipeline. The primary artifacts are CSV data files and one Bash utility script.

---

## Repository Structure

```
Pro-Apps-App-External-IDs/
├── README.md                   # Project documentation and contribution guide
├── masreceipt-extid-finder.sh  # Bash script: extracts App External IDs from MASReceipt files
├── Compressor.csv              # Data: Apple Compressor (App Item ID: 424390742)
├── Final_Cut_Pro.csv           # Data: Final Cut Pro (App Item ID: 424389933)
├── GarageBand.csv              # Data: GarageBand (App Item ID: 682658836)
├── iMovie.csv                  # Data: iMovie (App Item ID: 408981434)
├── Keynote.csv                 # Data: Keynote (App Item ID: 409183694)
├── Logic_Pro.csv               # Data: Logic Pro (App Item ID: 634148309)
├── MainStage.csv               # Data: MainStage (App Item ID: 427865759)
├── Motion.csv                  # Data: Apple Motion (App Item ID: 424393196)
├── Numbers.csv                 # Data: Numbers (App Item ID: 409203825)
├── Pages.csv                   # Data: Pages (App Item ID: 409201541)
└── Pixelmator_Pro.csv          # Data: Pixelmator Pro (App Item ID: 1289583905)
```

---

## CSV File Format

All CSV files share an identical column schema:

| Column | Description |
|--------|-------------|
| `Release Order (oldest→newest)` | Sequential integer, 1-based, oldest version = 1 |
| `[App Name] Version` | Version string, e.g. `10.6.5` or `4.11.1` |
| `App External ID` | 9-digit numeric identifier — the core data being collected |
| `Release Date` | ISO 8601 date (`YYYY-MM-DD`) or empty if unknown |
| `App Item ID` | Constant 9-digit identifier for the app in the Mac App Store |
| `Notes / Source` | Attribution for where the App External ID came from |

### Example Row

```csv
67,10.6.5,858081833,2023-09-18,424389933,API validated via amp-api-edge.apps.apple.com
```

### Canonical Source Values (Notes / Source column)

| Value | Meaning |
|-------|---------|
| `User provided` | Submitted by a community member via GitHub issue |
| `Crash report` | Extracted from a macOS crash report dialog |
| `Crash report (Apple Community thread XXXXXXX)` | Crash report, with a community thread citation |
| `API validated via amp-api-edge.apps.apple.com` | Confirmed via Apple's internal version history API |
| `Additions API validated via commerce` | Confirmed via Apple's commerce API |
| `Seed App External ID list provided by user` | From a pre-release seed/beta version list |
| `Placeholder — version listed in Apple release notes` | Version is documented but App External ID is unknown; contribution needed |
| `CORRECTED (was X) via [source]` | A previously incorrect value was corrected; old value noted for transparency |

---

## Data Conventions

### Ordering
- Rows are always sorted **oldest to newest** by release date/version.
- The `Release Order` column is a stable 1-based integer index that must be kept contiguous.

### Missing Data
- An **empty** `App External ID` cell means the ID is unknown and a community contribution is needed.
- Placeholder rows explicitly say so in the Notes column. Do not delete placeholder rows.
- `Release Date` may be empty if the release date is not known.

### Adding New Rows
1. Append at the end (newest version last).
2. Increment `Release Order` by 1 from the previous row.
3. `App Item ID` is constant per application — never change it.
4. Always populate `Notes / Source` to credit where the data came from.
5. Use the exact ISO 8601 date format (`YYYY-MM-DD`) for `Release Date` when known.

### Correcting Existing Rows
- Update the `App External ID` field to the correct value.
- Update `Notes / Source` to `CORRECTED (was <old_value>) via <source>`.

### Do Not
- Change the `App Item ID` column — it is fixed for each application.
- Reorder rows arbitrarily.
- Remove placeholder rows (they signal gaps that still need contributions).
- Add duplicate version rows without correcting the existing one.

---

## The `masreceipt-extid-finder.sh` Script

This Bash script extracts App External ID metadata from a Mac App Store application's receipt file (`_MASReceipt/receipt`). It has **no external dependencies** — it uses only macOS built-in tools: `bash`, `openssl`, and `awk`.

### What it Does
1. Accepts a `.app` bundle path or a direct path to the receipt file.
2. Uses `openssl smime` to unwrap the ASN.1/CMS container.
3. Parses the ASN.1 structure to locate specific attribute types.
4. Extracts and prints four values: `bundle_id`, `application_version`, `app_item_id`, `app_external_id`.

### Usage
```bash
sudo bash masreceipt-extid-finder.sh "/Applications/Compressor.app"
# or
sudo bash masreceipt-extid-finder.sh "/Applications/Compressor.app/Contents/_MASReceipt/receipt"
```

### Output Format
```
bundle_id: com.apple.Compressor
application_version: 4.6.5
app_item_id: 424390742
app_external_id: 858081833
```

### Exit Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Missing or invalid argument / usage requested |
| 2 | Receipt file not found |
| 3 | OpenSSL CMS unwrap failed |
| 4 | ASN.1 parse failed |
| 5 | Could not decode `bundle_id` or `application_version` |

### Script Conventions
- `set -euo pipefail` — strict error handling throughout.
- Variables holding major data are `UPPERCASE`.
- Helper functions use `snake_case`.
- Temporary files go in `$TMPDIR` (cleaned up via `trap ... EXIT`).
- Written for **BSD awk** (macOS default). Avoid GNU awk extensions.
- Whitespace trimming uses plain-space regex (`/ +/`) — not `[ \t]` bracket classes, which can break on copy/paste.

**Do not modify this script to add external dependencies.**

---

## App Item ID Reference

These IDs are fixed identifiers for each application in the Mac App Store:

| Application | App Item ID |
|-------------|-------------|
| Compressor | `424390742` |
| Final Cut Pro | `424389933` |
| GarageBand | `682658836` |
| iMovie | `408981434` |
| Keynote | `409183694` |
| Logic Pro | `634148309` |
| MainStage | `427865759` |
| Motion | `424393196` |
| Numbers | `409203825` |
| Pages | `409201541` |
| Pixelmator Pro | `1289583905` |

---

## Contribution Workflow

New App External IDs are submitted by community members via **GitHub Issues**. Each issue should contain:
- App name
- App version
- App Item ID
- App External ID
- How the ID was obtained

### Methods to Obtain an App External ID

**Method 1 — Crash Report:**
```bash
open -a "Compressor"
pgrep -x "Compressor"          # → e.g., 50811
sudo kill -3 50811             # Forces crash report dialog
```
Read `App Item ID` and `App External ID` from the top of the crash report.

**Method 2 — masreceipt-extid-finder Script:**
```bash
sudo bash masreceipt-extid-finder.sh "/Applications/Compressor.app"
```
Works on any `.app` obtained from the Mac App Store (requires `_MASReceipt/receipt`).

**Important:** Only Mac App Store versions contain a `_MASReceipt` folder. Apps from other sources cannot be used to contribute.

---

## Git Workflow

- Main branch: `main`
- Historical development branch: `master` (mirrors `main`)
- Feature/contribution branches should be named descriptively.
- Commit messages describe the source of the data additions (e.g., `"API validated via amp-api-edge.apps.apple.com versionHistory"`).

### Commit Message Conventions (from repository history)
```
Additions API validated via commerce
API validated via amp-api-edge.apps.apple.com versionHistory
added versions via api calls to amp-api-edge.apps.apple.com
Add files via upload
```

Keep commit messages short and factual, describing the data source.

---

## What AI Assistants Should Know

### This Repo's Scope
- **In scope:** Updating CSV files with new/corrected App External IDs, improving documentation, fixing the shell script (without adding dependencies).
- **Out of scope:** Adding a build system, tests, CI/CD, or refactoring into a different format (e.g., JSON, database) unless explicitly requested.

### Data Integrity Rules
1. Never change `App Item ID` values — they are fixed MAS identifiers.
2. Never reorder rows (they are ordered oldest → newest by design).
3. Never delete placeholder rows.
4. Always maintain contiguous `Release Order` numbering.
5. Cite the data source in the `Notes / Source` column.

### Shell Script Rules
1. The script must remain dependency-free (macOS built-ins only).
2. BSD awk compatibility is required — no GNU awk extensions.
3. Do not use `[ \t]` bracket whitespace classes in awk.

### CSV Formatting
- No trailing commas.
- Preserve the header row exactly as-is.
- Do not quote fields unless the value contains a comma.
- UTF-8 encoding, Unix line endings (`LF`).
