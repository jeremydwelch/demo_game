# CLAUDE.md

Context for AI agents working on this project. Read this before starting a task.

## The game

A top-down 2D roguelike survival game (working title "MyFirstGame"). It's inspired by **Vampire Survivors**: you survive as long as you can against endless waves of mobs that keep getting stronger. The combat is **Zelda-style** instead of bullet-hell. The player swings a sword at nearby enemies, and enemies sometimes drop health (hearts) or experience (crystals) when they die.

Solo project by Jeremy. Agents work on tasks he assigns and deliver them as PRs for him to review.

### Where the design is headed

- **Abilities.** Players unlock abilities (e.g. dash/movement, magic fireball, status effects). At the start of each run they pick up to N unlocked abilities for a loadout, then level those abilities up during the run.
- **The sword becomes an ability.** It is the default ability that is always equipped. Its upgrades are things like more damage or a faster swing.
- **Meta-progression and persistence.** Unlocks carry over between runs, so the game needs a save system (`user://`). Nothing is persisted yet; even `high_score` lives only in memory. Keep meta state (unlocks, high score) separate from run state (current loadout, ability levels, XP, world level).
- **More enemy types, and bosses that have abilities of their own.**

## Tech

- **Godot 4.7, GDScript only.** Don't add C#.
- Renderer: GL Compatibility. Default texture filter: nearest (pixel art). 2D gravity is 0 (top-down).
- Main scene: `res://src/levels/game_manager.tscn`.
- Input actions: `up` / `down` / `left` / `right` (WASD + arrows), `use` (LMB / Space = swing), `pause` (Esc / joypad 6).
- 2D physics layers: 1 player, 2 enemy, 3 hazard, 4 destructible, 5 collectible, 6 environment. Use these names, and add new layers in Project Settings rather than reusing an existing one for something else.

## Layout

```
src/
  actors/   player, sword, Mob base + Blob/Skeleton/Wasp, smoke_explosion
  levels/   game_manager, level (spawning, timers, scoring), loot_table, globals
  objects/  Collectible base + heart/crystal, tree, gate
  ui/       title_screen, world_transition, hud, stats (level-up/pause), game_over
assets/     sprites, tilesets, HUD theme, music, sfx (many sfx not wired up yet)
addons/     godot-git-plugin, godot_mcp_toolkit
```

## How the game currently works

- **Scene flow:** `game_manager.tscn` shows `TitleScreen` → `WorldTransition` fade → `change_scene_to_file(level.tscn)`, which makes `level` the scene root → on player death → `game_over.tscn` → back to `level.tscn`.
- **`Globals`** (`src/levels/globals.gd`) is a static `class_name`, **not** an autoload. It holds scene paths plus `score` / `high_score`. `Level` connects to each mob's signals when it spawns the mob and sets `mob.target`. Mobs don't look up the level or player themselves.
- **Spawning** (`level.gd`): a `Timer` spawns mobs at a random point on a `Path2D` ring parented to the player. Every `level_time` (45s) `world_level` goes up, which spawns more mobs, spawns them faster, and calls `mob.set_level(world_level)` to scale their health, damage, and speed.
- **Combat:** the player's `Sword` `Area2D` calls `take_damage(direction, damage)` on bodies it hits. Mobs knock back, and on death they emit `enemy_death`, free themselves, and spawn smoke. The player's hurtbox calls `take_player_damage`, with knockback i-frames handled by `KnockbackTimer`. Toughness reduces damage by a percentage, with a floor of 10% damage taken.
- **Loot** (`loot_table.gd`): a roll out of 1000 drops a heart (<100) or a crystal (<400). Collectibles blink and then despawn after their `ttl`.
- **Progression:** XP → `player.level_up()` → `level.player_level_up()` pauses the tree and opens `Stats`. There the player spends points on HP / Damage / Speed / Toughness, and `Stats.new_stats` → `level.new_player_stats` applies them. Each player stat is `base + modifier * scale`.
- **Animation:** the player and mobs use an `AnimationTree` driven by `parameters/conditions/*` flags and left/right `blend_position`s.

## Architecture direction

The code is early-stage and fragile. A large cleanup is planned. When you touch code, move it toward these patterns:

- **Data-driven content.** Abilities, mob types, and (later) bosses are defined by `Resource` subclasses (e.g. `AbilityData`: cooldown, per-level scaling, icon, the scene to run) plus a scene/script that executes them. Adding a fireball or a new mob should mean adding a resource and a scene, not new branches in `player.gd` or more `if rand < 1` chains in `level.gd`.
- **Autoloads instead of hard-coded paths.** Replace `Globals` and direct cross-node calls with autoloads. Use an `EventBus` for game-wide signals and a `GameState` for run/meta data such as score. Prefer signals ("call down, signal up") over `get_node("/root/...")`.
- **Separate run state from meta state** so persistence can be added cleanly.

## Code conventions

Follow the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html):

- **Tabs** for indentation. Existing files use 2 spaces by accident and will be converted during the cleanup. Until then, don't mix indentation styles within a file.
- `snake_case` for files, functions, and variables. `PascalCase` for `class_name` and nodes. `CONSTANT_CASE` for constants.
- Member order: `class_name`/`extends` → signals → enums → constants → `@export` → vars → `@onready` → `_ready` / built-ins → public methods → private methods.
- **Static typing everywhere**: variables, parameters, and return types (`func foo(x: float) -> void`).
- `print()` is fine for temporary debugging. Remove it before opening a PR. The existing debug prints are cleanup targets.

## Workflow

- **Every change ships as a PR** against `github.com/jeremydwelch/demo_game`. Never push to `main`.
- Branch off `main` as `<type>/<short-name>`, e.g. `feat/dash-ability`, `fix/mob-double-death`, `chore/cleanup-globals`. One task per PR. Open PRs as regular PRs, not drafts.
- Agents may edit any file. **For `.tscn` / `.tres` changes, prefer the Godot MCP tools** over hand-editing scene text. Hand edits are fine for small, obvious changes, such as fixing a path.
- Use MCP when a task needs it. Code-only changes don't always need the editor.

### Verification (required before opening a PR)

There's no automated test suite yet; formal tests will come later. Before opening a PR:

1. Run the game through the Godot MCP (`run_project`, then `get_debug_output`) and confirm there are **no new errors or warnings**.
2. Play through the feature you changed (spawn/fight/level-up/death as relevant).
3. In the PR description, say what you tested and give manual test steps Jeremy can repeat.

### MCP setup notes

- The session's `godot` MCP server provides `run_project`, `get_debug_output`, `create_scene`, `add_node`, and other tools.
- `addons/godot_mcp_toolkit/` (editor-side WebSocket bridge) is in the repo but **not enabled** in `project.godot` and has no `.mcp.json` yet. Enable it via Project Settings → Plugins and **Project → Tools → MCP Toolkit → Write .mcp.json** (see its README) if a task needs live editor access.

## Known issues / cleanup targets

There are likely more bugs than are listed here. Fix them when they're in scope, and mention them in the PR when you find them.

- `gate.tscn` is unused (the old gate/world-advance code was removed).
- Player knockback isn't implemented: `Player.is_knockback` is never set, so `knockback_speed` does nothing.
- All three mob scenes use the same `Mob` defaults, so blob, wasp, and skeleton only differ in sprites.
- Mob spawn odds come from `randf_range(0, num_mobs + 1)`: roughly 25% blob, 25% wasp, and 50% skeleton.
- The player's `AnimationTree` logs "aborts the transition by detecting one or more looped transitions" at runtime.
- Stats node names use hyphens (`hp-up`, ...). Rename them to PascalCase when the stats UI is reworked.
