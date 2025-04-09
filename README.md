# yt-summary

A script which downloads transcripts of YouTube videos (using auto-generated or manually added subtitles) and summarises them using [**llm**](https://github.com/simonw/llm).

Requires [**yt-dlp**](https://github.com/yt-dlp/yt-dlp) and [**llm**](https://github.com/simonw/llm) to be installed and available in PATH. 

By default, the model currently uses Gemini 2.0 Flash, and the [Fabric Summarization](https://github.com/danielmiessler/fabric/tree/main/patterns/summarize) pattern. For these, you'll need to install the [llm-templates-fabric](https://github.com/simonw/llm-templates-fabric) and [llm-gemini](https://github.com/simonw/llm-gemini) plugins, and [configure](https://llm.datasette.io/en/stable/setup.html) **llm** with your API key.

```bash
llm install llm-templates-fabric llm-gemini
llm keys set gemini
```

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/bradprtr/yt-summary/refs/heads/main/yt-summary.sh
```

2. Make it executable:
```bash
chmod +x yt-summary.sh
```

## Usage

Basic usage:
```bash
./yt-summary.sh <YouTube URL>
```

### Options

- `-k`: **Keep** the transcript txt file after processing
- `-s`: **Skip** LLM summarisation and keep transcript txt file
- `-p <prompt>`: Custom **prompt** for LLM (default: 'Summarise the provided YouTube transcript.')
- `-m <model>`: LLM **model** to use (default: 'gemini-2.0-flash')

### Examples

1. Basic usage - download and summarize:
```bash
./yt-summary.sh <YouTube URL>
```

2. Keep the transcript file:
```bash
./yt-summary.sh -k <YouTube URL>
```

3. Only download transcript (no summarization):
```bash
./yt-summary.sh -s <YouTube URL>
```

4. Custom summarization prompt:
```bash
./yt-summary.sh -p "Summarise this YouTube transcript in a pirate voice" <YouTube URL>
```

5. Use a different model:
```bash
./yt-summary.sh -m "chatgpt-4o" <YouTube URL>
```

## Output Files

When using the `-k` or `-s` flags, the script generates a file named:
```
subtitles-{video_id}_{timestamp}.txt
```
in the current directory, containing the transcript.
