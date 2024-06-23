#!/bin/bash

function main() {
  if [ "$#" -ne 1 ]; then
      echo "Usage: $0 <website>"
      exit 1
  fi

  repo_root=$(git rev-parse --show-toplevel)
  if npm --prefix "$repo_root/apps/evaluator" start -- "$1"; then
    echo "Program Complete."
  else
    echo "Program Error"
  fi
}

main "$@"
