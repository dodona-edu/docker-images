#!/usr/bin/env bash
# Usage: [MOVES='{"python": {"from": "sha256:...", "to": "sha256:..."}}'] HEADER=<first line> EMPTY=<no-moves line> release-notes.sh > body.md
# Run from a full clone. MOVES unset or empty: every image whose :latest differs from :live. from is empty without a :live.
set -euo pipefail

: "${HEADER:?}" "${EMPTY:?}"

revision_of() {
  docker buildx imagetools inspect "$1" --format '{{json .Image}}' 2>/dev/null \
    | jq -r '.config.Labels["org.opencontainers.image.revision"] // empty' || true
}

# {{.Manifest.Digest}} silently renders the whole output, not the digest.
digest_of() {
  docker buildx imagetools inspect "$1" --format '{{json .Manifest}}' 2>/dev/null | jq -r '.digest // empty' || true
}

# Compressed bytes of the linux/amd64 image (config + layers), empty when unreadable.
size_of() {
  local repo=$1 digest=$2 raw manifest
  raw=$(docker buildx imagetools inspect --raw "$repo@$digest" 2>/dev/null) || return 0
  if jq -e '.manifests' >/dev/null 2>&1 <<<"$raw"; then
    manifest=$(jq -r '[.manifests[] | select(.platform.os == "linux" and .platform.architecture == "amd64")][0].digest // empty' <<<"$raw")
    [ -n "$manifest" ] || return 0
    raw=$(docker buildx imagetools inspect --raw "$repo@$manifest" 2>/dev/null) || return 0
  fi
  jq -r '[.config.size, (.layers[].size)] | add // empty' <<<"$raw" 2>/dev/null || true
}

mb() { awk -v b="$1" 'BEGIN { printf "%.1f MB", b / 1e6 }'; }

size_label() { if [ -n "$1" ]; then mb "$1"; else echo "size unknown"; fi; }

# size_text <new bytes> <previous bytes, empty for a new image>
size_text() {
  if [ -z "$1" ]; then echo "size unknown"
  elif [ -z "$2" ]; then echo "$(mb "$1") (new image)"
  else awk -v n="$1" -v o="$2" 'BEGIN {
    d = n - o; p = d * 100 / o
    if (d > -1e6 && d < 1e6) delta = sprintf("%+.1f kB", d / 1e3)
    else delta = sprintf("%+.1f MB", d / 1e6)
    if (p >= 0.1 || p <= -0.1) printf "%.1f MB (%s, %+.1f%%)", n / 1e6, delta, p
    else printf "%.1f MB (%s)", n / 1e6, delta
  }'
  fi
}

known_commit() { [ -n "$1" ] && git cat-file -e "$1^{commit}" 2>/dev/null; }

# A zero-width space after @ keeps PR titles from mentioning anyone.
zwsp=$'\xe2\x80\x8b'

no_prs="No merged PR changed this image's files between the two builds."

# PRs merged into dev reach master as one "from dodona-edu/dev" merge: skip it and
# list the PR merges inside it, whose first parent is dev itself.
# prs_for <image> <old rev> <new rev>
prs_for() {
  local image=$1 sha subject title number
  while IFS=$'\t' read -r sha subject; do
    [[ "$subject" =~ ^Merge\ pull\ request\ \#([0-9]+)\ from\ (.+)$ ]] || continue
    number=${BASH_REMATCH[1]}
    [ "${BASH_REMATCH[2]}" != dodona-edu/dev ] || continue
    git diff --quiet "$sha^1" "$sha" -- "dodona-$image.dockerfile" "dodona-$image" || {
      title=$(git log -1 --format=%b "$sha" | sed -n 1p)
      title=${title:-$subject}
      echo "- ${title//@/@$zwsp} (#$number)"
    }
  done < <(git log --merges --reverse --format='%H%x09%s' "$2..$3")
}

images=$(yq -r '.[]' images.yml)

declare -A live
for image in $images; do
  live[$image]=$(digest_of "ghcr.io/dodona-edu/dodona-$image:live")
done

moves=${MOVES:-}
if [ -z "$moves" ]; then
  moves='{}'
  for image in $images; do
    latest=$(digest_of "ghcr.io/dodona-edu/dodona-$image:latest")
    if [ -z "$latest" ]; then
      echo "::error::Could not read ghcr.io/dodona-edu/dodona-$image:latest" >&2
      exit 1
    fi
    if [ "$latest" != "${live[$image]}" ]; then
      moves=$(jq -c --arg i "$image" --arg f "${live[$image]}" --arg t "$latest" '. + {($i): {from: $f, to: $t}}' <<<"$moves")
    fi
  done
fi

if [ "$moves" = '{}' ]; then
  echo "$EMPTY"
  exit 0
fi

echo "$HEADER"
for image in $(jq -r 'keys[]' <<<"$moves"); do
  repo="ghcr.io/dodona-edu/dodona-$image"
  from=$(jq -r --arg i "$image" '.[$i].from' <<<"$moves")
  to=$(jq -r --arg i "$image" '.[$i].to' <<<"$moves")
  old_rev=""
  old_size=""
  if [ -n "$from" ]; then
    old_rev=$(revision_of "$repo@$from")
    old_size=$(size_of "$repo" "$from")
  fi
  new_rev=$(revision_of "$repo@$to")
  old_known=false
  new_known=false
  if known_commit "$old_rev"; then old_known=true; fi
  if known_commit "$new_rev"; then new_known=true; fi

  echo
  echo "### dodona-$image"
  echo
  echo "- digest: \`$to\`"
  echo "- previous digest: \`${from:-none}\`"
  echo "- size: $(size_text "$(size_of "$repo" "$to")" "$old_size")"
  echo
  if [ "$old_known" = true ] && [ "$new_known" = true ]; then
    prs=$(prs_for "$image" "$old_rev" "$new_rev")
    echo "${prs:-$no_prs}"
  else
    echo "No PR list: the previous or new revision is unknown to this repository."
  fi
done

moved=$(jq -r 'keys[]' <<<"$moves")
unchanged=$(grep -vxF -f <(echo "$moved") <<<"$images" || true)
if [ -n "$unchanged" ]; then
  echo
  echo "<details><summary>Unchanged images</summary>"
  echo
  for image in $unchanged; do
    if [ -n "${live[$image]}" ]; then
      echo "- dodona-$image: \`${live[$image]}\`, $(size_label "$(size_of "ghcr.io/dodona-edu/dodona-$image" "${live[$image]}")")"
    else
      echo "- dodona-$image: no \`:live\`"
    fi
  done
  echo
  echo "</details>"
fi
