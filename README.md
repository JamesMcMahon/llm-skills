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

## Local development

Test a plugin without installing it:

```bash
claude --plugin-dir ./plugins/my-new-skill
```

Test the whole marketplace as a user would install it:

```
/plugin marketplace add /Users/jamie/workspace/llm-skills
/plugin install my-new-skill@llm-skills
```

After editing, reload with `/reload-plugins` (no restart needed).

## Publishing a skill individually

Because each plugin folder is self-contained (its own `plugin.json` and
`skills/`), publishing one on its own later is just: move
`plugins/<name>/` to a new repo root, keep `.claude-plugin/plugin.json`
where it is, and add its own `.claude-plugin/marketplace.json` (or list
it in someone else's) if you want it independently installable.
