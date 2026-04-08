#!/bin/bash
# Claude Code session logger hook
# Records conversation content (prompts, thinking, outputs) to .uho directory

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract paths and metadata
PROJECT_DIR=$(echo "$INPUT" | jq -r '.cwd // ""')
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')

# Validate required fields
if [[ -z "$PROJECT_DIR" || -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
    exit 0
fi

# Setup output directory
UHO_DIR="${PROJECT_DIR}/.uho"
mkdir -p "$UHO_DIR"

# Get session slug from transcript (last entry with slug field)
SESSION_SLUG=$(tail -100 "$TRANSCRIPT_PATH" | jq -r 'select(.slug) | .slug' 2>/dev/null | tail -1)
if [[ -z "$SESSION_SLUG" || "$SESSION_SLUG" == "null" ]]; then
    SESSION_SLUG="session"
fi

# Generate output filename
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
OUTPUT_FILE="${UHO_DIR}/${TIMESTAMP}_${SESSION_SLUG}.md"

# Get session start time from first entry
SESSION_START=$(head -10 "$TRANSCRIPT_PATH" | jq -r 'select(.timestamp) | .timestamp' 2>/dev/null | head -1)
if [[ -z "$SESSION_START" || "$SESSION_START" == "null" ]]; then
    SESSION_START=$(date -Iseconds)
fi

# Start writing markdown
cat > "$OUTPUT_FILE" << EOF
# Session: ${SESSION_SLUG}

- **Date**: $(date '+%Y-%m-%d %H:%M:%S')
- **Project**: ${PROJECT_DIR}
- **Session ID**: ${SESSION_ID}

---

EOF

# Process transcript line by line
while IFS= read -r line; do
    TYPE=$(echo "$line" | jq -r '.type // ""' 2>/dev/null)

    case "$TYPE" in
        "user")
            # Extract user message
            CONTENT=$(echo "$line" | jq -r '.message.content // ""' 2>/dev/null)
            TIMESTAMP_RAW=$(echo "$line" | jq -r '.timestamp // ""' 2>/dev/null)

            # Handle array content (tool results)
            if [[ "$CONTENT" == "["* ]]; then
                CONTENT=$(echo "$line" | jq -r '.message.content[] | if .type == "text" then .text elif .type == "tool_result" then "[Tool Result]" else "" end' 2>/dev/null | head -1)
            fi

            # Skip empty or tool result only messages
            if [[ -z "$CONTENT" || "$CONTENT" == "[Tool Result]" || "$CONTENT" == "null" ]]; then
                continue
            fi

            # Format timestamp
            if [[ -n "$TIMESTAMP_RAW" && "$TIMESTAMP_RAW" != "null" ]]; then
                TIME_DISPLAY=$(echo "$TIMESTAMP_RAW" | sed 's/T/ /; s/\..*//' | cut -d' ' -f2)
            else
                TIME_DISPLAY="--:--:--"
            fi

            cat >> "$OUTPUT_FILE" << EOF
## User [$TIME_DISPLAY]

$CONTENT

EOF
            ;;

        "assistant")
            # Extract assistant message components
            TIMESTAMP_RAW=$(echo "$line" | jq -r '.timestamp // ""' 2>/dev/null)

            # Format timestamp
            if [[ -n "$TIMESTAMP_RAW" && "$TIMESTAMP_RAW" != "null" ]]; then
                TIME_DISPLAY=$(echo "$TIMESTAMP_RAW" | sed 's/T/ /; s/\..*//' | cut -d' ' -f2)
            else
                TIME_DISPLAY="--:--:--"
            fi

            # Check if this message has content
            HAS_CONTENT=$(echo "$line" | jq -r '.message.content | length' 2>/dev/null)
            if [[ "$HAS_CONTENT" == "0" || -z "$HAS_CONTENT" ]]; then
                continue
            fi

            # Extract thinking content
            THINKING=$(echo "$line" | jq -r '.message.content[]? | select(.type=="thinking") | .thinking // ""' 2>/dev/null)

            # Extract text output
            TEXT=$(echo "$line" | jq -r '.message.content[]? | select(.type=="text") | .text // ""' 2>/dev/null)

            # Extract tool uses
            TOOLS=$(echo "$line" | jq -r '.message.content[]? | select(.type=="tool_use") | "- **\(.name)**: \(.input | keys | join(", "))"' 2>/dev/null)

            # Skip if nothing to write
            if [[ -z "$THINKING" && -z "$TEXT" && -z "$TOOLS" ]]; then
                continue
            fi

            echo "## Claude [$TIME_DISPLAY]" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"

            # Write thinking section
            if [[ -n "$THINKING" && "$THINKING" != "null" ]]; then
                cat >> "$OUTPUT_FILE" << EOF
<details>
<summary>Thinking</summary>

$THINKING

</details>

EOF
            fi

            # Write text output
            if [[ -n "$TEXT" && "$TEXT" != "null" ]]; then
                cat >> "$OUTPUT_FILE" << EOF
### Output

$TEXT

EOF
            fi

            # Write tool usage
            if [[ -n "$TOOLS" && "$TOOLS" != "null" ]]; then
                cat >> "$OUTPUT_FILE" << EOF
### Tools Used

$TOOLS

EOF
            fi

            echo "---" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            ;;
    esac
done < "$TRANSCRIPT_PATH"

notify "Session logged: ${SESSION_SLUG}" 2>/dev/null || true

exit 0
