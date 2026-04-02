# Engen Modernization Spec

## What Engen Is

A bash-based environment generator that creates standardized development
workspaces with directory trees, automated tool installations, and git repo
management. Think of it as `dotfiles` meets `brew bundle` meets project
scaffolding — all in one interactive CLI.

---

## Current State Assessment

### What Works Well
- Directory tree creation from config files
- Environment selection and context passing (engen.sh → main.sh)
- Git operations (clone, status, update, create/delete repos via gh CLI)
- VS Code extension management (51 extensions, smart diffing)
- Program installation menu with 23 Linux tools
- OS detection and multi-platform branching
- Profile modification pattern (idempotent exports to ~/.profile)

### What's Broken or Incomplete
| Issue | File | Severity |
|-------|------|----------|
| `cleanup_installs.sh` is empty | utils/cleanup/cleanup_installs.sh | **High** — core feature missing |
| `build_config_file()` param bug — uses `${root_dir_name}` instead of `$1` | utils/helpers/helpers.sh:30 | **High** — breaks config lookup |
| `sed` version incompatibility (GNU vs BSD) | env-creation/generate_config_file.sh | **Medium** — breaks on macOS |
| `which` used instead of `command -v` | programs-to-install/linux/dev_tools_installs.sh | **Medium** — unreliable |
| `readlink -m` invalid on macOS | env-creation/generate_directory_tree.sh | **Medium** — breaks path resolution |
| Theme.sh function defined but not in FUNCTIONS_ARRAY | programs-to-install/linux/dev_tools_installs.sh | **Low** — dead code |
| Typo: `sudo apt-get istall` (line 174) | programs-to-install/linux/dev_tools_installs.sh | **Low** — breaks htop install |
| `tokenFile.txt` hardcoded path, not gitignored | utils/git-utils/tokenFile.txt | **Low** — security concern |
| Help menu incomplete | main.sh, engen.sh | **Low** — UX gap |
| v2 Python rewrite abandoned mid-skeleton | v2/ | **N/A** — we'll modernize v1 instead |

### Config Format Problem

The current config (`.engenrc_template`) is a bash script that gets sourced.
This works but is fragile:
- Users must understand bash array syntax
- sed-based templating breaks across OS versions
- DIR_ARRAY, CORRESPONDING_PROJECTS_ARRAY, and DIR_NAMES_ARRAY must stay
  in sync by index — one misalignment breaks everything
- No validation possible without sourcing (which executes arbitrary code)

---

## Modernization Plan

### 1. New Config Format — JSON Tree

Replace the bash-sourced config with a JSON file that represents the directory
tree as a nested structure. Repos are attached to the directories they belong in.

**Before** (bash arrays that must stay index-aligned):
```bash
BASE_DIR_ARRAY=(${CHALLENGES} ${JAVA_CHALLENGES} ${JS_CHALLENGES})
DIR_ARRAY=(${JS_CHALLENGES})
CORRESPONDING_PROJECTS_ARRAY=("my-js-project")
DIR_NAMES_ARRAY=("JS Challenges")
```

**After** (JSON tree — structure IS the directory tree):
```json
{
  "name": "dev-workspace",
  "path": "~/Projects/dev-workspace",
  "git": {
    "username": "vnly",
    "email": "vnly@email.com"
  },
  "tree": {
    "Challenges": {
      "Java": {},
      "JS": {
        "_repos": ["my-js-project", "leetcode-solutions"]
      },
      "Python": {
        "_repos": ["py-algorithms"]
      },
      "Rust": {}
    },
    "Projects": {
      "Web": {
        "_repos": ["portfolio-site"]
      },
      "Tools": {}
    },
    "Scripts": {
      "Bash": {},
      "Python": {}
    }
  },
  "tools": {
    "installed": [],
    "available": []
  }
}
```

**Benefits**:
- The tree structure IS the directory tree — no index alignment needed
- `_repos` arrays are co-located with their directories
- JSON is parseable without sourcing (no arbitrary code execution)
- Validatable with `python3 -c "import json; json.load(open('config.json'))"`
- Tools section tracks what was installed for cleanup
- The v2 skeleton already proposed this format — we're completing the vision

**Parser**: `python3` for JSON parsing (available on all target platforms),
or `jq` if available. The bash script calls python3 one-liners to extract
values — no full Python rewrite needed.

### 2. Config File Location & Naming

**Current**: `~/.engenrc_{NAME}` — dotfiles scattered in home directory
**New**: `~/.config/engen/{NAME}.json` — XDG-compliant, organized

The migration path:
1. Check for old `.engenrc_*` files
2. Offer to convert them to JSON format
3. New environments use JSON from the start

### 3. Cleanup — Install Removal

The missing `cleanup_installs.sh` needs to:

#### Track what was installed
When a tool is installed via engen, record it in the config JSON:
```json
"tools": {
  "installed": [
    {"name": "vim", "method": "apt", "installed_at": "2026-04-02"},
    {"name": "nvm", "method": "curl-script", "installed_at": "2026-04-02"},
    {"name": "rust", "method": "rustup", "installed_at": "2026-04-02"}
  ]
}
```

#### Selective removal
```
╔══════════════════════════════════════════╗
║  Cleanup — Remove Installed Tools        ║
╠══════════════════════════════════════════╝
║
║  [0] vim         (apt)
║  [1] nvm         (curl-script)
║  [2] rust        (rustup)
║  [3] vscode      (snap)
║
║  Enter numbers (space-separated) or "all"
```

#### Removal methods by install method
| Install method | Removal command |
|---------------|----------------|
| `apt` | `sudo apt-get remove -y {name}` |
| `snap` | `sudo snap remove {name}` |
| `brew` | `brew uninstall {name}` |
| `curl-script` | Custom per-tool (e.g., `rustup self uninstall`) |
| `npm-global` | `npm uninstall -g {name}` |
| `manual` | Display manual removal instructions |

Each `check_and_install_*` function gets a corresponding `uninstall_*` function.
The install function records the method used, so cleanup knows how to reverse it.

### 4. Directory Tree Cleanup — Selective

**Current**: Can remove entire environments but not individual directories.

**New**: Selective cleanup matching the JSON tree:
```
╔══════════════════════════════════════════╗
║  Cleanup — Remove Directories            ║
╠══════════════════════════════════════════╝
║
║  Environment: dev-workspace
║
║  [0] Challenges/
║  [1]   Java/
║  [2]   JS/ (2 repos)
║  [3]   Python/ (1 repo)
║  [4]   Rust/
║  [5] Projects/
║  [6]   Web/ (1 repo)
║  [7]   Tools/
║  [8] Scripts/
║
║  Enter numbers, "all", or "env" (whole environment)
```

Removing a parent directory removes all children. The config JSON is updated
to reflect the removal.

### 5. Tool Installation — Modernized

#### Docker-based tools (new)
Many tools that were installed system-wide can now be containerized:
```json
"tools": {
  "containerized": [
    {"name": "postgres", "image": "postgres:16-alpine", "ports": ["5432:5432"]},
    {"name": "mongodb", "image": "mongo:7", "ports": ["27017:27017"]},
    {"name": "redis", "image": "redis:alpine", "ports": ["6379:6379"]}
  ]
}
```

The install function for containerized tools:
1. Check if Docker is installed
2. `docker pull {image}`
3. Create a docker-compose.yml in `~/.config/engen/containers/`
4. `docker compose up -d`

#### Updated tool list
Remove outdated tools, add modern ones:

**Remove**: Robo3t (discontinued), MongoDB Compass (use Docker), Grub Customizer
(niche), Theme.sh (unused)

**Add**: Docker, Docker Compose, lazydocker, lazygit, ripgrep, fd, bat, fzf,
starship prompt, tmux, Claude Code CLI, zoxide, eza (modern ls)

**Keep**: Vim, VS Code, Rust, NVM, htop, tree, curl

### 6. Credential Security & Git Setup

#### Current Problems Found

| Issue | Location | Severity |
|-------|----------|----------|
| `vanely` username hardcoded in todo.txt examples | todo.txt:6-10 | Low (docs only) |
| `/home/vnly/` hardcoded in test files | utils/test_files/ | Low (test only) |
| `tokenFile.txt` in repo, not gitignored | utils/git-utils/tokenFile.txt | **High** |
| Git credentials stored in config template | config-file-templates/ROOT_ENV_CONFIG_template.sh | **Medium** |
| `clone_git_repo()` assumes HTTPS + public repos | utils/git-utils/git_utils.sh:28 | **Medium** |
| No `.gitignore` for sensitive files | .gitignore only has .DS_Store and .vscode | **High** |
| `CURRENT_GIT_USER_NAME` baked into config files | env-creation/generate_config_file.sh | **Medium** |

#### Fix: Git Credential Setup Flow

The git setup flow should be fully interactive with no hardcoded values.
Replace the current `config_git_creds_and_auth()` in `initial_checks.sh`:

**New flow**:
```
╔══════════════════════════════════════════╗
║  Git Configuration                       ║
╠══════════════════════════════════════════╝
║
║  Checking ~/.gitconfig...
║
║  GitHub username: [vnly_          ] ✓ (found)
║  GitHub email:    [v@email.com    ] ✓ (found)
║
║  Credential helper: git-credential-store
║
║  GitHub Authentication:
║  To clone private repos, you need a
║  Personal Access Token (PAT):
║
║  1. Go to: github.com/settings/tokens
║  2. Generate new token (classic)
║  3. Select scopes: repo, read:org
║  4. Copy the token
║
║  Paste token (or Enter to skip): [•••••] ✓
║
║  ✓ Authenticated via gh CLI
```

**Implementation**:
```bash
setup_git_credentials() {
    local git_user="" git_email=""

    # Try to read from existing gitconfig
    if [ -f "$HOME/.gitconfig" ]; then
        git_user=$(git config --global user.name 2>/dev/null || echo "")
        git_email=$(git config --global user.email 2>/dev/null || echo "")
    fi

    # Prompt for username (pre-fill from gitconfig)
    echo -ne "  GitHub username"
    [ -n "$git_user" ] && echo -ne " [$git_user]"
    echo -ne ": "
    read -r input_user
    [ -n "$input_user" ] && git_user="$input_user"

    # Prompt for email (pre-fill from gitconfig)
    echo -ne "  GitHub email"
    [ -n "$git_email" ] && echo -ne " [$git_email]"
    echo -ne ": "
    read -r input_email
    [ -n "$input_email" ] && git_email="$input_email"

    # Set git config
    git config --global user.name "$git_user"
    git config --global user.email "$git_email"
    git config --global credential.helper store

    # GitHub authentication
    echo ""
    echo "  To clone private repos, authenticate with GitHub:"
    echo "  1. Go to: https://github.com/settings/tokens"
    echo "  2. Generate new token (classic)"
    echo "  3. Select scopes: repo, read:org"
    echo "  4. Copy the token"
    echo ""
    echo -ne "  Paste token (or Enter to skip): "
    read -rs token
    echo ""

    if [ -n "$token" ]; then
        echo "$token" | gh auth login --with-token 2>/dev/null
        if gh auth status &>/dev/null; then
            echo "  ✓ Authenticated with GitHub"
        else
            echo "  ✗ Authentication failed — try: gh auth login"
        fi
    else
        echo "  Skipped — private repos won't be accessible"
    fi
}
```

**Key changes from current approach**:
- No `tokenFile.txt` stored in the repo
- Credentials read from `git config`, not parsed from `~/.gitconfig` with grep
- Token entered at runtime, passed directly to `gh auth login --with-token`
- If user skips token, public repos still work
- `credential.helper store` handles HTTPS password caching

#### Fix: Config File — No Credentials

The JSON config should NOT store git credentials. They belong in `~/.gitconfig`
and `gh auth`, not in the project config.

**Before** (bash config):
```bash
CURRENT_GIT_USER_NAME=vnly
CURRENT_GIT_EMAIL=vnly@email.com
```

**After** (JSON config):
```json
{
  "git": {
    "username": null,
    "email": null
  }
}
```

`null` means "read from git config at runtime". The username is only used for
constructing clone URLs (`https://github.com/{username}/{repo}.git`) and for
`gh repo list`. Both `git` and `gh` CLI already know the credentials.

Actually — we can simplify further. The clone function should use the repo
name only and let `gh` handle the URL:
```bash
gh repo clone {username}/{repo} {target_dir}
```
Or for repos with a known owner in the config:
```json
"_repos": [
    "my-project",
    "github.com/other-user/their-project"
]
```
Simple names clone from the authenticated user. Full URLs clone from anywhere.

#### Fix: .gitignore

```
.DS_Store
.vscode
*.token
tokenFile.txt
~/.config/engen/*.json
```

### 7. Bug Fixes

| Bug | Fix |
|-----|-----|
| `build_config_file()` param name | Change `${root_dir_name}` to `$1` |
| `which` for existence checks | Replace with `command -v` |
| `readlink -m` on macOS | Use `realpath` or bash-native `cd && pwd` |
| `sudo apt-get istall` typo | Fix to `install` |
| sed GNU vs BSD | Use `sed -i'' -e` (works on both) or inline bash substitution |
| Theme.sh not in array | Add to FUNCTIONS_ARRAY or remove function |
| tokenFile.txt security | Remove from repo, add to .gitignore |
| `/home/vnly/` in test files | Replace with `$HOME` or relative paths |
| `vanely` in todo.txt | Replace with generic examples |
| grep-based gitconfig parsing | Use `git config --global user.name` instead |
| HTTPS-only clone URLs | Use `gh repo clone` which handles auth automatically |

### 7. Config File Operations

#### Create new config
```bash
engen new my-project
# → Interactive: prompts for tree structure, repos, tools
# → Writes ~/.config/engen/my-project.json
# → Creates directory tree
# → Clones repos
```

#### Edit existing config
```bash
engen edit my-project
# → Opens config in $EDITOR
# → On save: diffs old vs new
# → Creates new directories, clones new repos
# → Warns about removed directories (doesn't delete without confirmation)
```

#### Sync config to filesystem
```bash
engen sync my-project
# → Reads config, creates missing dirs, clones missing repos
# → Reports what's on disk but not in config (orphans)
```

#### Import existing directory as config
```bash
engen import ~/Projects/my-existing-project
# → Scans directory tree
# → Detects git repos
# → Generates config JSON
```

### 8. Profile Management — Modernized

**Current**: Appends exports to `~/.profile`, sources in `~/.bashrc` and `~/.zshrc`.
This accumulates cruft over time.

**New**: Single managed block in shell rc files:
```bash
# --- engen managed block (do not edit) ---
export ENGEN_DIR="$HOME/.config/engen"
export PATH="$ENGEN_DIR/bin:$PATH"
for env in "$ENGEN_DIR"/*/; do
  [ -f "$env/config.json" ] && export "ENGEN_ENV_$(basename $env | tr '[:lower:]' '[:upper:]')=$env"
done
# --- end engen managed block ---
```

One block, one source line. `engen cleanup` removes it cleanly.

---

## Implementation Order

### Phase 1: Foundation
1. Create `~/.config/engen/` directory structure
2. Write JSON config parser (bash + python3 one-liners)
3. Write JSON config writer (for recording installations)
4. Migrate `.engenrc_template` to JSON template
5. Fix all bugs listed above
6. Add `.gitignore` for tokenFile.txt

### Phase 2: Core Features
7. Rewrite `generate_directory_tree.sh` to use JSON config
8. Rewrite `directories.sh` (update) to use JSON config
9. Implement `cleanup_installs.sh` with selective removal
10. Implement selective directory cleanup
11. Update tool installation to record install method in config
12. Add `engen new`, `engen edit`, `engen sync` commands

### Phase 3: Modernization
13. Add Docker-based tool installation
14. Update tool list (remove outdated, add modern)
15. Implement `engen import` for existing directories
16. Modernize profile management (managed block)
17. Add `--dry-run` flag to all destructive operations
18. Add `--verbose` flag for debug output

### Phase 4: Polish
19. Add help text for all commands (`engen --help`, `engen new --help`)
20. Add config validation (check JSON structure before using)
21. Add color-coded output consistently
22. Add progress indicators for long operations (cloning, installing)
23. Clean up or remove v2/ directory (concepts merged into v1)
24. Write updated README.md

---

## Backward Compatibility

- Old `.engenrc_*` configs continue to work
- `engen migrate` converts old configs to JSON
- `main.sh` detects config format and uses appropriate parser
- New features only available with JSON configs

---

## File Changes Summary

| File | Action |
|------|--------|
| `main.sh` | Add JSON config detection, new command routing |
| `engen.sh` | Add subcommand support (new, edit, sync, import, migrate) |
| `env-creation/generate_directory_tree.sh` | Rewrite for JSON config |
| `env-creation/generate_config_file.sh` | Generate JSON instead of bash |
| `env-creation/directories.sh` | Read from JSON config |
| `config-file-templates/.engenrc_template` | Keep for backward compat |
| `config-file-templates/config.template.json` | **New** — JSON template |
| `utils/cleanup/cleanup_installs.sh` | **Implement** — selective tool removal |
| `utils/cleanup/cleanup_dir_trees.sh` | Add selective directory removal |
| `utils/helpers/helpers.sh` | Fix build_config_file bug, add JSON helpers |
| `utils/helpers/validation.sh` | Add JSON validation |
| `programs-to-install/linux/dev_tools_installs.sh` | Fix typo, add uninstall functions, update tool list |
| `programs-to-install/dependencies/dependencies.sh` | Add Docker check |
| `utils/git-utils/git_utils.sh` | Fix tokenFile path |
| `.gitignore` | Add tokenFile.txt, *.json configs with secrets |
| `v2/` | Archive or remove (concepts merged) |
| `docs/modernization-spec.md` | **This file** |
