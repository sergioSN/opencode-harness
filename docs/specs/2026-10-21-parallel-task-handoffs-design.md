# Make delegated SDD tasks safe to parallelize

## Problem

The task brief names the files for the whole task, but does not partition write ownership when a coordinator delegates parts to multiple agents. Concurrent writers can therefore touch the same path, and their handoff has no required status or concise result format.

## Scope

- **Yes:** define an optional delegation section with agent/owner, goal, context/constraints, exclusive write paths, dependencies/contract, and deliverable.
- **Yes:** require parallel writers to own disjoint paths; shared inspection is read-only. If ownership cannot be disjoint, sequence the work.
- **Yes:** standardize delegated results as `done|blocked|partial` with a summary of at most 10 lines and commands/results.
- **No:** add a runtime orchestrator, auto-partition repository files, or change the normal single-implementer workflow.

## Design

Extend the existing brief template and `ship-change` coordination rules. A serial task explicitly says `sin delegación`. The template requires one repeated handoff record per delegated assignment, naming its responsible agent, goal, context and constraints, exclusive writable paths, dependencies/interface contract, and deliverable. No two writers may own overlapping paths; a read-only verifier may inspect those paths. If paths overlap, sequence the assignments instead of relaxing ownership. Require a concise status report and leave long details in the task report.

## Edge cases

- No delegated agent: the brief explicitly says `sin delegación`.
- Shared files needed by multiple agents: only one writer owns them; other agents receive read-only access or a contract, otherwise work is sequenced.
- A task spans overlapping paths: reject parallel execution until the split is changed.
- A delegated agent is blocked or only partially completes: use the corresponding explicit status and report remaining work; do not label it done.

## Decisions pending

None.

## Rejected options

| Option | Why not |
|---|---|
| Copy the colleague's tmux/Claude orchestration application | This repo is OpenCode configuration and workflow, not an agent runtime. |
| Infer ownership automatically from filenames | It cannot determine semantic ownership and would add a runtime mechanism without a present implementation. |

## Completion

### Automatic

- `tests/test-sdd-contract.sh` requires all handoff fields, disjoint writer ownership, read-only sharing, concise status/evidence reporting, and the coordinator rule.

### Human acceptance

- A maintainer can fill the section for a parallel task without inventing the ownership or report contract.
