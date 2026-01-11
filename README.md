# Dev Flow Plugin

A comprehensive multi-agent development workflow for Claude Code that automates the software development lifecycle from requirements to merge.

## Overview

Dev Flow orchestrates multiple specialized agents to handle different aspects of software development:

- **Requirements Refiner**: Clarifies and documents requirements
- **Planner**: Creates detailed implementation plans
- **Implementor**: Writes code and tests
- **Code Reviewer**: Reviews code quality
- **Tester**: Verifies requirements are met
- **Debugger**: Investigates and fixes issues

## Installation

1. Copy the `dev-flow-plugin` directory to your Claude Code plugins directory:

```bash
# On macOS/Linux
cp -r dev-flow-plugin ~/.claude/plugins/

# Or create a symlink for development
ln -s /path/to/dev-flow-plugin ~/.claude/plugins/dev-flow
```

2. Restart Claude Code or reload plugins

## Quick Start

1. Create a `TODO.md` file in your project repository:

```markdown
# Add User Authentication

Implement JWT-based authentication with:
- Login endpoint
- Token validation middleware
- Logout functionality
- Token refresh
```

2. Start the workflow:

```bash
/dev-flow
```

3. The workflow will guide you through each phase with checkpoints for review

4. Continue after reviewing each phase:

```bash
/dev-flow-continue
```

5. Check status anytime:

```bash
/dev-flow-status
```

## Workflow Phases

### 1. Requirements Refinement

- Reads `TODO.md`
- Asks clarifying questions
- Produces `REQUIREMENTS.md`
- **Checkpoint**: User reviews requirements

### 2. Planning

- Reads `REQUIREMENTS.md`
- Explores codebase
- Creates detailed `PLAN.md`
- **Checkpoint**: User reviews plan

### 3. Implementation

- Reads requirements and plan
- Implements all changes
- Writes/updates tests
- Makes atomic commits
- Runs tests and build
- Proceeds to code review automatically

### 4. Code Review

- Reviews all changes
- Checks quality, security, performance
- Produces `COMMENTS.md`
- **Checkpoint** (if changes requested): User reviews comments

### 5. Address Comments (if needed)

- Implementor addresses review comments
- Commits fixes
- Returns to code review
- Iterates until approved

### 6. Testing

- Tests all requirements manually
- Verifies acceptance criteria
- Reports results or issues
- Proceeds to completion or debugging

### 7. Debugging (if needed)

- Investigates issues from `PROBLEMS.md`
- Produces `FIX.md` with diagnosis
- Implementor applies fixes
- Returns to appropriate phase

### 8. Completion

- All requirements verified
- Code approved
- Tests passing
- Ready for PR or merge

## Commands

### `/dev-flow`

Start a new development workflow. Requires `TODO.md` in current directory.

```bash
/dev-flow
```

### `/dev-flow-continue`

Continue from the last checkpoint after reviewing outputs.

```bash
# After reviewing REQUIREMENTS.md
/dev-flow-continue

# After reviewing PLAN.md
/dev-flow-continue

# After reviewing COMMENTS.md
/dev-flow-continue
```

### `/dev-flow-status`

Show current workflow status and progress.

```bash
/dev-flow-status
```

Example output:
```
╔════════════════════════════════════════╗
║     Dev Flow Workflow Status          ║
╚════════════════════════════════════════╝

👀 Current Phase: Code Review

Progress: 60% [████████████░░░░░░░░]

Iteration: 1
Review Round: 2

Started: 2h ago
```

## Workflow Files

The workflow creates these files in your project directory:

- `TODO.md` - Initial task description (you create this)
- `REQUIREMENTS.md` - Refined requirements (created by workflow)
- `PLAN.md` - Implementation plan (created by workflow)
- `COMMENTS.md` - Code review feedback (created by workflow)
- `PROBLEMS.md` - Issue reports (created when blockers found)
- `FIX.md` - Debug analysis (created when debugging)
- `.dev-flow-state` - Workflow state (for resume functionality)

## Integration with Git

### Recommended Setup

Use with git worktrees for parallel workflows:

```bash
#!/bin/bash
# start-dev-flow.sh

TASK_NAME=$1
BRANCH_NAME=$(echo "$TASK_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

# Create feature branch
git branch "feature/$BRANCH_NAME"

# Create worktree in separate directory
git worktree add "../worktrees/$BRANCH_NAME" "feature/$BRANCH_NAME"

# Copy TODO.md if provided
if [ -f "$TASK_NAME.md" ]; then
  cp "$TASK_NAME.md" "../worktrees/$BRANCH_NAME/TODO.md"
fi

# Start Claude Code in the worktree
cd "../worktrees/$BRANCH_NAME"
claude-code
```

Usage:
```bash
./start-dev-flow.sh "add-user-authentication"
# Then in Claude Code:
/dev-flow
```

### Git Workflow

The Implementor agent will:
- Make atomic commits for each logical change
- Use descriptive commit messages
- Include co-author attribution to Claude
- Run tests before committing

After workflow completes:
```bash
# Create pull request
gh pr create

# Or merge directly
git checkout main
git merge feature/your-branch
```

## Parallel Workflows

You can run multiple workflows in parallel:

1. Each workflow in its own worktree
2. Each has independent state (`.dev-flow-state`)
3. Each has its own feature branch
4. PRs can be created independently
5. Merge in any order (assuming no conflicts)

Example structure:
```
my-project/
├── .git/
└── worktrees/
    ├── add-authentication/
    │   ├── TODO.md
    │   ├── REQUIREMENTS.md
    │   ├── PLAN.md
    │   └── .dev-flow-state
    ├── fix-performance/
    │   ├── TODO.md
    │   ├── REQUIREMENTS.md
    │   └── .dev-flow-state
    └── refactor-api/
        ├── TODO.md
        └── .dev-flow-state
```

## Comparison to Manual Workflow

### Your Old Workflow

✅ Parallel sessions via worktrees
✅ Good PR-based history
✅ High quality results
❌ Too much manual review time
❌ Single session exhausted context
❌ Complex hooks for PR comments
❌ Cumbersome switching between sessions

### New Dev Flow Workflow

✅ Parallel sessions via worktrees (same)
✅ Good PR-based history (same)
✅ High quality results (same)
✅ **Automated internal reviews** - less manual work
✅ **Focused agent contexts** - no context exhaustion
✅ **Native GitHub integration** - no custom hooks needed
✅ **Async checkpoints** - review when convenient
✅ **Clear progress tracking** - `/dev-flow-status`

## Customization

### Adjusting Review Strictness

Edit [code-reviewer.md](subagents/code-reviewer.md) to adjust review criteria:

```markdown
### Be Pragmatic
- "Done is better than perfect"
- Don't nitpick trivial style issues  # ← Adjust this
- Focus on things that matter: correctness, security, maintainability
```

### Changing Testing Scope

Edit [tester.md](subagents/tester.md) to adjust testing approach:

```markdown
### Coverage
- Test every functional requirement
- Test every acceptance criterion
- Test edge cases from requirements
- Test error scenarios
- Don't test beyond requirements  # ← Adjust this
```

### Model Selection

The orchestrator uses Sonnet for all agents by default. You can override per-agent in the skill files:

```typescript
await launchAgent('implementor', {
  prompt: '...',
  model: 'opus'  // Use Opus for more complex implementation
});
```

## Troubleshooting

### "No workflow in progress"

You need to start a workflow first:
```bash
/dev-flow
```

### "TODO.md not found"

Create a TODO.md file with your task description first.

### Workflow stuck in a phase

Check status:
```bash
/dev-flow-status
```

Then continue:
```bash
/dev-flow-continue
```

### Agent errors or failures

Check for `PROBLEMS.md` - the workflow will automatically invoke the Debugger.

If workflow is stuck, you can manually fix issues and continue.

### State file corruption

Delete `.dev-flow-state` and restart:
```bash
rm .dev-flow-state
/dev-flow
```

## Best Practices

1. **Write clear TODO.md**: The better your initial description, the less back-and-forth needed

2. **Review checkpoints promptly**: Workflow pauses at key points for your input

3. **Use parallel workflows**: Start multiple tasks in separate worktrees

4. **Trust the agents**: They're designed to work together - let them iterate

5. **Intervene when needed**: You can edit COMMENTS.md or make manual fixes anytime

6. **Keep PRs focused**: One workflow = one feature = one PR

## Advanced Usage

### Custom Review Comments

You can add your own comments to `COMMENTS.md` before continuing:

```markdown
# Code Review Comments

## Summary
... (agent's review)

---

## Additional User Comments

### Use a More Descriptive Variable Name
**File**: `src/auth.ts:42`

The variable `tkn` should be `token` for clarity.
```

Then:
```bash
/dev-flow-continue
```

The Implementor will address both agent and user comments.

### Skipping Phases

If you want to skip a phase (e.g., you've already written requirements), you can:

1. Create `REQUIREMENTS.md` manually
2. Update `.dev-flow-state` to `"phase": "planning"`
3. Run `/dev-flow-continue`

### Manual Testing Integration

After the Tester phase, you can do additional manual testing:

1. Review the Tester's report
2. Do your own testing
3. If issues found, create/update `PROBLEMS.md`
4. Run `/dev-flow-continue` to invoke Debugger

## Contributing

To improve this plugin:

1. Edit the subagent or skill markdown files
2. Test with a real workflow
3. Share your improvements

## License

MIT

## Support

For issues or questions about this plugin, please open an issue on GitHub.
