# Dev Flow - Quick Reference

## Commands

```bash
/dev-flow              # Start new workflow (requires TODO.md)
/dev-flow-continue     # Continue from last checkpoint
/dev-flow-status       # Show current status and progress
```

## Workflow Phases

```
1. Requirements  → REQUIREMENTS.md  [CHECKPOINT]
2. Planning      → PLAN.md          [CHECKPOINT]
3. Implementation→ Code commits     [automatic]
4. Code Review   → COMMENTS.md      [CHECKPOINT if changes needed]
5. Testing       → Test results     [automatic]
6. Complete      → Summary          [done!]

(Debugging phase activates if issues found)
```

## Quick Start

```bash
# 1. Create task
echo "# Add feature X" > TODO.md

# 2. Start
/dev-flow

# 3. Review REQUIREMENTS.md
/dev-flow-continue

# 4. Review PLAN.md
/dev-flow-continue

# 5. Let workflow run
# (Implementation → Review → Testing happen automatically)

# 6. If review comments, address them
/dev-flow-continue

# 7. Done! Create PR
gh pr create
```

## Files Created

| File | Created By | Purpose |
|------|-----------|---------|
| `TODO.md` | You | Initial task description |
| `REQUIREMENTS.md` | Requirements Refiner | Clarified requirements |
| `PLAN.md` | Planner | Implementation plan |
| `COMMENTS.md` | Code Reviewer | Review feedback |
| `PROBLEMS.md` | Implementor/Tester | Issues found |
| `FIX.md` | Debugger | Bug diagnosis & fix |
| `.dev-flow-state` | Workflow | State tracking |

## Checkpoints

You'll be asked to review and continue at these points:

1. **After Requirements**: Review `REQUIREMENTS.md`
2. **After Planning**: Review `PLAN.md`
3. **After Code Review** (if changes requested): Review `COMMENTS.md`

At each checkpoint: `/dev-flow-continue` when ready

## Status Output

```bash
/dev-flow-status
```

Shows:
- Current phase
- Progress percentage
- Iteration and round numbers
- What's completed
- What's next
- Relevant files

## Parallel Workflows

Each task in its own worktree:

```
project/worktrees/
├── add-auth/          ← Task 1
│   ├── TODO.md
│   └── .dev-flow-state
├── fix-bug/           ← Task 2
│   ├── TODO.md
│   └── .dev-flow-state
└── refactor/          ← Task 3
    ├── TODO.md
    └── .dev-flow-state
```

Each can progress independently!

## Common Patterns

### Starting Multiple Tasks

```bash
# Terminal 1
cd ~/project/worktrees/task-1
claude-code
/dev-flow

# Terminal 2
cd ~/project/worktrees/task-2
claude-code
/dev-flow

# Terminal 3
cd ~/project/worktrees/task-3
claude-code
/dev-flow
```

### Batch Review

```bash
# Start all tasks, let them reach first checkpoint

# Review all at once
cat worktrees/task-1/REQUIREMENTS.md
cat worktrees/task-2/REQUIREMENTS.md
cat worktrees/task-3/REQUIREMENTS.md

# Continue all
cd worktrees/task-1 && echo "/dev-flow-continue" | claude-code
cd worktrees/task-2 && echo "/dev-flow-continue" | claude-code
cd worktrees/task-3 && echo "/dev-flow-continue" | claude-code
```

### Adding Your Own Review Comments

```bash
# After internal code review creates COMMENTS.md
vim COMMENTS.md

# Add your section:
# ## Additional User Comments
# ### Fix X
# Please change Y to Z because...

# Continue
/dev-flow-continue
```

### Manual Testing

```bash
# After Tester completes, do additional testing

# If you find issues:
vim PROBLEMS.md
# Document what you found

# Continue (Debugger will investigate)
/dev-flow-continue
```

## Troubleshooting

### No workflow in progress
```bash
# Start one first
/dev-flow
```

### TODO.md not found
```bash
# Create it
vim TODO.md
```

### Workflow seems stuck
```bash
# Check status
/dev-flow-status

# Continue if at checkpoint
/dev-flow-continue
```

### Want to reset
```bash
# Delete state and start over
rm .dev-flow-state
/dev-flow
```

## Agents Reference

| Agent | Role | Input | Output |
|-------|------|-------|--------|
| Requirements Refiner | Clarify requirements | TODO.md | REQUIREMENTS.md |
| Planner | Create plan | REQUIREMENTS.md | PLAN.md |
| Implementor | Write code | PLAN.md | Commits |
| Code Reviewer | Review quality | Code changes | COMMENTS.md |
| Tester | Verify requirements | REQUIREMENTS.md | Pass/Fail |
| Debugger | Diagnose issues | PROBLEMS.md | FIX.md |

## Tips

- **Write clear TODO.md**: Better input = less clarification needed
- **Review checkpoints promptly**: Don't let workflow wait unnecessarily
- **Trust the agents**: They're designed to iterate internally
- **Check status often**: `/dev-flow-status` is your friend
- **Intervene when needed**: You can edit any file anytime
- **Use parallel workflows**: Less review time = more parallelization

## Comparison to Old Workflow

| Old | New |
|-----|-----|
| `/do-task` | `/dev-flow` |
| `/requested-changes` | Automatic (internal) |
| Manual GitHub review | Internal + optional manual |
| Single session | Multi-agent |
| Context exhaustion | Fresh contexts |
| Custom hooks | No hooks needed |
| No status | `/dev-flow-status` |

## Environment Setup

### Installation
```bash
cp -r dev-flow-plugin ~/.claude/plugins/dev-flow
```

### Launch Script
```bash
~/.claude/plugins/dev-flow/scripts/start-dev-flow.sh "task name"
```

Or integrate with your existing script.

## Getting Help

- Full docs: [README.md](README.md)
- Migration guide: [MIGRATION.md](MIGRATION.md)
- Implementation details: [SUMMARY.md](SUMMARY.md)
- Examples: [examples/](examples/)
- Agent docs: [subagents/](subagents/)

---

**Remember**: The workflow is async - you can start, walk away, check status, and continue when convenient!
