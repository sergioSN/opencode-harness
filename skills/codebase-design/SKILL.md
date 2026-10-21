---
name: codebase-design
description: Use when choosing a module's interface, placing a test seam, assessing module depth, or making a codebase easier to change.
---

# Codebase Design

Design deep modules: useful behavior behind a small interface, placed where change and verification stay local. Use this vocabulary consistently when proposing architecture.

## Terms

- **Module:** anything with an interface and implementation: a function, class, package, or larger slice.
- **Interface:** everything a caller must know to use a module correctly: types, invariants, ordering, errors, configuration, and performance characteristics.
- **Depth:** how much behavior a caller can use per unit of interface it must learn. A small interface with substantial behavior is deep; a surface nearly as complex as its implementation is shallow.
- **Seam:** the place at which an interface lets behavior change without changing its caller.
- **Adapter:** a concrete implementation that satisfies an interface at a seam.
- **Leverage:** capability gained by callers from a deep interface.
- **Locality:** how much a change, bug, or verification can stay in one place.

## Design checks

1. **Deletion test:** If deleting a proposed module would simply spread its complexity across callers, the module is earning its place. If complexity disappears, it may be a pass-through.
2. **Interface is the test surface:** tests and callers should cross the same seam. If a test must reach behind it, reconsider the module's shape.
3. **One adapter is hypothetical; two are evidence:** don't introduce an abstraction for a single implementation unless it buys a real, present capability.
4. Reduce methods, parameters, and required knowledge at the interface; keep internal composition private.
5. Prefer dependencies passed through the interface over hidden construction, and return results instead of hiding behavior in side effects when that improves testability.

When proposing a refactor, name the module, its interface, the seam, and the leverage/locality it creates. State what behavior remains behind the interface and how a test will exercise it.
