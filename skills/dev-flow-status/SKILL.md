---
name: dev-flow-status
description: Show current development workflow status. Use when checking progress, understanding current phase, or seeing what's been completed.
---

# Dev Flow Status

Show the current status of the development workflow.

## Usage

```bash
/dev-flow-status
```

## What This Skill Does

This skill displays the current state of the development workflow:
- Current phase
- Progress through workflow
- What's been completed
- What's next
- Any blockers or issues

## Process

```typescript
async function showDevFlowStatus() {
  // Load state
  const state = loadState();

  if (!state) {
    return message('No active workflow.\n\nStart one with `/dev-flow`');
  }

  // Display status
  displayStatus(state);
}

function displayStatus(state) {
  const phaseEmoji = {
    requirements: '📝',
    planning: '📋',
    implementation: '⚙️',
    review: '👀',
    testing: '🧪',
    debugging: '🐛',
    complete: '✅'
  };

  const phaseNames = {
    requirements: 'Requirements Refinement',
    planning: 'Planning',
    implementation: 'Implementation',
    review: 'Code Review',
    testing: 'Testing',
    debugging: 'Debugging',
    complete: 'Complete'
  };

  const progress = calculateProgress(state);

  console.log(`
╔════════════════════════════════════════╗
║     Dev Flow Workflow Status          ║
╚════════════════════════════════════════╝

${phaseEmoji[state.phase]} Current Phase: ${phaseNames[state.phase]}

Progress: ${progress}% ${progressBar(progress)}

Iteration: ${state.iteration}
${state.reviewRound > 0 ? `Review Round: ${state.reviewRound}\n` : ''}${state.debugRound > 0 ? `Debug Round: ${state.debugRound}\n` : ''}
Started: ${formatDate(state.startedAt)}

──────────────────────────────────────────

Completed Phases:
${formatCompletedPhases(state)}

Current Phase:
${describeCurrentPhase(state)}

Next Steps:
${describeNextSteps(state)}

${state.blockers.length > 0 ? `
⚠️  Blockers:
${state.blockers.map(b => `  - ${b}`).join('\n')}
` : ''}
──────────────────────────────────────────

Files:
${formatFiles(state)}
  `);
}

function calculateProgress(state) {
  const phases = ['requirements', 'planning', 'implementation', 'review', 'testing', 'complete'];
  const currentIndex = phases.indexOf(state.phase);

  if (state.phase === 'debugging') {
    // Debugging happens between phases, use previous phase
    const previousIndex = phases.indexOf(state.previousPhase || 'implementation');
    return Math.round((previousIndex / (phases.length - 1)) * 100);
  }

  return Math.round((currentIndex / (phases.length - 1)) * 100);
}

function progressBar(percent) {
  const filled = Math.round(percent / 5);
  const empty = 20 - filled;
  return '[' + '█'.repeat(filled) + '░'.repeat(empty) + ']';
}

function formatCompletedPhases(state) {
  const allPhases = ['requirements', 'planning', 'implementation', 'review', 'testing'];
  const currentIndex = allPhases.indexOf(state.phase);

  if (currentIndex === -1) return '  None yet';

  const completed = allPhases.slice(0, currentIndex);

  if (completed.length === 0) return '  None yet';

  return completed.map(p => `  ✅ ${capitalize(p)}`).join('\n');
}

function describeCurrentPhase(state) {
  const descriptions = {
    requirements: '  📝 Refining requirements from TODO.md\n  → Output: REQUIREMENTS.md',
    planning: '  📋 Creating implementation plan\n  → Output: PLAN.md',
    implementation: '  ⚙️ Implementing changes according to plan\n  → Output: Code changes, commits',
    review: `  👀 Reviewing code quality (Round ${state.reviewRound})\n  → Output: COMMENTS.md`,
    testing: '  🧪 Testing implementation against requirements\n  → Output: Test results',
    debugging: `  🐛 Investigating and fixing issues (Round ${state.debugRound})\n  → Output: FIX.md`,
    complete: '  ✅ All done! Ready to merge.'
  };

  return descriptions[state.phase] || '  Unknown phase';
}

function describeNextSteps(state) {
  const nextSteps = {
    requirements: '  Waiting for user to review REQUIREMENTS.md\n  Run `/dev-flow-continue` to proceed to planning',
    planning: '  Waiting for user to review PLAN.md\n  Run `/dev-flow-continue` to begin implementation',
    implementation: '  Implementation in progress...\n  Will automatically proceed to code review when complete',
    review: state.lastReviewVerdict === 'APPROVE'
      ? '  Code approved! Proceeding to testing...'
      : '  Waiting for user to review COMMENTS.md\n  Run `/dev-flow-continue` to address comments',
    testing: '  Testing in progress...\n  Will complete workflow or report issues',
    debugging: '  Debugging in progress...\n  Will return to previous phase after fix',
    complete: '  Create a pull request:\n    gh pr create\n  Or merge directly if ready'
  };

  return nextSteps[state.phase] || '  Unknown next steps';
}

function formatFiles(state) {
  const files = [];

  if (fs.existsSync('TODO.md')) files.push('  📄 TODO.md');
  if (fs.existsSync('REQUIREMENTS.md')) files.push('  📄 REQUIREMENTS.md');
  if (fs.existsSync('PLAN.md')) files.push('  📄 PLAN.md');
  if (fs.existsSync('COMMENTS.md')) files.push('  📄 COMMENTS.md');
  if (fs.existsSync('PROBLEMS.md')) files.push('  ⚠️  PROBLEMS.md');
  if (fs.existsSync('FIX.md')) files.push('  🔧 FIX.md');
  if (fs.existsSync('.dev-flow-state')) files.push('  💾 .dev-flow-state');

  return files.length > 0 ? files.join('\n') : '  No workflow files found';
}

function formatDate(isoString) {
  const date = new Date(isoString);
  const now = new Date();
  const diffMs = now - date;
  const diffMins = Math.round(diffMs / 60000);

  if (diffMins < 1) return 'just now';
  if (diffMins < 60) return `${diffMins}m ago`;

  const diffHours = Math.round(diffMins / 60);
  if (diffHours < 24) return `${diffHours}h ago`;

  const diffDays = Math.round(diffHours / 24);
  return `${diffDays}d ago`;
}

function capitalize(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}
```

## Example Output

```
╔════════════════════════════════════════╗
║     Dev Flow Workflow Status          ║
╚════════════════════════════════════════╝

👀 Current Phase: Code Review

Progress: 60% [████████████░░░░░░░░]

Iteration: 1
Review Round: 2

Started: 2h ago

──────────────────────────────────────────

Completed Phases:
  ✅ Requirements
  ✅ Planning
  ✅ Implementation

Current Phase:
  👀 Reviewing code quality (Round 2)
  → Output: COMMENTS.md

Next Steps:
  Waiting for user to review COMMENTS.md
  Run `/dev-flow-continue` to address comments

──────────────────────────────────────────

Files:
  📄 TODO.md
  📄 REQUIREMENTS.md
  📄 PLAN.md
  📄 COMMENTS.md
  💾 .dev-flow-state
```

## Implementation Notes

- Keep the output clean and readable
- Use emojis for visual clarity
- Show only relevant information based on phase
- Make next steps obvious
- Include timing information
- List all workflow files

## Important Notes

- Should be quick - just read state and display
- Don't modify anything
- Don't run any agents
- Purely informational
- Help user understand where they are in the workflow
