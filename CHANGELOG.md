# Changelog

All notable changes to this project are documented here. Format loosely follows [Keep a Changelog](https://keepachangelog.com/); add new entries under an `[Unreleased]` section at the top going forward.

## [Unreleased]

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
