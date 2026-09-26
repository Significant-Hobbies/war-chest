# War Chest

A personal desktop tactical RPG: command a persistent company, fit equipment into a spatial war chest, and unlock something playable at every level.

## Play locally

**Double-click `War Chest.app` in this project folder** to play your saved campaign without opening Terminal. The self-contained app includes the same local runtime and game pack; it can be moved as a single unit to another writable local folder. Existing campaign progress uses the unchanged save location. This is an unsigned local convenience app, not a notarized release. Do not bypass macOS security warnings.

**Double-click `Practice War Chest.app` to try the new opening without touching your save.** Practice progress is temporary. Both apps contain Banner & Steel: mature flat illustrated troops, olive/stone scenery, three vertical approaches, restrained paper controls and a playable earned-rune introduction. Close older game windows before trying the updated apps.

Build another copy with `sh scripts/build-app.sh`; the builder refuses to replace an existing app. For a practice build, supply input folder, output app path and `practice` as its three arguments. `sh tests/test_app_launcher.sh` checks layout, campaign/practice arguments, relocation and overwrite protection using a fake engine, never your save. Finder launch of these updated wrappers still needs owner confirmation. The owner confirmed the previous Practice command opens a game window; background stability is not yet confirmed. Earlier bundles are preserved under `builds/War Chest Before Banner Steel.app` and `builds/War Chest Local Before Banner Steel/`.

The self-contained local bundle is at `builds/War Chest Local/`:

- Double-click `Play War Chest.command` to continue your saved campaign.
- Double-click `Practice War Chest.command` for a fresh, temporary campaign that never reads/writes your save or settings.
- `Verify Local Game.command` checks integrity and runs packaged journey, native-control, onboarding and motion tests. Logs stay in the bundle's `logs/` folder. Engine errors produce a failure even when assertions pass.

The project-root Play/Practice launchers prefer this bundle when present. Keep the whole bundle together; it contains the existing Godot runtime, game pack, both Banner & Steel artwork images, engine notices and checksum manifest. It does not depend on the source checkout or Downloads path at runtime. This is a local runner, not a notarized standalone export. Native graphical/background-crash verification is still pending.

Rebuild with `sh scripts/build-local.sh builds/NewCandidate` to preserve the existing bundle. The builder refuses to overwrite an existing output. It includes only the current game's explicit resource closure and six isolated test scripts, never player data or previous art experiments. `sh tests/test_local_launcher.sh` tests launcher modes and failure paths without starting a game.

### Run from source instead

Godot 4.7.2 is downloaded at `/Users/sarthak/Downloads/war-chest-tools/Godot.app`. The project and assets are already prepared on this machine.

```sh
cd /Users/sarthak/Desktop/fleet/war-chest
sh scripts/play.sh
```

Or open `project.godot` in Godot and press F5. On another machine, set `GODOT_BIN` to a Godot 4.7.x executable and separately copy `assets/banner-steel/` before importing the project. These required generated battle assets are local-only; fetch-assets.sh restores only the older prototype's external art. Legacy sprite-alpha fixtures also use the preserved `assets/pocket-v2/` images.

Battle-only practice trial (does not read or write player saves): `sh scripts/play.sh -- --pocket-battle`.

## Controls

- Click a hero/portrait or press **1–5** to select.
- Choose a command card, then click a troop. **T** cycles legal targets; **F** confirms.
- **Space** ends the round; **Z** undoes the last order within the current round. Rewards and enemy turns cannot be undone.
- **Tab/Enter** navigates controls. **Esc** cancels a selection or returns from help. Menu opens the guide and sound/motion settings.
- In the war chest, select an owned item and click an empty anchor cell, or drag packed equipment. **WASD** moves its cursor, **R** rotates the selected placement shape, **F** places. Stored equipment gives no combat ability.
- Retreat requires a second click. Defeat preserves equipment, gold and experience.

### Interaction feedback

Attacks now lunge, arrows and spells travel to their targets, and damage follows impact. Cleave marks both victims; defeated troops fade before the formation closes up. Healing, shared shields, absorbed hits, stuns and incoming reinforcements have distinct cues. Rapid commands preserve movement continuity and moving targets keep their clickable regions.

Effects finish within 0.68 seconds. The final result stays on the battlefield briefly before rewards; Continue or Space skips this presentation without changing rewards. Undo and navigation cancel outstanding effects. Menu → reduced motion removes spatial effects and keeps a stationary result summary. Buttons have a short press response; victory illustrations reveal once on entering rewards.

### Learn through your first battle

Genuinely new campaigns open directly into the Lantern Gate defense with sword, bow and shield already packed. Four optional contextual lessons teach attack, cross-front Volley, block and resolving the enemy turn. They advance on actual actions, respect Undo and can be skipped. First victory earns a storm rune instead of presenting the banner draft. The reward leads directly to the chest, highlights legal weapon-adjacent cells, and explains the real +2 command-damage benefit. Test this loadout opens battle two; the hint follows available linked attacks and recovers from fallen heroes or exhausted orders.

After battle two the guided company opens up to side quests, contracts and banners. Explore without guidance exposes systems at their existing level/story requirements; rewards are not forfeited. The optional validated opening state survives saves. Existing campaigns are not enrolled, do not lose their starter rune or first banner, and keep their existing access. Practice app/command uses `--pocket-demo --banner-opening`; bare `--pocket-demo` remains the legacy isolated fixture mode.

Hints explain recovery if Lysa falls or her bow is stored. Mouse and keyboard target previews show damage after armor, Cleave's area, and stun's attack cancellation. At level one, contracts and the banner-management tab stay locked until level two; combat commands remain fully available.

Every level-up now explains how to use its unlocks: ready immediately, free in storage, earned-gold purchase, or recruitment followed by packing. Two focal effects are Cleave's paired impact strokes and a 0.65-second level seal. The seal never blocks reward selection and does not replay when inspecting rewards; reduced motion shows its finished state.

## Campaign and progression

Six main encounters plus six optional side quests, across three chapters and six company levels. Main first clears grant 70 XP; company levels need 70 XP each. Main replays award half gold and 35 XP, with enemy health scaling. Side quests grant 35 XP on their first clear only. Level 6 is the current content cap, not a promise of infinite new content.

| Level | Playable unlocks |
|---|---|
| 1 | Rowan, Lysa, Fen, sword/bow/shield; first victory earns the storm rune in new campaigns |
| 2 | Merrin recruitment and storm staff, permanent talent choice, side quests/contracts, forge +1 |
| 3 | Ballista kit, healing flask, forge +2 |
| 4 | Fen's Pin down, free Frostfang relic |
| 5 | Rowan's Rally, Winterwatch defense, masterwork forge +3 |
| 6 | Talon the owl with ranged disruption, Hollow Crown finale, veteran replays |

Equipment supplies deterministic ability cards rather than a shuffled hand. Baseline movement, strike and guard remain available. The rune boosts edge-adjacent weapons. A packed ballista kit adds a player-controlled ballista in every battle. The current prototype shares one battlefield layout with different enemy compositions; distinct authored maps are still needed.

### Side quests and loadout choices

Keep → Side quests opens after the first campaign victory. These are optional missions with actual objectives, not kill-count checklists:

| Quest | Opens after | Objective and unique reward |
|---|---|---|
| The Missing Scout | Main battle 1 | Rowan reaches front 3, then returns to front 1 alive; Scout's pennant |
| The Last Supply Cart | Scout + main battle 1 | Escort Rowan through fronts 1 → 2 → 3 → 1; contract tier II |
| The Sunken Reliquary | Main battle 2 | Shield a surviving hero on front 3 for three turns; Dawn aegis |
| Light the Watchfires | Reliquary + main battle 3 | Reposition survivors into all three fronts; contract tier III |
| The Iron Oath | Main battle 4 | Defeat a patrol under rotating bombardments; Watcher's lens + tier IV |
| Break the Siege Engine | Iron Oath + main battle 6 | Defeat escorts to remove the commander's protection; tier V |

Each quest has a turn deadline and awards gold, mastery and a banner on victory. Replays pay half base gold with no repeated unique item or XP. Missing a convoy escort stage costs 5 gate health. Losing Rowan fails rescue/escort. Defeat preserves the company and explains what went wrong.

Three unique six-cell relics must be packed to work: pennant makes the company's first move each turn free; aegis adds 4 block to Guard; lens adds 3 ranged damage when the shooter's own front is clear. They cannot be bought or forged. Eleven items occupy 43 cells in total, but the chest holds 30: builds now compete for room.

Main battles 3–6 and the last two quests show the next bombardment's front and damage. It lands before enemy attacks and consumes block first. Move or protect threatened heroes, or build around passive defenses. Old in-progress battles are not changed retroactively.

### War contracts and banners

At level 2, choose Supply Raid (ranged hunters), Powder & Steel (gate-attacking sappers), or Ironclad Patrol (armored guards and an enraging captain). Five difficulty tiers unlock at 0/6/12/18/24 renown, or through the corresponding side-quest milestones above. Contracts award earned gold, 35 XP up to the company cap, tier-scaled renown and a banner choice. They do not skip campaign encounters. Formations rotate with completed contracts; there are no daily locks.

Victories offer three persistent banner upgrades, except the new opening's first victory, which teaches the earned rune. Collect six banners, raise them to rank III, and equip one at the keep: melee damage, ranged damage, start-of-turn block, healing, disruption damage, or extra gold. A mastered duplicate pays 40 gold. Pending choices are saved and cannot be claimed twice. Bonuses require their matching commands; banners do not grant equipment or recruit heroes.

Armored guards reduce each hit by two (minimum one damage). Archers target the weakest living ally across fronts. Sappers bypass troops to attack the gate. Captains gain two attack at half health. Inspect a troop to read its rule and current intent.

### Hero mastery and optional objectives

Each deployed hero earns one mastery win when the company wins, even if that hero fell. Ranks I/II/III unlock at 2/5/9 wins. New ranks apply next battle; defeats do not erase progress. Fen and Talon share companion mastery, and ballistas do not gain mastery. Select mastery badges at the keep or rank-up buttons after victory to inspect benefits:

| Hero | Rank I / II / III benefit |
|---|---|
| Rowan | Guard gives other living allies on his front 2 / 4 / 6 block |
| Lysa | Volley deals 2 / 4 / 6 extra damage to an already-stunned foe |
| Fen / Talon | Strike restores 2 / 4 / 6 of the companion's own health |
| Merrin | Heal also grants its target 2 / 4 / 6 block |

New battles have an optional bonus-gold objective: protect the gate, keep all heroes standing, finish an assault by turn five, move three different heroes, or stun three different surviving foes. The campaign assigns objectives; contracts rotate them deterministically. Objectives pay only on victory, once, with no penalty for missing them. Move/stun counters and impossible-goal feedback are visible during play. Keyboard target previews include armor and Lysa's conditional mastery damage.

Old active saves keep their original battle rules. Mastery starts counting with new battles after this upgrade; no historical hero participation is invented.

## Saves

Auto-saves after meaningful actions. macOS default: `~/Library/Application Support/Godot/app_userdata/War Chest/iron-and-ember-v2.json`. The earlier campaign-v1.json is preserved separately. No account, cloud sync, analytics, purchases, or runtime network traffic. Malformed saves are preserved and saving is disabled with a visible recovery message. Move a broken save aside before relaunching; never delete it as an automated fix.

`-- --pocket-demo` starts an isolated practice campaign; `-- --pocket-battle` opens its first battle directly. Neither reads or writes player saves/settings. The old scene's test-mode flags do not apply to Pocket Siege.

## Verification

```sh
sh scripts/check.sh
```

Runs Godot import/script diagnostics and thirteen test suites, including the earned two-battle opening, practice startup, complete earned twelve-encounter journey with save/restore after each turn, and bounded idle/navigation/scene-cleanup stress. The current restricted host emits a macOS system-CA diagnostic and cannot save editor preferences, so the strict wrapper is not green here. Direct headless suite assertions pass with explicit temporary log paths. Native graphical requalification remains blocked; do not launch background GUI probes from the restricted agent. A legal-action solver proving winnability is not proof of long-term fun or human difficulty balance.

## Structure

- `scripts/siege_game.gd`: three-front combat, inheriting inventory/progression/persistence from game.gd.
- `scripts/pocket_campaign.gd`: contracts, renown, banners, enemy roles and backward-compatible save extensions.
- `scripts/hero_campaign.gd`: hero mastery snapshots, command synergies and optional battle objectives.
- `scripts/journey_game.gd`: current model; authored quests, milestone gates, packed relics and telegraphed hazards.
- `scripts/pocket_main.gd`: current full-window game UI.
- `scripts/pocket_field.gd`, `pocket_art.gd`: battle presentation and art.
- `scripts/pocket_chest.gd`: shaped equipment packing view.
- `tests/`: isolated model checks and campaign regression.
- `ASSETS.md`, `ART_PROMPTS.md`: provenance and generated-art recipe.

Active scope and verification: https://github.com/sarthakagrawal927/war-chest/issues/1

## Current boundaries

Local playable prototype, not a finished commercial-quality game. September 23 adds contracts and banners using the current keep/reward system, plus illustrated support troops and enemy roles. Owner acceptance remains open. No exported/notarized app, distinct battle maps, polished attack-animation sets, soundtrack, complete screen-reader support or long-term balance qualification yet. Source and media are local and uncommitted; remote is private and contains the tracking issue, not a pushed game build.
