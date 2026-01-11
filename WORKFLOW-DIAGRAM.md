# Dev Flow - Workflow Diagram

## Complete Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         START: User creates TODO.md                 │
│                         Runs: /dev-flow                             │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 1: REQUIREMENTS REFINEMENT                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Requirements Refiner Agent                                 │    │
│  │ - Reads TODO.md                                            │    │
│  │ - Asks clarifying questions (if needed)                    │    │
│  │ - Documents requirements clearly                           │    │
│  │ - Writes REQUIREMENTS.md                                   │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────┐
                    │  🚦 CHECKPOINT #1          │
                    │  User reviews:             │
                    │  - REQUIREMENTS.md         │
                    │  - Asks questions          │
                    │  - Approves or requests    │
                    │    changes                 │
                    │  Runs: /dev-flow-continue  │
                    └────────────┬───────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 2: PLANNING                                                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Planner Agent                                              │    │
│  │ - Reads REQUIREMENTS.md                                    │    │
│  │ - Explores codebase (Explore subagent)                     │    │
│  │ - Understands architecture                                 │    │
│  │ - Creates detailed implementation plan                     │    │
│  │ - Identifies risks and challenges                          │    │
│  │ - Writes PLAN.md                                           │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                                 ▼
                    ┌────────────────────────────┐
                    │  🚦 CHECKPOINT #2          │
                    │  User reviews:             │
                    │  - PLAN.md                 │
                    │  - Checks approach         │
                    │  - Verifies architecture   │
                    │  Runs: /dev-flow-continue  │
                    └────────────┬───────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 3: IMPLEMENTATION                                            │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Implementor Agent                                          │    │
│  │ - Reads REQUIREMENTS.md and PLAN.md                        │    │
│  │ - Implements each step in order                            │    │
│  │ - Writes/updates tests                                     │    │
│  │ - Makes atomic commits                                     │    │
│  │ - Runs tests after each change                             │    │
│  │ - Runs final build                                         │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴───────────┐
                    │                        │
                    ▼                        ▼
        ┌───────────────────┐    ┌──────────────────┐
        │ Success?          │    │ Blocked?         │
        │ Tests pass?       │    │ Unresolved error?│
        └────────┬──────────┘    └────────┬─────────┘
                 │ YES                     │ YES
                 │                         │
                 │                         ▼
                 │              ┌──────────────────────┐
                 │              │ Creates PROBLEMS.md  │
                 │              └──────────┬───────────┘
                 │                         │
                 │                         ▼
                 │              [Go to DEBUGGING phase]
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 4: CODE REVIEW                                               │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Code Reviewer Agent                                        │    │
│  │ - Reviews all commits and changes                          │    │
│  │ - Checks requirements compliance                           │    │
│  │ - Evaluates code quality                                   │    │
│  │ - Checks security, performance                             │    │
│  │ - Verifies test coverage                                   │    │
│  │ - Writes COMMENTS.md                                       │    │
│  │ - Verdict: APPROVE or REQUEST_CHANGES                      │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴───────────┐
                    │                        │
                    ▼                        ▼
        ┌───────────────────┐    ┌──────────────────────┐
        │ APPROVED?         │    │ REQUEST_CHANGES?     │
        └────────┬──────────┘    └────────┬─────────────┘
                 │ YES                     │ YES
                 │                         │
                 │                         ▼
                 │              ┌──────────────────────────┐
                 │              │  🚦 CHECKPOINT #3        │
                 │              │  User reviews:           │
                 │              │  - COMMENTS.md           │
                 │              │  - Can add own comments  │
                 │              │  Runs: /dev-flow-continue│
                 │              └────────┬─────────────────┘
                 │                       │
                 │                       ▼
                 │              ┌────────────────────────────┐
                 │              │ PHASE 4b: ADDRESS COMMENTS │
                 │              │ Implementor Agent:         │
                 │              │ - Reads COMMENTS.md        │
                 │              │ - Addresses each comment   │
                 │              │ - Commits fixes            │
                 │              │ - Updates responses        │
                 │              └────────┬───────────────────┘
                 │                       │
                 │                       │
                 │      ┌────────────────┘
                 │      │ Loop until approved
                 │      │ (Review round + 1)
                 │      └────────▶ [Back to CODE REVIEW]
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 5: TESTING                                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Tester Agent                                               │    │
│  │ - Reads REQUIREMENTS.md                                    │    │
│  │ - Tests all functional requirements                        │    │
│  │ - Verifies acceptance criteria                             │    │
│  │ - Tests edge cases                                         │    │
│  │ - Documents test results                                   │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴───────────┐
                    │                        │
                    ▼                        ▼
        ┌───────────────────┐    ┌──────────────────────┐
        │ ALL TESTS PASS?   │    │ ISSUES FOUND?        │
        └────────┬──────────┘    └────────┬─────────────┘
                 │ YES                     │ YES
                 │                         │
                 │                         ▼
                 │              ┌──────────────────────┐
                 │              │ Creates PROBLEMS.md  │
                 │              └──────────┬───────────┘
                 │                         │
                 │                         ▼
                 │              [Go to DEBUGGING phase]
                 │
                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PHASE 6: COMPLETE                                                  │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Summary:                                                   │    │
│  │ ✅ All requirements verified                               │    │
│  │ ✅ Code reviewed and approved                              │    │
│  │ ✅ All tests passing                                       │    │
│  │ ✅ Changes committed                                       │    │
│  │                                                            │    │
│  │ Next steps:                                                │    │
│  │ - Create PR: gh pr create                                  │    │
│  │ - Or merge directly                                        │    │
│  └────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘


                        [DEBUGGING PHASE]
                     (Activates when needed)

┌─────────────────────────────────────────────────────────────────────┐
│  PHASE: DEBUGGING                                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Debugger Agent                                             │    │
│  │ - Reads PROBLEMS.md                                        │    │
│  │ - Investigates root cause                                  │    │
│  │ - Analyzes code and errors                                 │    │
│  │ - Forms and verifies hypothesis                            │    │
│  │ - Writes detailed FIX.md with:                             │    │
│  │   * Root cause explanation                                 │    │
│  │   * Detailed fix instructions                              │    │
│  │   * Testing steps                                          │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                 │                                   │
│                                 ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Implementor Agent                                          │    │
│  │ - Reads FIX.md                                             │    │
│  │ - Implements the fix                                       │    │
│  │ - Tests the fix                                            │    │
│  │ - Commits changes                                          │    │
│  │ - Deletes PROBLEMS.md and FIX.md                           │    │
│  └────────────────────────────────────────────────────────────┘    │
└────────────────────────────────┬────────────────────────────────────┘
                                 │
                    ┌────────────┴───────────┐
                    │                        │
                    ▼                        ▼
        ┌───────────────────┐    ┌──────────────────────┐
        │ Issue from         │    │ Issue from          │
        │ IMPLEMENTATION?    │    │ TESTING?            │
        └────────┬───────────┘    └────────┬─────────────┘
                 │                         │
                 ▼                         ▼
    [Back to CODE REVIEW]      [Back to TESTING]
```

## Parallel Workflows

```
                    ┌──────────────────────────────────┐
                    │    Your Machine / Git Repo       │
                    └──────────────────────────────────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        │                          │                          │
        ▼                          ▼                          ▼
┌───────────────┐          ┌───────────────┐        ┌───────────────┐
│  Worktree 1   │          │  Worktree 2   │        │  Worktree 3   │
│               │          │               │        │               │
│  Branch:      │          │  Branch:      │        │  Branch:      │
│  feature/auth │          │  feature/perf │        │  feature/api  │
│               │          │               │        │               │
│  Files:       │          │  Files:       │        │  Files:       │
│  - TODO.md    │          │  - TODO.md    │        │  - TODO.md    │
│  - REQUIRE... │          │  - REQUIRE... │        │  - REQUIRE... │
│  - PLAN.md    │          │  - PLAN.md    │        │  - PLAN.md    │
│  - .dev-flow  │          │  - .dev-flow  │        │  - .dev-flow  │
│               │          │               │        │               │
│  Claude Code  │          │  Claude Code  │        │  Claude Code  │
│  Instance 1   │          │  Instance 2   │        │  Instance 3   │
│  /dev-flow    │          │  /dev-flow    │        │  /dev-flow    │
└───────┬───────┘          └───────┬───────┘        └───────┬───────┘
        │                          │                        │
        ▼                          ▼                        ▼
┌───────────────┐          ┌───────────────┐        ┌───────────────┐
│  Phase: Review│          │  Phase: Test  │        │  Phase: Plan  │
│  Round: 2     │          │  Progress: 80%│        │  Progress: 20%│
└───────────────┘          └───────────────┘        └───────────────┘
        │                          │                        │
        │                          │                        │
        └──────────────────────────┴────────────────────────┘
                                   │
                                   ▼
                    ┌──────────────────────────┐
                    │  Independent PRs         │
                    │  Merge in any order      │
                    │  No interference         │
                    └──────────────────────────┘
```

## Agent Interactions

```
┌────────────────┐
│ Requirements   │──────► REQUIREMENTS.md ──────┐
│ Refiner        │                              │
└────────────────┘                              │
                                                ▼
┌────────────────┐                    ┌────────────────┐
│ Planner        │◄───────────────────┤ REQUIREMENTS.md│
│                │                    └────────────────┘
└────────┬───────┘
         │
         ▼
    PLAN.md
         │
         └──────────────────────────────┐
                                        ▼
                              ┌────────────────┐
                              │ Implementor    │
                              │                │
                              └────────┬───────┘
                                       │
                                       ▼
                                 Code Changes
                                   Commits
                                       │
                    ┌──────────────────┴──────────────────┐
                    │                                     │
                    ▼                                     ▼
          ┌────────────────┐                   ┌────────────────┐
          │ Code Reviewer  │                   │ Tester         │
          │                │                   │                │
          └────────┬───────┘                   └────────┬───────┘
                   │                                    │
                   ▼                                    │
             COMMENTS.md                                │
                   │                                    │
                   │         ┌──────────────────────────┘
                   │         │
                   │         ▼
                   │    Test Results
                   │         │
                   │         │ Issues?
                   │         ▼
                   │    PROBLEMS.md
                   │         │
                   │         ▼
                   │    ┌────────────┐
                   │    │ Debugger   │
                   │    │            │
                   │    └──────┬─────┘
                   │           │
                   │           ▼
                   │       FIX.md
                   │           │
                   └───────────┴─────┐
                                     ▼
                           ┌────────────────┐
                           │ Implementor    │
                           │ (fixes)        │
                           └────────────────┘
                                     │
                         [Loop back to appropriate phase]
```

## State Transitions

```
requirements ──[user continue]──► planning
                                     │
                    [user continue]──┘
                                     ▼
                              implementation
                                     │
                    [automatic]──────┤
                                     ▼
                                  review
                                     │
                 ┌───────────────────┴────────────────┐
                 │                                    │
        [APPROVE]▼                          [REQUEST_CHANGES]
              testing                                 │
                 │                   [user continue]──┘
                 │                                    ▼
    [pass]───────┤                          address_comments
                 │                                    │
    [issues]─────┤                                    │
                 │                                    │
                 ▼                                    │
             debugging◄──────────────────────────────┘
                 │                            [back to review]
                 └────► [fix applied]
                            │
              ┌─────────────┴─────────────┐
              │                           │
    [from impl]▼                 [from test]▼
       review                        testing
              │                           │
              └─────────►complete◄────────┘
```

## Legend

```
┌─────────┐
│  Box    │  = Phase or component
└─────────┘

    ▼       = Flow direction

──►         = Automatic transition

🚦          = User checkpoint (manual approval needed)

[Condition] = Decision point

Agent       = Specialized Claude agent with fresh context
```
