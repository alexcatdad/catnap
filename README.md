# Catnap

macOS menubar dashboard for your local git repos. Scans a directory, shows live status, and enriches with GitHub data.

![Catnap — Compact, Expanded, and Loading states](assets/hero.png)

## Features

- **Click** the cat icon for a compact repo list — status dot, name, dirty indicator, relative time
- **Option+Click** for expanded view with GitHub descriptions
- **Click any repo** to open it on GitHub
- Collapsible category sections with persisted state
- Background polling (configurable interval)
- Skeleton loading state with shimmer animation
- GitHub description caching (refreshes daily)
- Settings popover for scan path, thresholds, and refresh interval

## Views

| Compact | Expanded | Loading |
|---------|----------|---------|
| ![Compact view](assets/compact.png) | ![Expanded view](assets/expanded.png) | ![Loading state](assets/loading.png) |

## Install

Requires macOS 14+ and Swift 6.

```bash
git clone https://github.com/alexcatdad/catnap.git
cd catnap
make run
```

This builds, bundles into a `.app`, ad-hoc codesigns, and opens it. A cat icon appears in your menubar.

## Usage

```bash
make run     # build + bundle + codesign + open
make build   # swift build only
make clean   # remove .build and .app
```

**Quit** via the power button in the popup footer, or `pkill Catnap`.

**Launch at login** — add `Catnap.app` to System Settings > General > Login Items.

## Configuration

Config lives at `~/.config/catnap/config.json`. Created automatically with defaults on first run, or editable via the gear icon in the popup.

```json
{
  "scanPath": "~/REPOS/alexcatdad",
  "githubOwner": "alexcatdad",
  "refreshIntervalMinutes": 5,
  "activeDays": 14,
  "staleDays": 60,
  "categories": {
    "Profile & Config": ["alexcatdad", "dotfiles", "paw"],
    "Developer Tools": ["paw-proxy", "meowtern"],
    "Infrastructure": ["shoyu-flux", "soy-sauce"]
  },
  "collapsedSections": []
}
```

| Field | Description |
|-------|-------------|
| `scanPath` | Directory to scan for git repos |
| `githubOwner` | GitHub username for repo links and `gh` enrichment |
| `refreshIntervalMinutes` | Background poll interval |
| `activeDays` | Repos with commits within N days are "active" (green) |
| `staleDays` | Repos with no commits for N days are "stale" (gray) |
| `categories` | Map of category names to repo name arrays |
| `collapsedSections` | Categories collapsed by default |

## Status Colors

- **Green** — active (commits within `activeDays`)
- **Gold** — in progress (between active and stale thresholds)
- **Gray** — stale (no commits for `staleDays`)

## Dependencies

- `/usr/bin/git` — repo scanning
- `/opt/homebrew/bin/gh` or `/usr/local/bin/gh` — GitHub enrichment (optional, falls back gracefully)

## Stack

Swift 6 / SwiftUI / SPM / MenuBarExtra / Observation framework

## License

MIT
