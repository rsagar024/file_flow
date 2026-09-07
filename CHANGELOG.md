# Changelog

All notable changes to this project are documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/); add new entries under an `[Unreleased]` section at the top going forward.

## [Unreleased]

- Theme management: light/dark/system mode selection, persisted across launches, with semantic color tokens (`SemanticColors`) replacing hardcoded colors in themed widgets and an animated circular-reveal transition when switching brightness
- Profile editing: update display name, username, email, and photo from the profile screen (reuses the create-account form in an edit mode)
- Avatar component (`UserAvatar`) with network image, local file, and initials/icon fallback, integrated into the profile screen alongside a storage-usage summary

## [1.0.0] — seeded from project history

Initial build-out of the app, in roughly the order it happened:

- Project scaffolding, string constants, and initial GitHub Actions workflows
- Splash screen and route setup
- App color/theme refactor and shared UI foundations (custom button, validators)
- Phone number + OTP authentication flow, including auto-verification, resend, and create-account (with profile photo, unique email/username checks)
- Custom app bar and further auth model refactors
- Several UI-bug fixes and merge-conflict cleanups; GitHub workflow fixes; disabled device font scaling app-wide
- Profile screen and related components
- Device management: per-device session tracking, single-device logout, and "log out all other devices"
