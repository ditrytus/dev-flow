#!/bin/bash
set -e

# Start Dev Flow - Helper script to launch Claude Code with a dev-flow task
# Usage: ./start-dev-flow.sh <task-file.md>
#   or: ./start-dev-flow.sh "Task description"

usage() {
    echo "Usage: $0 <task-file.md> | <task-description>"
    echo ""
    echo "Examples:"
    echo "  $0 add-auth.md                    # Use existing markdown file"
    echo "  $0 \"Add user authentication\"      # Create TODO.md from description"
    echo ""
    echo "This script will:"
    echo "  1. Create a feature branch from the task name"
    echo "  2. Create a git worktree in ../worktrees/"
    echo "  3. Copy or create TODO.md"
    echo "  4. Launch Claude Code in the worktree"
    exit 1
}

# Check arguments
if [ $# -eq 0 ]; then
    usage
fi

INPUT="$1"

# Determine if input is a file or a description
if [ -f "$INPUT" ]; then
    # Input is a file
    TASK_FILE="$INPUT"
    TASK_NAME=$(basename "$TASK_FILE" .md)
    TASK_CONTENT=$(cat "$TASK_FILE")
else
    # Input is a description
    TASK_NAME="$INPUT"
    TASK_CONTENT="# $INPUT\n\n(Add details here)"
fi

# Create branch name from task name
BRANCH_NAME=$(echo "$TASK_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')
BRANCH_NAME="feature/$BRANCH_NAME"

# Ensure we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_DIR="$REPO_ROOT/../worktrees/$(basename "$BRANCH_NAME")"

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    echo "Branch $BRANCH_NAME already exists."
    read -p "Use existing branch? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
else
    # Create feature branch
    echo "Creating branch: $BRANCH_NAME"
    git branch "$BRANCH_NAME"
fi

# Check if worktree already exists
if [ -d "$WORKTREE_DIR" ]; then
    echo "Worktree already exists at: $WORKTREE_DIR"
    read -p "Use existing worktree? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
else
    # Create worktree
    echo "Creating worktree at: $WORKTREE_DIR"
    mkdir -p "$(dirname "$WORKTREE_DIR")"
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
fi

# Create or copy TODO.md
TODO_FILE="$WORKTREE_DIR/TODO.md"

if [ -f "$TODO_FILE" ]; then
    echo "TODO.md already exists in worktree"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "$TASK_CONTENT" > "$TODO_FILE"
        echo "TODO.md updated"
    fi
else
    echo -e "$TASK_CONTENT" > "$TODO_FILE"
    echo "TODO.md created"
fi

echo ""
echo "=========================================="
echo "Dev Flow Workflow Ready!"
echo "=========================================="
echo ""
echo "Worktree: $WORKTREE_DIR"
echo "Branch: $BRANCH_NAME"
echo ""
echo "Next steps:"
echo "  1. Edit TODO.md if needed: vim $TODO_FILE"
echo "  2. Start Claude Code: cd $WORKTREE_DIR && claude-code"
echo "  3. In Claude Code, run: /dev-flow"
echo ""
echo "Or auto-start now? (y/n)"
read -p "> " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORKTREE_DIR"
    echo "Starting Claude Code in $WORKTREE_DIR..."
    echo "Run '/dev-flow' to begin the workflow"
    echo ""

    # Launch Claude Code (adjust command based on your setup)
    if command -v claude-code &> /dev/null; then
        claude-code
    elif command -v claude &> /dev/null; then
        claude
    else
        echo "Error: Claude Code CLI not found"
        echo "Please install Claude Code CLI or manually cd to the worktree"
        echo "  cd $WORKTREE_DIR"
        exit 1
    fi
else
    echo "Manual start:"
    echo "  cd $WORKTREE_DIR"
    echo "  claude-code"
fi
