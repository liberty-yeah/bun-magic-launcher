# Bun Magic Launcher ✨

A Bash-based launcher that makes it easy to run JavaScript, TypeScript, and Shell scripts in a Bun-powered environment.  
It provides a simple interactive menu, logging with timestamps, crash handling, and Zenity dialogs for a smoother developer experience.

---

## Features 🚀

* **Automatic Bun setup** Reads Bun installation path from `whereIsMyBunFolder.txt` file kept adjacent and adds it to `PATH`.
* **File discovery** Scans the current directory for `.js`, `.ts`, and `.sh` files (excluding itself).
* **Interactive menu** * If no files are found: choose between launching a terminal or selecting a file manually.  
    * If one file is found: option to auto-run it, open selector, or launch terminal.  
    * If multiple files are found: numbered menu to pick which script to run.
* **Execution logic** * Runs `.sh` files with `bash`.  
    * Runs `.js` / `.ts` files with `bun run`.  
    * Special handling for `server.js` / `server.ts`: detects `http://localhost:PORT` in output and shows a Zenity info dialog.
* **Logging** * All output is timestamped with `awk`.  
    * Logs are saved as `log_<filename>.txt` in the script’s directory.  
    * Crash exit codes are reported via Zenity error dialogs.
* **Terminal mode** Launches a custom Bash shell with a `(bun-env)` prompt.

---

## Requirements 📦

* **Bun** installed and its path written in `whereIsMyBunFolder.txt`.  
    *Example:* `/home/username/.bun/bin`
* **Zenity** for GUI dialogs (`sudo apt install zenity` on Debian/Ubuntu).
* **Bash** (already present on most Linux systems).

---

## Usage 🖥️

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/bun-magic-launcher.git
    cd bun-magic-launcher
    ```
2.  **Make the script executable:**
    ```bash
    chmod +x bun-magic.sh
    ```
3.  **Run it:**
    ```bash
    ./bun-magic.sh
    ```
4.  Follow the interactive menu to launch scripts or open a Bun terminal.

---

## Example Workflow 📑

1.  You can place this file anwhere or in the folder where your typescript or javascript is.
2.  Run this file in terminal with `./bun-magic.sh`.
3.  Now you can choose the option to either open a terminal, or a file picker, or ts/js/sh files if they are within same folder
4.  Selected file will run with bun automatically and you get Zenity info box when script starts and if there are errors.
5.  Logs are saved in `log_name_of_the_picked_file.txt`.

---
