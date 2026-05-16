# Repository Guidelines

## Overview

This repository contains personal macOS/Linux dotfiles. Shell configuration is
built around Oh My Zsh with the custom `nathan` theme, and files are installed
through symlinks created by `bootstrap.sh`.

## Project Structure & Module Organization

`bootstrap.sh` is the installer and links every `*.symlink` file to the matching
dotfile in `$HOME`. Shell configuration lives in `home/`: aliases, shared shell
setup, functions, global gitignore, the Oh My Zsh rc file, and the custom
`nathan.zsh-theme`. Git configuration lives in `git/`; edit
`git/gitconfig.symlink.example` rather than generated personal config. Helper
executables that should be on PATH belong in `bin/`, while Drupal-specific
maintenance scripts belong in `scripts/`.

Key files:

| File | Purpose |
| --- | --- |
| `home/commonrc.symlink` | PATH setup, environment variables, nvm/asdf loading |
| `home/aliases.symlink` | Shell aliases for navigation, git, PHP/Laravel, and Claude |
| `home/functions.symlink` | Shell functions such as `repeat`, `take`, and `npm-do` |
| `home/zshrc-omz.symlink` | Oh My Zsh config, plugins, and history settings |
| `git/gitconfig.symlink.example` | Template for generated user git config |

## Architecture Notes

Any file named `*.symlink` under `home/` or `git/` is linked to
`~/.<basename>`; for example, `home/aliases.symlink` becomes `~/.aliases`.
`git/gitconfig.symlink` is generated from `git/gitconfig.symlink.example` with
user-specific name and email values. Shell load order is `.zshrc` sources
`.zshrc-omz`, Oh My Zsh loads, `.commonrc` is sourced, then `.aliases` and
`.functions` are loaded from `.commonrc`. `$HOME/.dotfiles/bin` is added to PATH;
`scripts/` is not on PATH by default.

## Build, Test, and Development Commands

- `./bootstrap.sh`: installs or updates the dotfiles, initializes submodules,
  installs Oh My Zsh, links dotfiles, and updates `.zshrc`.
- `bash -n bootstrap.sh`: syntax-checks the installer without running it.
- `bash -n scripts/*.sh`: syntax-checks helper scripts.
- `shellcheck bootstrap.sh scripts/*.sh`: runs static shell analysis when
  ShellCheck is installed.
- `git status --short`: review local changes before editing or committing.

Run `bootstrap.sh` only when you intend to affect the current user environment;
it can overwrite, back up, or skip existing files interactively.

## Coding Style & Naming Conventions

Use Bash-compatible shell unless a file is already zsh-specific. Keep two-space
indentation inside functions and control blocks, matching `bootstrap.sh`.
Quote variables used as paths or user input when adding new code. Dotfiles that
should be installed must use the `name.symlink` convention, for example
`home/aliases.symlink` becomes `~/.aliases`. Keep executable commands in `bin/`
short and focused; keep project-specific scripts in `scripts/` with `.sh`
suffixes.

## Testing Guidelines

There is no formal automated test suite. Validate shell changes with `bash -n`
and ShellCheck where possible, then manually inspect commands that touch `$HOME`,
`/etc/hosts`, Apache config, or other machine-level state. For symlink changes,
confirm the destination name produced by `bootstrap.sh` before running it.

## Commit & Pull Request Guidelines

Recent commit messages are concise, imperative summaries such as `Import
environment variables` and `Add .local/bin to path`. Follow that pattern:
describe the user-visible change in one line. Pull requests should explain the
affected files, any required manual validation, and environment-specific risks.
Include screenshots only for visual shell prompt or theme changes. Git defaults
prefer rebasing and fast-forward merges; the default branch is `master`.

## Agent-Specific Instructions

Do not edit generated or personal files such as `git/gitconfig.symlink` unless
explicitly asked. Prefer small, targeted patches, preserve existing user changes,
and avoid running `bootstrap.sh` without clear approval because it mutates the
developer's home directory. When making repository changes, create atomic commits
automatically after validation; do not push commits unless the user explicitly
asks for a push.
