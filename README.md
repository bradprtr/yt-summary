# yt-summary.sh

A script which downloads transcripts of YouTube videos (using auto-generated or manually added subtitles) and summarises them using [**llm**](https://github.com/simonw/llm).

Requires [**yt-dlp**](https://github.com/yt-dlp/yt-dlp) and [**llm**](https://github.com/simonw/llm) to be installed and available in PATH. You'll also need to have [configured](https://llm.datasette.io/en/stable/setup.html) **llm** with your choice of model and API keys.

## Usage

Basic usage:
```bash
./yt-summary.sh <YouTube URL>
```

### Options

- `-k`: **Keep** the transcript txt file after processing
- `-s`: **Skip** LLM summarisation and keep transcript txt file
- `-p <prompt>`: Custom **prompt** for LLM (default: 'Summarise the provided YouTube transcript.')

### Examples

1. Basic usage - download and summarize:
```bash
./youtube-transcript.sh <YouTube URL>
```

2. Keep the transcript file:
```bash
./youtube-transcript.sh -k <YouTube URL>
```

3. Only download transcript (no summarization):
```bash
./youtube-transcript.sh -s <YouTube URL>
```

4. Custom summarization prompt:
```bash
./youtube-transcript.sh -p "List the key takeaway from this transcript as a haiku" <YouTube URL>
```

## Output Files

When using the `-k` or `-s` flags, the script generates a file named:
```
subtitles-{video_id}_{timestamp}.txt
```
in the current directory, containing the transcript.