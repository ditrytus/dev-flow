# Dev Flow Continue

Continue the development workflow from the last checkpoint.

## Usage

```bash
/dev-flow-continue
```

Expected context: `.dev-flow-state` file exists with saved workflow state.

## What This Skill Does

This skill resumes a paused workflow from the last checkpoint. It:
1. Loads the saved state from `.dev-flow-state`
2. Continues from where it left off
3. Executes the next phase in the workflow

## When to Use

Use this command after reviewing checkpoint outputs:
- After reviewing `REQUIREMENTS.md`
- After reviewing `PLAN.md`
- After reviewing and potentially editing `COMMENTS.md`
- After user makes a decision on test results

## Process

```typescript
async function continueDevFlow() {
  // Load state
  const state = loadState();

  if (!state) {
    return error('No workflow in progress. Run `/dev-flow` to start.');
  }

  // Log resume
  log(`Resuming workflow from ${state.phase} phase...`);

  // Continue based on current phase
  switch (state.phase) {
    case 'planning':
      // User reviewed REQUIREMENTS.md, proceed to planning
      await runPlanningPhase();
      break;

    case 'implementation':
      // User reviewed PLAN.md, proceed to implementation
      await runImplementationPhase();
      break;

    case 'review':
      // User reviewed COMMENTS.md, implementor will address them
      await runAddressCommentsPhase();
      break;

    case 'testing':
      // User made a decision after test issues, retry testing
      await runTestingPhase();
      break;

    case 'debugging':
      // Unlikely to be here, but continue debugging if needed
      await runDebuggingPhase();
      break;

    case 'complete':
      // Already complete
      return message('Workflow already complete!');

    default:
      return error(`Unknown phase: ${state.phase}`);
  }
}

async function runAddressCommentsPhase() {
  // Implementor reads COMMENTS.md and addresses issues
  await launchAgent('implementor', {
    prompt: 'Read COMMENTS.md and address all comments. ' +
            'For each comment, either fix the issue or provide a response explaining your reasoning.',
    model: 'sonnet'
  });

  // Check for new problems
  if (fileExists('PROBLEMS.md')) {
    updateState({ phase: 'debugging' });
    await runDebuggingPhase();
    return;
  }

  // Increment review round and go back to review
  const state = getState();
  state.reviewRound++;
  updateState({ phase: 'review' });

  await runReviewPhase();
}
```

## Implementation

Your implementation should:

1. **Validate state exists**:
   ```typescript
   if (!fs.existsSync('.dev-flow-state')) {
     throw new Error('No workflow state found. Start with /dev-flow');
   }
   ```

2. **Load and parse state**:
   ```typescript
   const stateContent = fs.readFileSync('.dev-flow-state', 'utf-8');
   const state = JSON.parse(stateContent);
   ```

3. **Resume appropriate phase**:
   - Call the same orchestration logic as `/dev-flow`
   - But skip to the current phase
   - Don't re-run completed phases

4. **Handle edge cases**:
   - State file corrupted → Error with recovery suggestion
   - Phase unknown → Error
   - Already complete → Inform user

## User Communication

### On Resume

```
Resuming dev-flow workflow...
Current phase: implementation (iteration 1)
Last checkpoint: Plan reviewed
```

### On Error

```
Error: No workflow state found.

Start a new workflow with /dev-flow
Ensure TODO.md exists with task description.
```

### On Complete

```
Workflow already complete!

Review the changes and create a PR:
  gh pr create
```

## State Transitions

The continue command facilitates these transitions:

```
[User reviews REQUIREMENTS.md]
/dev-flow-continue
  → planning phase

[User reviews PLAN.md]
/dev-flow-continue
  → implementation phase

[User reviews COMMENTS.md]
/dev-flow-continue
  → address comments → review phase

[User decides on test issues]
/dev-flow-continue
  → testing phase or debugging phase
```

## Important Notes

- This command should be quick - just load state and continue
- Don't ask questions unless absolutely necessary
- Trust the saved state
- If state is invalid, fail fast with clear message
- Update state file as workflow progresses
