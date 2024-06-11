#!/bin/bash

# Check for website argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <website>"
    exit 1
fi

echo "Starting crawl on: $1"  # Indicates the script has started and shows the website being crawled.

# Initial URL
BASE_URL=$1

# Normalize the base URL to avoid issues with missing trailing slash
[[ "${BASE_URL}" != */ ]] && BASE_URL="${BASE_URL}/"

echo "Normalized base URL: $BASE_URL"  # Displays the normalized base URL.

# Create a directory for temporary files
TMP_DIR=$(mktemp -d)
echo "Temporary files stored in: $TMP_DIR"  # Shows the directory where temporary files are stored.

# Function to normalize URL
normalize_url() {
    local normalized=$(echo $1 | sed -E "s/#.*$//g" | sed -E "s/\?.*$//g")
    echo "Normalized URL: $normalized"  # Displays the URL after removing fragment and query.
    echo $normalized
}

# Function to parse HTML for links and titles
parse_page() {
    local url=$1
    local parent_page=$2
    local filename=$(echo $url | sed -E 's/[\/:]/_/g')

    echo "Processing URL: $url"  # Indicates which URL is currently being processed.

    # Avoid re-downloading and re-parsing the same page
    if [ ! -e "${TMP_DIR}/${filename}" ]; then
        wget -q -O "${TMP_DIR}/${filename}" "$url"
        echo "Downloaded: $url"  # Confirms the URL has been downloaded.
    else
        echo "Already downloaded: $url"  # Indicates the URL was previously downloaded and is being skipped.
    fi

    local title=$(grep -oE '<title>[^<]*</title>' "${TMP_DIR}/${filename}" | sed -E 's/<title>([^<]*)<\/title>/\1/')
    echo "Found title: $title"  # Displays the title found in the page.

    # Print the title of the page if not printed before
    if [ ! -e "${TMP_DIR}/titles_${filename}" ]; then
        echo "$title"  # Echo the title for report generation.
        touch "${TMP_DIR}/titles_${filename}"
    fi
    echo "  $parent_page" >> "${TMP_DIR}/report_${title}"

    # Find all links that are internal
    grep -oE 'href="[^"]*' "${TMP_DIR}/${filename}" | sed -E 's/href="//' | while read -r link; do
        local full_link=$(normalize_url "$link")
        echo "Checking link: $link -> $full_link"  # Shows the original link and the normalized version.

        # Follow only internal links that match the base url
        if [[ "$full_link" =~ ^${BASE_URL} ]]; then
            parse_page "$full_link" "$title"
        fi
    done
}

# Start crawling from the base URL
parse_page "$BASE_URL" "Home Page"

# Generate report
echo "Generating report..."  # Indicates the start of report generation.
find "${TMP_DIR}" -name "report_*" | while read -r report_file; do
    cat "$report_file"
done

# Clean up
echo "Cleaning up temporary files..."  # Notifies about cleanup process.
rm -rf "$TMP_DIR"
echo "Done."  # Indicates the script has finished executing.
