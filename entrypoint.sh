#!/bin/bash
set -e

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Set the GITHUB_TOKEN env variable."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Set the GITHUB_REPOSITORY env variable."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Set the GITHUB_EVENT_PATH env variable."
  exit 1
fi

addLabel=$ADD_LABEL
if [[ -z "$ADD_LABEL" ]]; then
  echo "Set the ADD_LABEL env variable."
  exit 1
fi

color=$LABEL_COLOR
if [[ -z "$color" ]]; then
  echo "Use default color."
  color="#0E8A16"
fi

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
state=$(jq --raw-output .review.state "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

label_when_approved() {
  # https://developer.github.com/v3/pulls/reviews/#list-reviews-on-a-pull-request
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
  reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

  approvals=0

  #Get all labels in current project
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/labels")
  names=$(echo "$body" | jq --raw-output '.[] | .name')

  for r in $reviews; do
    review="$(echo "$r" | base64 -d)"
    rState=$(echo "$review" | jq --raw-output '.state')

    if [[ "$rState" == "APPROVED" ]]; then
      approvals=$((approvals+1))
    fi

    echo "${approvals}/${APPROVALS} approvals"

    if [[ "$approvals" -ge "$APPROVALS" ]]; then
      echo "Labeling pull request"

      #If label of this name does not exist
      if [[ !($(echo "$names" | grep -w "$addLabel")) ]]; then
          curl -sSL \
            -H "${AUTH_HEADER}" \
            -H "${API_HEADER}" \
            -X POST \
            -H "Content-Type: application/json" \
            -d "{\"name\":\"${addLabel}\",\"color\":\"${color}\"}" \
            "${URI}/repos/${GITHUB_REPOSITORY}/labels"
      fi

      curl -sSL \
        -H "${AUTH_HEADER}" \
        -H "${API_HEADER}" \
        -X POST \
        -H "Content-Type: application/json" \
        -d "{\"labels\":[\"${addLabel}\"]}" \
        "${URI}/repos/${GITHUB_REPOSITORY}/issues/${number}/labels"

      break
    fi
  done
}

if [[ "$action" == "submitted" ]] && [[ "$state" == "approved" ]]; then
  label_when_approved
else
  echo "Ignoring event ${action}/${state}"
fi
