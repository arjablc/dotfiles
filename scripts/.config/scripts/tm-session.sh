#!/bin/bash

# Your root project directory
PROJECT_ROOT="$HOME/Devl/"

# Additional important directories
EXTRA_DIRS=(
    "$HOME/Documents/notes_vault/"  # Obsidian vault
)

# Main function
main() {
    local selected

    if [[ $# -eq 1 ]]; then
        # If directory passed as argument, use it
        selected=$1
    else
        # Find all directories under project root (2 levels deep to get actual projects)
        # Plus any extra directories
        selected=$(
            {
                # Remove PROJECT_ROOT prefix for cleaner display
                find "$PROJECT_ROOT" -mindepth 2 -maxdepth 2 -type d 2>/dev/null | sed "s|^$PROJECT_ROOT/||"
                
                # Add extra directories with ~ prefix
                printf '%s\n' "${EXTRA_DIRS[@]}" | sed "s|^$HOME/|~/|"
                
                # Also show existing tmux sessions
                tmux list-sessions -F "#{session_name}" 2>/dev/null | sed 's/^/[SESSION] /'
            } | fzf --height 40% --reverse --border
        )
    fi

    # Exit if nothing selected
    [[ -z $selected ]] && exit 0

    # Handle existing tmux session selection
    if [[ "$selected" =~ ^\[SESSION\]\ (.+)$ ]]; then
        selected_name="${BASH_REMATCH[1]}"
        tmux switch-client -t "$selected_name" 2>/dev/null || tmux attach-session -t "$selected_name"
        exit 0
    fi

    # Add back the full path for non-session selections
    if [[ "$selected" =~ ^~/ ]]; then
        selected="${selected/#\~/$HOME}"
    elif [[ ! "$selected" =~ ^/ ]]; then
        selected="$PROJECT_ROOT/$selected"
    fi

    # Create session name from directory
    # ~/projects/flutter/my-app -> my-app
    # ~/notes -> notes
    selected_name=$(basename "$selected" | tr . _)

    # Create session if it doesn't exist
    if ! tmux has-session -t "$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected"
    fi

    # Switch to session
    if [[ -z $TMUX ]]; then
        tmux attach-session -t "$selected_name"
    else
        tmux switch-client -t "$selected_name"
    fi
}

main "$@"
