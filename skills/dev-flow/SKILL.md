---
name: dev-flow
description: Main workflow orchestrator for complete development workflow. Use when starting a new development task. Orchestrates requirements, planning, implementation, code review, and testing phases.
---

# Dev Flow - Main Workflow Orchestrator

This is the main entry point for the development workflow. It orchestrates the entire process from requirements to merge.

## Usage

```bash
/dev-flow
```

Expected context: `TODO.md` file exists in the current directory with the task description.

## What This Skill Does

This skill orchestrates a complete development workflow through multiple specialized agents:

1. **Requirements Refiner** - Clarifies requirements from TODO.md → REQUIREMENTS.md
2. **Planner** - Creates implementation plan → PLAN.md
3. **Implementor** - Makes code changes and commits
4. **Code Reviewer** - Reviews changes → COMMENTS.md
5. **Tester** - Verifies requirements are met
6. **Debugger** - Fixes issues if found

## Process

You are the orchestrator. Your job is to:
1. Check the current workflow state
2. Invoke the appropriate agent
3. Handle the agent's output
4. Decide next steps
5. Manage checkpoints for user approval

## Workflow State Management

State is tracked in `.dev-flow-state` file:

```json
{
  "phase": "requirements|planning|implementation|review|testing|debugging|complete",
  "iteration": 1,
  "reviewRound": 0,
  "debugRound": 0,
  "history": [],
  "blockers": []
}
```

## Execution Flow

### Phase 1: Requirements Refinement

1. Check if `REQUIREMENTS.md` exists
   - If yes and recent, skip to planning
   - If no or outdated, proceed

2. Launch `requirements-refiner` agent with `TODO.md`

3. Agent will:
   - Read TODO.md
   - Ask clarifying questions if needed
   - Write REQUIREMENTS.md

4. **CHECKPOINT**: Wait for user approval
   - Update state to `phase: "planning"`
   - Message: "Requirements refined. Review `REQUIREMENTS.md` and run `/dev-flow-continue` to proceed with planning."

### Phase 2: Planning

1. Launch `planner` agent

2. Agent will:
   - Read REQUIREMENTS.md
   - Explore codebase
   - Write PLAN.md

3. **CHECKPOINT**: Wait for user approval
   - Update state to `phase: "implementation"`
   - Message: "Plan created. Review `PLAN.md` and run `/dev-flow-continue` to begin implementation."

### Phase 3: Implementation

1. Launch `implementor` agent

2. Agent will:
   - Read REQUIREMENTS.md and PLAN.md
   - Make code changes
   - Write tests
   - Commit changes
   - Run tests and build

3. Handle outcomes:
   - **Success**: Proceed to code review
   - **Blocked**: Agent creates PROBLEMS.md → Go to debugging phase

4. If successful:
   - Update state to `phase: "review", reviewRound: 1`
   - Proceed directly to code review (no checkpoint)

### Phase 4: Code Review

1. Launch `code-reviewer` agent

2. Agent will:
   - Review all changes
   - Write COMMENTS.md
   - Verdict: APPROVE or REQUEST_CHANGES

3. Handle verdict:
   - **APPROVE**:
     - Update state to `phase: "testing"`
     - Proceed to testing
   - **REQUEST_CHANGES**:
     - **CHECKPOINT**: Wait for user
     - Message: "Code review complete. Review `COMMENTS.md`. Options:
       - Run `/dev-flow-continue` to have Implementor address comments
       - Edit `COMMENTS.md` with your own comments and run `/dev-flow-continue`
       - Manually fix issues and run `/dev-flow-continue` to skip to next review"

### Phase 5: Address Review Comments (if needed)

1. User continues after reviewing COMMENTS.md

2. Launch `implementor` agent with instruction to address comments

3. Agent will:
   - Read COMMENTS.md
   - Address each comment (fix or respond)
   - Commit changes
   - Update COMMENTS.md with responses

4. Increment `reviewRound`

5. Return to Phase 4 (Code Review)

### Phase 6: Testing

1. Launch `tester` agent

2. Agent will:
   - Read REQUIREMENTS.md
   - Test all functional requirements manually
   - Verify acceptance criteria
   - Report results

3. Handle outcomes:
   - **All tests pass**: Proceed to completion
   - **Issues found**: Agent creates PROBLEMS.md → Go to debugging phase
   - **Needs user decision**: **CHECKPOINT** - wait for user to decide

### Phase 7: Debugging (if needed)

1. Launch `debugger` agent with PROBLEMS.md

2. Agent will:
   - Investigate issues
   - Write FIX.md with diagnosis and solution

3. Increment `debugRound`

4. Launch `implementor` agent to apply fixes

5. Agent will:
   - Read FIX.md
   - Implement fixes
   - Commit changes
   - Delete PROBLEMS.md and FIX.md

6. Return to the phase where the problem was found:
   - If from implementation → Go to code review
   - If from testing → Go to testing

### Phase 8: Completion

1. Message user with summary:
   - "✅ Development workflow complete!
   - Requirements met and verified
   - Code reviewed and approved
   - All tests passing
   - Changes committed to feature branch

   Next steps:
   - Create pull request: `gh pr create`
   - Or merge directly if you prefer"

2. Clean up:
   - Archive .dev-flow-state
   - Keep REQUIREMENTS.md and PLAN.md for PR description

## Error Handling

### Agent Failures

If an agent fails or returns an error:
1. Log the error
2. Check if it's retryable
3. If yes, retry once
4. If no, create PROBLEMS.md and go to debugging phase

### User Interruption

If user interrupts or cancels:
1. Save current state to .dev-flow-state
2. Allow resume with `/dev-flow-continue`

### Timeout

If an agent takes too long:
1. Cancel the agent
2. Save state
3. Ask user if they want to retry or investigate

## Implementation Details

```typescript
// Pseudo-code for orchestration

async function runDevFlow() {
  const state = loadState() || initializeState();

  switch (state.phase) {
    case 'requirements':
      await runRequirementsPhase();
      break;
    case 'planning':
      await runPlanningPhase();
      break;
    case 'implementation':
      await runImplementationPhase();
      break;
    case 'review':
      await runReviewPhase();
      break;
    case 'testing':
      await runTestingPhase();
      break;
    case 'debugging':
      await runDebuggingPhase();
      break;
    case 'complete':
      showCompletionMessage();
      break;
  }
}

function initializeState() {
  return {
    phase: 'requirements',
    iteration: 1,
    reviewRound: 0,
    debugRound: 0,
    history: [],
    blockers: [],
    startedAt: new Date().toISOString()
  };
}

async function runRequirementsPhase() {
  // Check if TODO.md exists
  if (!fileExists('TODO.md')) {
    throw new Error('TODO.md not found. Please create it with task description.');
  }

  // Check if REQUIREMENTS.md already exists and is recent
  if (fileExists('REQUIREMENTS.md')) {
    const response = await askUser('REQUIREMENTS.md already exists. Use it or regenerate?', [
      'Use existing',
      'Regenerate'
    ]);

    if (response === 'Use existing') {
      updateState({ phase: 'planning' });
      return checkpoint('Requirements exist. Review and continue to planning.');
    }
  }

  // Launch requirements refiner
  await launchAgent('requirements-refiner', {
    prompt: 'Read TODO.md and create REQUIREMENTS.md with clarified requirements.',
    model: 'sonnet'
  });

  updateState({ phase: 'planning' });
  checkpoint('Requirements refined. Review REQUIREMENTS.md and continue to planning.');
}

async function runPlanningPhase() {
  // Launch planner
  await launchAgent('planner', {
    prompt: 'Read REQUIREMENTS.md and create detailed PLAN.md.',
    model: 'sonnet'
  });

  updateState({ phase: 'implementation' });
  checkpoint('Plan created. Review PLAN.md and continue to implementation.');
}

async function runImplementationPhase() {
  // Launch implementor
  const result = await launchAgent('implementor', {
    prompt: 'Read REQUIREMENTS.md and PLAN.md and implement all changes.',
    model: 'sonnet'
  });

  // Check for PROBLEMS.md
  if (fileExists('PROBLEMS.md')) {
    updateState({ phase: 'debugging' });
    await runDebuggingPhase();
    return;
  }

  // Proceed to code review
  updateState({ phase: 'review', reviewRound: 1 });
  await runReviewPhase();
}

async function runReviewPhase() {
  const state = getState();

  // Launch code reviewer
  await launchAgent('code-reviewer', {
    prompt: state.reviewRound === 1
      ? 'Review all changes and create COMMENTS.md.'
      : 'Review changes addressing previous comments and update COMMENTS.md.',
    model: 'sonnet'
  });

  // Read verdict from COMMENTS.md
  const comments = readFile('COMMENTS.md');
  const verdict = extractVerdict(comments);

  if (verdict === 'APPROVE') {
    updateState({ phase: 'testing' });
    await runTestingPhase();
  } else {
    checkpoint(
      `Code review round ${state.reviewRound} complete. ` +
      'Review COMMENTS.md and continue to address comments.'
    );
  }
}

async function runTestingPhase() {
  // Launch tester
  await launchAgent('tester', {
    prompt: 'Test all requirements from REQUIREMENTS.md manually.',
    model: 'sonnet'
  });

  // Check for PROBLEMS.md
  if (fileExists('PROBLEMS.md')) {
    updateState({ phase: 'debugging' });
    await runDebuggingPhase();
    return;
  }

  // Complete
  updateState({ phase: 'complete' });
  showCompletionMessage();
}

async function runDebuggingPhase() {
  const state = getState();
  state.debugRound++;

  // Launch debugger
  await launchAgent('debugger', {
    prompt: 'Read PROBLEMS.md and create FIX.md with diagnosis and solution.',
    model: 'sonnet'
  });

  // Launch implementor to apply fix
  await launchAgent('implementor', {
    prompt: 'Read FIX.md and implement the fixes.',
    model: 'sonnet'
  });

  // Return to previous phase
  if (state.previousPhase === 'implementation') {
    updateState({ phase: 'review' });
    await runReviewPhase();
  } else if (state.previousPhase === 'testing') {
    updateState({ phase: 'testing' });
    await runTestingPhase();
  }
}

function checkpoint(message) {
  saveState();
  informUser(message + '\n\nRun `/dev-flow-continue` when ready.');
}
```

## User Communication

### Progress Updates

Keep user informed:
- "🔍 Refining requirements..."
- "📋 Creating implementation plan..."
- "⚙️ Implementing changes..."
- "👀 Reviewing code..."
- "🧪 Testing implementation..."
- "🐛 Debugging issues..."

### Checkpoints

Clear instructions at each checkpoint:
- What was just completed
- What to review
- How to continue
- Alternative options if applicable

### Completion

Summary of what was accomplished:
- Requirements met
- Code quality verified
- Tests passing
- Commits made
- Next steps

## Important Notes

- **Async workflow**: User can walk away between phases
- **Transparent**: User can see all intermediate files
- **Recoverable**: State is saved, can resume anytime
- **Flexible**: User can intervene at checkpoints
- **Efficient**: Agents run with appropriate context
- **Quality**: Multiple verification steps ensure good results
