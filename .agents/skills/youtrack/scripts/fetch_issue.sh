#!/usr/bin/env bash
set -euo pipefail

: "${YOUTRACK_BASE_URL:?Set YOUTRACK_BASE_URL}"
: "${YOUTRACK_TOKEN:?Set YOUTRACK_TOKEN}"

AUTH_HEADER="Authorization: Bearer ${YOUTRACK_TOKEN}"
ACCEPT_HEADER="Accept: application/json"

issue_fields='idReadable,summary,description,created,updated,customFields(name,value(name,text,login,fullName)),links(direction,linkType(name),issues(idReadable,summary)),subtasks(idReadable,summary,description),comments(id,text,created,updated,author(login,fullName))'
list_fields='idReadable,summary,description,updated,customFields(name,value(name,text))'
comment_fields='id,text,created,updated,author(login,fullName)'

usage() {
  cat <<USAGE
Usage:
  fetch_issue.sh ISSUE-123
  fetch_issue.sh --query '<YouTrack query>' [--top N]
  fetch_issue.sh --comments ISSUE-123 [--top N]
USAGE
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

if [[ "$1" == "--query" ]]; then
  [[ $# -ge 2 ]] || { usage; exit 1; }
  query="$2"
  top="20"

  if [[ "${3:-}" == "--top" ]]; then
    top="${4:-20}"
  fi

  curl -sS \
    -H "$AUTH_HEADER" \
    -H "$ACCEPT_HEADER" \
    --get "${YOUTRACK_BASE_URL}/api/issues" \
    --data-urlencode "query=${query}" \
    --data-urlencode "fields=${list_fields}" \
    --data-urlencode "\$top=${top}"
  exit 0
fi

if [[ "$1" == "--comments" ]]; then
  [[ $# -ge 2 ]] || { usage; exit 1; }
  issue_key="$2"
  top="50"

  if [[ ! "$issue_key" =~ ^[A-Z][A-Z0-9]+-[0-9]+$ ]]; then
    echo "Invalid issue key: $issue_key" >&2
    exit 2
  fi

  if [[ "${3:-}" == "--top" ]]; then
    top="${4:-50}"
  fi

  curl -sS \
    -H "$AUTH_HEADER" \
    -H "$ACCEPT_HEADER" \
    --get "${YOUTRACK_BASE_URL}/api/issues/${issue_key}/comments" \
    --data-urlencode "fields=${comment_fields}" \
    --data-urlencode "\$top=${top}"
  exit 0
fi

issue_key="$1"
if [[ ! "$issue_key" =~ ^[A-Z][A-Z0-9]+-[0-9]+$ ]]; then
  echo "Invalid issue key: $issue_key" >&2
  exit 2
fi

curl -sS \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER" \
  "${YOUTRACK_BASE_URL}/api/issues/${issue_key}?fields=${issue_fields}"
