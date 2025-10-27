#!/bin/bash
set -eou pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <profile-name> <dockerfile-url>"
  exit 1
fi

PROFILE_NAME="$1"
DOCKERFILE_URL="$2"
PROFILE_SCRIPT="/etc/profile.d/init/${PROFILE_NAME}.sh"

mkdir -p "$(dirname "$PROFILE_SCRIPT")"

DOCKERFILE_ENVS="$(
    curl -s "$DOCKERFILE_URL" |
    awk '
        /^ENV / {
            line = $0
            while (sub(/\\$/, "", line)) {
                getline cont
                sub(/^[[:space:]]*/, "", cont)
                line = line "\nENV " cont
            }
            print line
        }
    '
)"

: > $PROFILE_SCRIPT

printf '%s\n' "$DOCKERFILE_ENVS" | while read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Extract key and value — handle both `KEY VALUE` and `KEY=VALUE`
    rest="${line#ENV }"
    if [[ "$rest" =~ ^([^[:space:]=]+)[[:space:]]+(.*)$ ]]; then
        key="${BASH_REMATCH[1]}"
        val="${BASH_REMATCH[2]}"
    elif [[ "$rest" =~ ^([^=]+)=(.*)$ ]]; then
        key="${BASH_REMATCH[1]}"
        val="${BASH_REMATCH[2]}"
    else
        continue
    fi

    # Handle PATH specially: don't expand or eval
    if [[ "$key" == "PATH" ]]; then
        val="${val//'${PATH}'/\$PATH}"
        val="${val//'$PATH'/"__PATH_MARKER__"}"
        IFS=':' read -ra segments <<< "$val"

        before_path=()
        after_path=()
        seen_path=false

        for seg in "${segments[@]}"; do
            seg="${seg//\"/}"
            seg="${seg//\'/}"
            seg="${seg// /}"

            [[ -z "$seg" ]] && continue
            if [[ "$seg" == "__PATH_MARKER__" ]]; then
                seen_path=true
                continue
            fi

            if ! $seen_path; then
                before_path+=("$seg")
            else
                after_path+=("$seg")
            fi
        done

        for (( idx=${#before_path[@]}-1 ; idx>=0 ; idx-- )); do
            seg="${before_path[idx]}"
            [[ -z "$seg" ]] && continue
            printf 'if [[ ":$PATH:" != *":%s:"* ]]; then export PATH="%s:$PATH"; fi\n' "$seg" "$seg" >> "$PROFILE_SCRIPT"
        done

        for seg in "${after_path[@]}"; do
            [[ -z "$seg" ]] && continue
            printf 'if [[ ":$PATH:" != *":%s:"* ]]; then export PATH="$PATH:%s"; fi\n' "$seg" "$seg" >> "$PROFILE_SCRIPT"
        done
    else
        # Expand variable only if not already set
        eval "export $key=\"\${$key:-$val}\""
        printf 'export %s="%s"\n' "$key" "$(printenv "$key" || echo "")" >> "$PROFILE_SCRIPT"
    fi
done

echo "$PROFILE_SCRIPT"