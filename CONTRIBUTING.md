# Contributing (Quick Guide)

Want to make a change? Here’s the fastest path: fork → branch → edit → PR.

## 1) Fork and clone
- On GitHub, click Fork on this repo.
- Clone your fork locally:
  - `git clone https://github.com/<your-username>/eb-platform-branch-update.git`
  - `cd eb-platform-branch-update`

## 2) Create a branch
- Use a short, descriptive name:
  - `git checkout -b fix/readme-typo`
  - or `git checkout -b feat/add-option`

## 3) Make your changes
- Edit files as needed. For scripts, try them locally:
  - `bash scripts/main.sh`
- Keep changes small and focused.

## 4) Commit
- Write a simple message that explains what changed:
  - `git add -A`
  - `git commit -m "fix: clarify usage in README"`

## 5) Push and open a PR
- Push your branch to your fork:
  - `git push -u origin <your-branch-name>`
- Open a Pull Request from your fork/branch to this repo’s main branch.
- In the PR description, briefly say what changed and why.

## Tips
- Please don’t commit secrets or credentials.
- If something’s unclear, just open an issue or draft PR and ask.
- See README.md for what this project does and how to run it.

Thanks for contributing!
