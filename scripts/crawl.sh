#!/bin/bash

function normalize_url() {
    local normalized=$(echo $1 | sed -E "s/#.*$//g" | sed -E "s/\?.*$//g")
    echo "Normalized URL: $normalized"  # Displays the URL after removing fragment and query.
    echo $normalized
}

function parse_page() {
    local url=$1
    local parent_page=$2
    local filename=$(echo $url | sed -E 's/[\/:]/_/g')

    echo "Processing URL: $url"

    # Avoid re-downloading and re-parsing the same page
    if [ ! -e "${TMP_DIR}/${filename}" ]; then
        wget -q -O "${TMP_DIR}/${filename}" "$url"
        echo "Downloaded: $url"
    else
        echo "Already downloaded: $url"  # Indicates the URL was previously downloaded and is being skipped.
    fi

    local title=$(grep -oE '<title>[^<]*</title>' "${TMP_DIR}/${filename}" | sed -E 's/<title>([^<]*)<\/title>/\1/')
    echo "Found title: $title"

    if [ ! -e "${TMP_DIR}/titles_${filename}" ]; then
        echo "$title"
        touch "${TMP_DIR}/titles_${filename}"
    fi
    echo "  $parent_page" >> "${TMP_DIR}/report_${title}"

    grep -oE 'href="[^"]*' "${TMP_DIR}/${filename}" | sed -E 's/href="//' | while read -r link; do
        local full_link=$(normalize_url "$link")
        echo "Checking link: $link -> $full_link"
        if [[ "$full_link" =~ ^${BASE_URL} ]]; then
            parse_page "$full_link" "$title"
        fi
    done
}

function main() {
  if [ "$#" -ne 1 ]; then
      echo "Usage: $0 <website>"
      exit 1
  fi

  echo "Starting crawl on: $1"
  BASE_URL=$1
  [[ "${BASE_URL}" != */ ]] && BASE_URL="${BASE_URL}/"
  echo "Normalized base URL: $BASE_URL"
  TMP_DIR=$(mktemp -d)
  echo "Temporary files stored in: $TMP_DIR"

  parse_page "$BASE_URL" "Home Page"

  echo "Generating report..."
  find "${TMP_DIR}" -name "report_*" | while read -r report_file; do
      cat "$report_file"
  done

  echo "Cleaning up temporary files..."
  rm -rf "$TMP_DIR"
  echo "Done."
}

main "$@"
