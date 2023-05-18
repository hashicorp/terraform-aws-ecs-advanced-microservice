#!/bin/bash
set -x

# List repository workflows, and get the ID of the workflow named repo-init
ACTION_ID=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${OWNER}/${WAYPOINT_PROJECT_NAME}/actions/workflows" | jq '.workflows[] | select(.name=="repo-init") | .id ')

# Create a dispatch event for the repo-init workflow
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN"\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "https://api.github.com/repos/${OWNER}/${WAYPOINT_PROJECT_NAME}/actions/workflows/${ACTION_ID}/dispatches"