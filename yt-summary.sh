#!/bin/bash

# Usage function
usage() {
  echo "Usage: $0 [-k] [-s] [-p prompt] <YouTube URL>"
  echo "  -k: Keep transcript txt file"
  echo "  -s: Skip LLM summarisation and keep transcript txt file"
  echo "  -p: Custom prompt for LLM (default: 'Summarise the provided YouTube transcript.')"
  exit 1
}

# Initialize variables
keep_files=false
skip_llm=false
prompt_string="-t fabric:summarize"
custom_prompt=false

# Parse command-line options
while getopts "ksp:" opt; do
  case "$opt" in
    k) keep_files=true ;;
    s) skip_llm=true; keep_files=true ;;
    p)
      if [ -z "$OPTARG" ]; then
        echo "Error: -p option requires a non-empty string argument." >&2
        usage
      fi
      prompt_string="$OPTARG"
      custom_prompt=true
      ;;
    :)
      if [ "$OPTARG" = "p" ]; then
        echo "Error: -p option requires a non-empty string argument." >&2
      else
        echo "Error: Option -$OPTARG requires an argument." >&2
      fi
      usage
      ;;
    \?) echo "Invalid option: -$OPTARG" >&2; usage ;;
  esac
done

shift $((OPTIND-1))

# Check if YouTube URL is provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a YouTube video URL." >&2
    usage
fi

youtube_url="$1"

# Validate YouTube URL format
if ! [[ "$youtube_url" =~ ^https?://((www\.)?youtube\.com/watch\?v=|youtu\.be/).+ ]]; then
    echo "Error: Invalid YouTube URL format." >&2
    exit 1
fi

# Warning for -p with -s
if [ "$skip_llm" = true ] && [ "$custom_prompt" = true ]; then
  echo "Warning: Custom prompt provided with -p will be ignored as LLM is skipped (-s flag)." >&2
fi

# Create temporary directory
temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

# Check for required commands
check_command() {
    if ! command -v "$1" > /dev/null 2>&1; then
        echo "Error: $1 is not installed or not in the system PATH." >&2
        echo "Please install $1 and try again." >&2
        exit 1
    fi
}

check_command yt-dlp
if [ "$skip_llm" = false ]; then
    check_command llm
fi

# Function to download subtitles
download_subtitles() {
    local url="$1"
    local output_template="$2"
    local lang="$3"

    echo "Attempting to download ${lang:-any} subtitles..."
    if [ -n "$lang" ]; then
        yt-dlp --skip-download --write-subs --write-auto-subs --sub-lang "$lang" \
               --sub-format ttml --convert-subs srt --output "$output_template" "$url"
    else
        yt-dlp --skip-download --write-subs --write-auto-subs --sub-format ttml \
               --convert-subs srt --output "$output_template" "$url"
    fi
}

# Get video ID
video_id=$(yt-dlp --get-id "$youtube_url")
video_id=${video_id//[^a-zA-Z0-9-]/}

# Download subtitles
output_template="$temp_dir/subtitles-${video_id}.%(ext)s"
if ! download_subtitles "$youtube_url" "$output_template" "en"; then
    if ! download_subtitles "$youtube_url" "$output_template"; then
        echo "Error: Failed to download any subtitles. Exiting." >&2
        exit 1
    fi
fi

# Find and process the SRT file
srt_file=$(find "$temp_dir" -name "subtitles-${video_id}*.srt" | head -n 1)
if [ -z "$srt_file" ]; then
    echo "Error: No subtitles file found." >&2
    exit 1
fi

# Clean up the SRT file and convert to plain text
sed -E \
    -e '/^[0-9]+$/d' \
    -e '/^[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3} --> [0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{3}$/d' \
    -e 's/<[^>]*>//g' \
    -e '/^$/d' \
"$srt_file" | iconv -f UTF-8 -t UTF-8//IGNORE > "$temp_dir/subtitles-${video_id}.txt"

# Remove intermediate files
rm -f "$srt_file"

# Run LLM if not skipped
if [ "$skip_llm" = false ]; then
    cat "$temp_dir/subtitles-${video_id}.txt" | llm -m claude-3.5-haiku "${prompt_string}"
else
    echo "LLM summarisation skipped. Transcript saved as subtitles-${video_id}.txt"
fi

# Handle file keeping/saving
if [ "$keep_files" = true ]; then
    timestamp=$(date +%H%M%S)
    cp "$temp_dir/subtitles-${video_id}.txt" "./subtitles-${video_id}_${timestamp}.txt"
    echo "Transcript saved as subtitles-${video_id}_${timestamp}.txt in the current directory."
fi

# Note: The temp_dir and its contents will be automatically removed by the trap command on script exit
