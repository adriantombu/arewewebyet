#!/bin/bash

#
# Usage: ./scripts/check_criterias.sh "<GITHUB_TOKEN>" "<GITLAB_TOKEN>"
#
# - Generate a Github personal access token on https://github.com/settings/tokens
# - Generate a Gitlab personal access token on https://gitlab.com/-/user_settings/personal_access_tokens
GITHUB_TOKEN="$1"
GITLAB_TOKEN="$2"

CRATE_REGEX='^[[:space:]]{1,2}"([A-Za-z0-9_-]+)",?'
EXCLUDE_CRATE="Facebook"
SEARCH_DIR=content/topics
DUPLICATES=()
MIN_RECENT_DOWNLOADS=4000
DEPRECATED_WORDS=("unmaintained" "deprecated" "discontinued" "no longer maintained")

# Retrieve all crates present in the project
for entry in "$SEARCH_DIR"/*.md
do
  while IFS= read -r line; do
    if [[ "$line" =~ $CRATE_REGEX ]]; then
      DUPLICATES+=("${BASH_REMATCH[1]}")
    fi
  done < "$entry"
done

# Remove duplicates
CRATES=($(for crate in "${DUPLICATES[@]/$EXCLUDE_CRATE}"; do echo "${crate}"; done | sort -u))

echo "Checking ${#CRATES[@]} crates:"

for crate in "${CRATES[@]}"; do
  echo "- $crate"

  #
  # The package must have at least 4k recent downloads on crates.io
  DATA=$(curl -s -H "Accept:application/json" "https://crates.io/api/v1/crates/$crate")
  RECENT_DOWNLOADS=$(jq -r '.crate.recent_downloads' <<< "$DATA")
  REPOSITORY=$(jq -r '.crate.repository' <<< "$DATA")
  REPOSITORY=${REPOSITORY%.git} # Remove .git suffix
  REPOSITORY=${REPOSITORY%/} # Remove trailing slash
  DESCRIPTION=$(jq -r '.crate.description' <<< "$DATA")

  if [ "$RECENT_DOWNLOADS" -lt $MIN_RECENT_DOWNLOADS ]; then
    echo "** crate has less than 4k recent downloads on crates.io"
  fi

  for word in "${DEPRECATED_WORDS[@]}"; do
    lower=$(echo "$DESCRIPTION" | tr "[:upper:]" "[:lower:]")

    if [[ "$lower" == *"$word"* ]]; then
      echo "** crate may be deprecated or unmaintained"
    fi
  done

  #
  # The package's repository is not archived
  OWNER_REPO="${REPOSITORY#https://github.com/}"
  ENCODED_OWNER_REPO="${OWNER_REPO//\//%2F}"

  if [[ "$REPOSITORY" == *"github.com"* ]]; then
    DATA=$(curl -s -H "Accept:application/json" -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER_REPO")
    STATUS=$(jq -r '.status' <<< "$DATA")
    if [ "$STATUS" != null ]; then
      echo "** unable to retrieve api github data from ${REPOSITORY}"
    fi

    ARCHIVED=$(jq -r '.archived' <<< "$DATA")
  elif [[ "$REPOSITORY" == *"bitbucket.org"* ]]; then
    #DATA=$(curl -s -H "Accept:application/json" "https://api.bitbucket.org/2.0/repositories/$OWNER_REPO")
    # No "archived" status on Bitbucket: https://jira.atlassian.com/browse/BCLOUD-18018
    ARCHIVED="false"
  elif [[ "$REPOSITORY" == *"gitlab.com"* ]]; then
    DATA=$(curl -s -H "Accept:application/json" -H "Authorization: Bearer $GITLAB_TOKEN" "https://gitlab.com/api/v4/projects/$ENCODED_OWNER_REPO")
    MESSAGE=$(jq -r '.message' <<< "$DATA")
    if [ "$MESSAGE" != null ]; then
      echo "** unable to retrieve api gitlab data from ${REPOSITORY}"
    fi

    ARCHIVED=$(jq -r '.archived' <<< "$DATA")
  else
    echo "** unknown repository type for: $REPOSITORY"
  fi

  if [ "$ARCHIVED" == "true" ]; then
    echo "** repository is archived"
  fi

  # TODO
  #
  # The package is not flagged as unmaintained in https://rustsec.org/

  sleep .5
done
