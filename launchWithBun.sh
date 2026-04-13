#!/bin/bash
set -o pipefail

# Read bun folder path
BUN_DIR=$(realpath "$(cat whereIsMyBunFolder.txt)")
export PATH="$BUN_DIR:$PATH"

SELF="$(basename "$0")"

# Collect all js/ts/sh files in current directory (excluding itself)
mapfile -t FILES < <(find . -maxdepth 1 -type f \( -name "*.js" -o -name "*.ts" -o -name "*.sh" \) ! -name "$SELF" | sort)
COUNT=${#FILES[@]}

show_terminal() {
    exec bash --rcfile <(echo "PS1='(bun-env) \$ magicTerminalVer3~'")
}

open_file_selector() {
    FILE=$(zenity --file-selection --title="Select a file to run")
    if [ -n "$FILE" ]; then
        run_script "$FILE"
    else
        echo "No file selected."
    fi
}

run_script() {
    SELECTED="$1"
    fname=$(basename "$SELECTED")
    DIR=$(dirname "$SELECTED")
    cd "$DIR" || { zenity --error --title="Error" --text="Failed to cd into $DIR"; exit 1; }

    LOG_FILE="$DIR/log_${fname%.*}.txt"
    echo "Running $fname with bun magic..."

    if [[ "$fname" == *.sh ]]; then
        stdbuf -oL -eL bash "$SELECTED" 2>&1 \
        | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' \
        | tee "$LOG_FILE"
        EXIT_CODE=${PIPESTATUS[0]}
    elif [[ "$fname" == "server.js" || "$fname" == "server.ts" ]]; then
        stdbuf -oL -eL bun run "$SELECTED" 2>&1 \
        | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' \
        | tee "$LOG_FILE" | while read -r line; do
            echo "$line"
            if [[ "$line" =~ http://localhost:[0-9]+ ]]; then
                URL=$(echo "$line" | grep -o 'http://localhost:[0-9]\+')
                zenity --info --title="Server Started" --text="Detected server URL: $URL"
            fi
        done
        EXIT_CODE=${PIPESTATUS[0]}
    else
        stdbuf -oL -eL bun run "$SELECTED" 2>&1 \
        | awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0; fflush(); }' \
        | tee "$LOG_FILE"
        EXIT_CODE=${PIPESTATUS[0]}
    fi

    # Handle crash
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Process exited with code $EXIT_CODE" >> "$LOG_FILE"
        zenity --error --title="Execution Failed" --text="Process crashed with exit code $EXIT_CODE.\nSee log: $LOG_FILE"
    fi
}

if [ $COUNT -eq 0 ]; then
    echo "No js/ts/sh files found."
    echo "Options:"
    echo "1) Launch terminal"
    echo "2) Open file selector"
    read -p "Enter choice: " choice
    case $choice in
        1) show_terminal ;;
        2) open_file_selector ;;
        *) echo "Invalid choice." ;;
    esac

elif [ $COUNT -eq 1 ]; then
    fname=$(basename "${FILES[0]}")
    echo "Found single file: $fname"
    echo "Options:"
    echo "1) Launch terminal"
    echo "2) Open file selector"
    echo "3) Auto-launch $fname"
    read -p "Enter choice: " choice
    case $choice in
        1) show_terminal ;;
        2) open_file_selector ;;
        3) run_script "${FILES[0]}" ;;
        *) echo "Invalid choice." ;;
    esac

else
    echo "Available options:"
    echo "1) Launch terminal"
    echo "2) Open file selector"
    i=3
    for script in "${FILES[@]}"; do
        fname=$(basename "$script")
        echo "$i) $fname"
        i=$((i+1))
    done

    read -p "Enter choice: " choice
    if [[ $choice == 1 ]]; then
        show_terminal
    elif [[ $choice == 2 ]]; then
        open_file_selector
    elif [[ $choice =~ ^[0-9]+$ ]] && [ $choice -ge 3 ] && [ $choice -le $((COUNT+2)) ]; then
        SELECTED="${FILES[$((choice-3))]}"
        run_script "$SELECTED"
    else
        echo "Invalid choice."
    fi
fi

