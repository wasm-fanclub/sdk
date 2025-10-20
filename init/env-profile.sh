#!/bin/bash
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <profile-name> <dockerfile-url>"
  exit 1
fi

PROFILE_NAME="$1"
DOCKERFILE_URL="$2"
PROFILE_SCRIPT="/etc/profile.d/${PROFILE_NAME}.sh"

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
        # Write literal, preserve any $PATH reference as-is
        printf 'export PATH=%s\n' "$val" >> $PROFILE_SCRIPT
    else
        # Expand variable only if not already set
        eval "export $key=\"\${$key:-$val}\""
        printf 'export %s="%s"\n' "$key" "$(printenv "$key" || echo "")" >> $PROFILE_SCRIPT
    fi
done

echo $PROFILE_SCRIPT