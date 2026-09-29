# Contributing to {{ModuleName}}

Thanks for helping improve this module.

## Development setup

1. Clone this repository
2. Use PowerShell 7+ when possible
3. Run `./build.ps1` to restore tools, lint, test, and compile

## Coding standards

- One function per file under `src/{{ModuleName}}/Public` or `Private`
- Use approved PowerShell verbs (`Get-Verb`)
- Include comment-based help (SYNOPSIS, DESCRIPTION, PARAMETER, EXAMPLE)
- Prefer `[CmdletBinding()]` and pipeline-friendly parameters where it helps callers
- Add or update Pester tests under `tests/` for public commands

## Pull requests

- Keep changes focused
- Ensure `./build.ps1` passes locally
- Update [CHANGELOG.md](CHANGELOG.md) under `[Unreleased]` when behavior changes
