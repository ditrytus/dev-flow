# Migration Guide: From Old Workflow to Dev Flow

This guide helps you transition from your existing custom workflow to the new Dev Flow plugin.

## Overview of Changes

### What Stays the Same ✅

- **Git worktrees**: Still use separate worktrees for parallel tasks
- **Feature branches**: Each task still gets its own branch
- **Pull requests**: Still create PRs for each feature
- **GitHub history**: PR-based history remains the same
- **Quality bar**: Same high quality standards

### What Changes 🔄

- **Multiple agents**: Work is split across specialized agents instead of one session
- **Automated reviews**: Internal code review before you see it
- **Async checkpoints**: Review at your convenience, not blocking
- **Native GitHub**: No more custom hooks for PR comments
- **Better context**: Each agent has focused context, no exhaustion

### What's Removed ❌

- **Custom hooks**: No more `PreToolUse` hooks
- **Comment fetching scripts**: No more `refresh_pr_comments.sh`
- **Manual orchestration**: No more running `/requested-changes` manually
- **Context exhaustion**: Agents work in phases with fresh context

## Step-by-Step Migration

### 1. Install Dev Flow Plugin

```bash
# Copy plugin to Claude Code plugins directory
cp -r dev-flow-plugin ~/.claude/plugins/dev-flow

# Or create symlink for development
ln -s /path/to/dev-flow-plugin ~/.claude/plugins/dev-flow
```

### 2. Remove Old Hooks (Optional)

If you want to fully switch to the new workflow, remove the old hooks from your Claude Code settings:

**Old settings** (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "refresh_pr_comments.sh"
          }
        ]
      }
    ]
  }
}
```

**New settings** (no hooks needed):
```json
{
  "hooks": {}
}
```

### 3. Update Your Launch Script

**Old script** (`~/scripts/do_task.sh`):
```bash
#!/bin/bash
TASK_FILE=$1
BRANCH_NAME=$(basename "$TASK_FILE" .md)

git branch "feature/$BRANCH_NAME"
git worktree add "../worktrees/$BRANCH_NAME" "feature/$BRANCH_NAME"
cp "$TASK_FILE" "../worktrees/$BRANCH_NAME/TODO.md"

cd "../worktrees/$BRANCH_NAME"
claude-code --instruction /do-task
```

**New script** (use provided script or adapt):
```bash
#!/bin/bash
# Use the provided start-dev-flow.sh script
~/.claude/plugins/dev-flow/scripts/start-dev-flow.sh "$1"
```

Or create your own variation:
```bash
#!/bin/bash
TASK_FILE=$1
BRANCH_NAME=$(basename "$TASK_FILE" .md)

git branch "feature/$BRANCH_NAME"
git worktree add "../worktrees/$BRANCH_NAME" "feature/$BRANCH_NAME"
cp "$TASK_FILE" "../worktrees/$BRANCH_NAME/TODO.md"

cd "../worktrees/$BRANCH_NAME"
claude-code
# Then manually run: /dev-flow
```

### 4. Remove Old Custom Instructions (Optional)

If you're fully switching, you can remove or archive your old custom instructions:

- `/do-task` → Replaced by `/dev-flow`
- `/requested-changes` → Replaced by internal workflow (Implementor handles review comments)

You might want to keep them for reference or for projects not using Dev Flow.

### 5. First Test Run

Try the new workflow on a simple task:

```bash
# Create a simple task
echo "# Fix Typo in README\n\nFix the spelling of 'recieve' to 'receive'" > test-task.md

# Start workflow
./start-dev-flow.sh test-task.md

# In Claude Code
/dev-flow

# Follow the prompts
```

## Workflow Comparison

### Old Workflow

```
1. You write requirements in notes app
2. You create .md file in repo
3. You run ~/scripts/do_task.sh
   → Creates branch, worktree, copies TODO.md
   → Starts Claude Code with /do-task
4. Claude implements everything in ONE session
   → Exhausts context on complex tasks
5. Claude creates PR
6. You do manual review on GitHub
7. You manually run /requested-changes
   → Hook fetches comments
   → Claude addresses comments in SAME session
   → Further exhausts context
8. Repeat steps 6-7 multiple times
9. You manually test
10. You merge PR
```

**Pain points:**
- Single session exhausts context
- Manual review takes lots of your time
- Multiple review rounds are tedious
- Switching between parallel tasks is cumbersome
- Custom hooks are flaky

### New Workflow

```
1. You write requirements (in notes or directly in TODO.md)
2. You run start-dev-flow.sh task.md
   → Creates branch, worktree, copies TODO.md
   → Starts Claude Code
3. You run /dev-flow
   → Requirements Refiner asks questions, creates REQUIREMENTS.md
4. You review REQUIREMENTS.md, run /dev-flow-continue
   → Planner explores codebase, creates PLAN.md
5. You review PLAN.md, run /dev-flow-continue
   → Implementor implements (fresh context)
   → Code Reviewer reviews (fresh context)
   → Either approved or COMMENTS.md created
6. If comments: You review COMMENTS.md, run /dev-flow-continue
   → Implementor addresses comments (fresh context)
   → Code Reviewer reviews again
   → Repeat until approved
7. Tester tests everything (fresh context)
   → Reports success or issues
8. If issues: Debugger investigates, Implementor fixes
9. Workflow complete
10. You create PR or merge
```

**Improvements:**
- Each agent has fresh, focused context
- Internal reviews reduce your review burden
- Async checkpoints - review when convenient
- Clear progress tracking
- No custom hooks needed

## Key Differences in Practice

### Creating Tasks

**Old:**
```bash
# Write in notes app, then:
vim ~/notes/add-auth.md
~/scripts/do_task.sh ~/notes/add-auth.md
```

**New:**
```bash
# Write in notes app or directly:
vim add-auth.md
# or
./start-dev-flow.sh "Add user authentication"
```

### Starting Work

**Old:**
```bash
# Auto-started with /do-task instruction
# One session does everything
```

**New:**
```bash
# Manually run after launch
/dev-flow

# Multiple agents, each with fresh context
```

### Handling Review Comments

**Old:**
```bash
# On GitHub, you write comments
# Back in terminal:
/requested-changes
# Hook fetches comments
# Same exhausted session tries to fix
```

**New:**
```bash
# Code Reviewer already reviewed internally
# COMMENTS.md already created
# You review COMMENTS.md
# Optionally add your own comments
/dev-flow-continue
# Fresh Implementor session addresses comments
```

### Checking Progress

**Old:**
```bash
# No built-in status
# Check git log, git diff
```

**New:**
```bash
/dev-flow-status
# Shows phase, progress, next steps
```

### Testing

**Old:**
```bash
# You do all manual testing
# Time consuming
```

**New:**
```bash
# Tester agent does systematic testing
# You can add additional testing if desired
# Tester reports results clearly
```

## Migration Checklist

- [ ] Install Dev Flow plugin
- [ ] Test on a simple task
- [ ] Update launch script (optional)
- [ ] Remove old hooks (optional)
- [ ] Archive old custom instructions (optional)
- [ ] Update your workflow documentation
- [ ] Train yourself on new commands (`/dev-flow`, `/dev-flow-continue`, `/dev-flow-status`)

## Parallel Workflows

Both old and new workflows support parallel sessions via worktrees:

```
my-project/
├── .git/
└── worktrees/
    ├── add-authentication/     ← Session 1
    │   ├── TODO.md
    │   ├── .dev-flow-state
    │   └── (code)
    ├── fix-performance/        ← Session 2
    │   ├── TODO.md
    │   ├── .dev-flow-state
    │   └── (code)
    └── refactor-api/           ← Session 3
        ├── TODO.md
        ├── .dev-flow-state
        └── (code)
```

**New advantage**: Less time reviewing means you can actually run parallel sessions effectively!

## Rollback Plan

If you want to go back to the old workflow:

1. Keep your old scripts and instructions
2. Remove or disable the Dev Flow plugin
3. Re-enable your hooks in settings
4. Continue using the old workflow

The two workflows can coexist - use Dev Flow for new tasks and old workflow for existing tasks if needed.

## Troubleshooting Migration

### "I miss the automatic PR comment fetching"

The new workflow doesn't need it because Code Reviewer does internal review. But if you still want GitHub review:

1. Let the workflow complete
2. Create PR: `gh pr create`
3. Get human review on GitHub
4. Manually address comments using standard git workflow

### "The new workflow seems more complex"

It has more phases, but each phase is simpler and you're less involved:

- **Old**: You're in the loop constantly
- **New**: Checkpoints are strategic, agents handle most iteration

### "I want to customize the workflow"

Edit the agent markdown files:
- `subagents/code-reviewer.md` - Adjust review strictness
- `subagents/tester.md` - Adjust testing scope
- `skills/dev-flow.md` - Adjust orchestration logic

### "Can I use both workflows?"

Yes! Use Dev Flow for most tasks, fall back to old workflow if needed:

```bash
# New workflow
/dev-flow

# Old workflow (if you kept the instruction)
/do-task
```

## Getting Help

- Check the [README.md](README.md) for full documentation
- Look at [examples/](examples/) for TODO.md templates
- Review the [subagents/](subagents/) docs to understand each agent's role

## Feedback

As you migrate, note what works well and what doesn't. The agents can be tuned to match your preferences better than the old single-session approach could.
