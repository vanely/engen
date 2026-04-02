#!/bin/bash

# ============================================================
# JSON helpers for engen config files
# Uses python3 for reliable JSON parsing (no jq dependency)
# ============================================================

if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required for JSON config support"
  echo "Install it with: sudo apt-get install python3"
  exit 1
fi

ENGEN_CONFIG_DIR="${HOME}/.config/engen"

ensure_config_dir() {
  mkdir -p "${ENGEN_CONFIG_DIR}"
}

# Validate a JSON file is well-formed
validate_json() {
  local json_file="${1}"
  if python3 -c "import json; json.load(open('${json_file}'))" 2>/dev/null; then
    echo "valid"
  else
    echo "invalid"
  fi
}

# Read a value from JSON config by dot-path
# arg1=json_file  arg2=dot_path (e.g., "name", "git.username")
json_read() {
  local json_file="${1}"
  local key_path="${2}"
  python3 << PYEOF
import json, sys
with open('${json_file}') as f:
    data = json.load(f)
keys = '${key_path}'.split('.')
val = data
for k in keys:
    if isinstance(val, dict) and k in val:
        val = val[k]
    else:
        sys.exit(1)
if val is None:
    print('')
elif isinstance(val, (dict, list)):
    print(json.dumps(val))
else:
    print(val)
PYEOF
}

# Write a value to JSON config by dot-path
# arg1=json_file  arg2=dot_path  arg3=value (JSON-encoded)
json_write() {
  local json_file="${1}"
  local key_path="${2}"
  local value="${3}"
  python3 -c "
import json, sys
config_file, key_path, value = sys.argv[1], sys.argv[2], sys.argv[3]
with open(config_file) as f:
    data = json.load(f)
keys = key_path.split('.')
obj = data
for k in keys[:-1]:
    obj = obj[k]
obj[keys[-1]] = json.loads(value)
with open(config_file, 'w') as f:
    json.dump(data, f, indent=2)
" "${json_file}" "${key_path}" "${value}"
}

# Append an item to a JSON array at a given dot-path
json_array_append() {
  local json_file="${1}"
  local key_path="${2}"
  local item="${3}"
  python3 -c "
import json, sys
config_file, key_path, item = sys.argv[1], sys.argv[2], sys.argv[3]
with open(config_file) as f:
    data = json.load(f)
keys = key_path.split('.')
obj = data
for k in keys:
    obj = obj[k]
obj.append(json.loads(item))
with open(config_file, 'w') as f:
    json.dump(data, f, indent=2)
" "${json_file}" "${key_path}" "${item}"
}

# Walk the JSON tree and output flat directory paths (one per line)
json_tree_to_paths() {
  local json_file="${1}"
  local home_dir="${HOME}"
  python3 << PYEOF
import json, os
with open('${json_file}') as f:
    data = json.load(f)
base = data.get('path', '').replace('~', '${home_dir}')

def walk(tree, parent):
    for key, val in tree.items():
        if key.startswith('_'):
            continue
        path = parent + '/' + key
        print(path)
        if isinstance(val, dict):
            walk(val, path)

walk(data.get('tree', {}), base)
PYEOF
}

# Walk the JSON tree and output repo entries as "dir_path repo_name" per line
json_tree_to_repos() {
  local json_file="${1}"
  local home_dir="${HOME}"
  python3 << PYEOF
import json
with open('${json_file}') as f:
    data = json.load(f)
base = data.get('path', '').replace('~', '${home_dir}')

def walk(tree, parent):
    for key, val in tree.items():
        if key == '_repos' and isinstance(val, list):
            for repo in val:
                print(parent + ' ' + repo)
        elif isinstance(val, dict):
            path = parent + '/' + key
            walk(val, path)

walk(data.get('tree', {}), base)
PYEOF
}

# List all config files in the engen config directory
list_configs() {
  ensure_config_dir
  for f in "${ENGEN_CONFIG_DIR}"/*.json; do
    [ -f "$f" ] || continue
    basename "$f" .json
  done
}

# Get the config file path for a named environment
get_config_path() {
  echo "${ENGEN_CONFIG_DIR}/${1}.json"
}

# Detect whether a config is JSON or legacy bash format
detect_config_format() {
  local config_file="${1}"
  if [[ "${config_file}" == *.json ]]; then
    echo "json"
  elif python3 -c "import json; json.load(open('${config_file}'))" 2>/dev/null; then
    echo "json"
  else
    echo "bash"
  fi
}

# Print the tree structure in a visual format for interactive display
json_tree_display() {
  local json_file="${1}"
  python3 << PYEOF
import json
with open('${json_file}') as f:
    data = json.load(f)

counter = [0]
def walk(tree, indent=0):
    for key, val in tree.items():
        if key.startswith('_'):
            continue
        repos = val.get('_repos', []) if isinstance(val, dict) else []
        suffix = ''
        if repos:
            suffix = f' ({len(repos)} repos)'
        print(f'  [{counter[0]}] {"  " * indent}{key}/{suffix}')
        counter[0] += 1
        if isinstance(val, dict):
            walk({k: v for k, v in val.items() if not k.startswith('_')}, indent + 1)

walk(data.get('tree', {}))
PYEOF
}

# Insert a directory path into the JSON tree structure
json_tree_add_dir() {
  local json_file="${1}"
  local dir_path="${2}"
  python3 -c "
import json, sys
config_file, path = sys.argv[1], sys.argv[2]
with open(config_file) as f:
    data = json.load(f)
parts = path.strip('/').split('/')
node = data['tree']
for part in parts:
    if part not in node:
        node[part] = {}
    node = node[part]
with open(config_file, 'w') as f:
    json.dump(data, f, indent=2)
" "${json_file}" "${dir_path}"
}

# Add a repo to a directory in the JSON tree
json_tree_add_repo() {
  local json_file="${1}"
  local dir_path="${2}"
  local repo_name="${3}"
  python3 -c "
import json, sys
config_file, path, repo = sys.argv[1], sys.argv[2], sys.argv[3]
with open(config_file) as f:
    data = json.load(f)
parts = path.strip('/').split('/')
node = data['tree']
for part in parts:
    if part not in node:
        node[part] = {}
    node = node[part]
if '_repos' not in node:
    node['_repos'] = []
if repo not in node['_repos']:
    node['_repos'].append(repo)
with open(config_file, 'w') as f:
    json.dump(data, f, indent=2)
" "${json_file}" "${dir_path}" "${repo_name}"
}

# Remove a directory from the JSON tree by index
json_tree_remove_by_index() {
  local json_file="${1}"
  local index="${2}"
  python3 << PYEOF
import json
with open('${json_file}') as f:
    data = json.load(f)

counter = [0]
target_key = [None]
target_parent = [None]

def walk(tree, parent_ref=None, parent_key=None):
    for key, val in list(tree.items()):
        if key.startswith('_'):
            continue
        if counter[0] == ${index}:
            target_key[0] = key
            target_parent[0] = tree
            return True
        counter[0] += 1
        if isinstance(val, dict):
            if walk(val, tree, key):
                return True
    return False

walk(data.get('tree', {}))
if target_parent[0] is not None and target_key[0] is not None:
    del target_parent[0][target_key[0]]

with open('${json_file}', 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
}
