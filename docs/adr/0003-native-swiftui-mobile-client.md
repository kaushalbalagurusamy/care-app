# ADR 0003: Native SwiftUI Mobile & Tablet Client Architecture

* **Status**: Accepted
* **Date**: 2026-08-11
* **Deciders**: Lead AI Systems Architect & Mobile/Backend Engineering Team

## Context

CARE App target users require fluid 60/120fps interactions, responsive iPadOS multi-window layouts, native accessibility support, and low-overhead HTTP/WebSocket synchronization.

## Decision

We build the mobile client as a 100% native Apple application using **Swift 5.10+ / Swift 6** and **SwiftUI** targeting **iOS 17.0+** / **iPadOS 17.0+**.
- Declarative UI components mapped directly to Figma design tokens.
- Native `URLSession` async/await networking layers.
- Xcode 26+ project structure with preview provider support.

## Consequences

* **Pros**: Best-in-class iOS/iPadOS performance, zero cross-platform bridge overhead, instant Apple system API adoption.
* **Cons**: Platform-locked to Apple platforms (alignment with CARE App core product goals).
