# Contributing to the Platform Engineering Architect Course

Thanks for helping improve this course! Contributions from students are what keep the workshop materials accurate and useful for future cohorts. Whether you spotted a typo, hit a command that doesn't work, or want to add a whole new module — we welcome it.

## What to contribute

Anything that makes the workshop better for the next student:

- **Fix what broke for you.** Wrong expected output, outdated image tags, commands that error — if you had to figure it out, save the next person the trouble.
- **Improve clarity.** Missing context, confusing steps, undocumented prerequisites.
- **Add content.** New examples, troubleshooting tips, alternative approaches, or entirely new modules.
- **Update dependencies.** Newer container images, Helm chart versions, API changes.

## How to contribute

1. **Fork the repo** and create a branch from `main`.
2. **Make your changes.** Keep each PR focused — one fix or one feature per PR.
3. **Test if possible.** If you changed a command or YAML manifest, try running it in your Coder environment first.
4. **Open a pull request** with a clear title and a short description of what you changed and why.

That's it. No formal template, no bureaucracy — just a clear title and enough context for a reviewer to understand what changed.

## Good PR examples

The kind of PRs that get merged quickly:

- "Fix kubectl describe syntax — can't use resource type with -f flag"
- "Update expected error output to match actual Gatekeeper webhook response"
- "Add example output for kubectl get deployment command"
- "Pin nginx image from floating :alpine to :1.27-alpine"

## A few guidelines

- **One concern per PR.** A typo fix and a new module should be separate PRs.
- **Match the existing style.** Look at how nearby READMEs are structured before adding new content.
- **Use the actual names.** Constraint templates, image tags, file paths — double-check these against the YAML files, not from memory.
- **Don't commit secrets.** No API keys, tokens, or credentials — even example ones that look real.

## Questions?

If you're not sure whether something is worth a PR, it probably is. Open it and we'll figure it out together.
