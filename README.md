# llm-skills

A personal Claude Code plugin marketplace. Each skill lives in its own
self-contained plugin folder under `plugins/`, so any of them can be
split out into its own repo later with no restructuring when it's ready
to be published individually.

## Layout

```
llm-skills/
├── .claude-plugin/
│   └── marketplace.json        # lists every plugin in this repo
├── plugins/
│   └── <plugin-name>/
│       ├── .claude-plugin/
│       │   └── plugin.json     # plugin metadata
│       └── skills/
│           └── <skill-name>/
│               └── SKILL.md    # the skill itself
```

`plugins/example-skill/` is a template — copy it to start a new skill.

## Adding a new skill

1. Copy the template: `cp -R plugins/example-skill plugins/my-new-skill`
2. Rename the inner `skills/example-skill` folder to match, and rewrite
   `SKILL.md` (frontmatter `name` + `description`, then the instructions).
3. Update `plugins/my-new-skill/.claude-plugin/plugin.json` (`name`,
   `description`).
4. Add an entry for it to the top-level `.claude-plugin/marketplace.json`.

A plugin can bundle multiple skills under its `skills/` folder if they're
tightly related, but the default here is one skill per plugin, since the
goal is to eventually publish some of these individually.

## Installing skills (new machine)

```bash
git clone git@github.com:JamesMcMahon/llm-skills.git
cd llm-skills
claude plugin marketplace add .
claude plugin install jj@llm-skills
claude plugin install communication-style@llm-skills
```

Restart Claude Code (or start a new session) for newly installed skills
to take effect — they don't apply mid-session.

New skill added to an already-added marketplace:

```bash
claude plugin marketplace update llm-skills
claude plugin install <name>@llm-skills
```

`claude plugin validate <path>` checks a plugin or marketplace manifest
before installing — run it after editing `plugin.json`/`marketplace.json`.

## Local development

Test a plugin without installing it:

```bash
claude --plugin-dir ./plugins/my-new-skill
```

## Publishing a skill individually

Because each plugin folder is self-contained (its own `plugin.json` and
`skills/`), publishing one on its own later is just: move
`plugins/<name>/` to a new repo root, keep `.claude-plugin/plugin.json`
where it is, and add its own `.claude-plugin/marketplace.json` (or list
it in someone else's) if you want it independently installable.
