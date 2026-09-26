---
name: Banner & Steel
description: A company worth commanding. Flat illustrated turn-based warfare.
colors:
  paper: "#f4ebd8"
  navy: "#203340"
  blue: "#405947"
  sky: "#dfd4bb"
  coral: "#9d4133"
  gold: "#dbac51"
  muted: "#596050"
---
# Design System: War Chest

## Overview
**Creative North Star: "Banner & Steel"**
Owner explicitly selected refined A on September 23 after rejecting the childish Pocket Siege presentation. Approved reference: `artifacts/onboarding-directions/a-banner-steel.png`. Mature, simple flat illustration with adult-proportioned troops, an olive company standard and warm stone terrain. Preserve every tactical rule and saved campaign. The previous system is archived at `.fleet/pocket-siege-design-history.md`.

## Colors
Warm paper controls over limestone scenery; ink text, olive company identity, brick hostile intent, ochre orders and selection. Pair every status color with text or an outline. No pastel blue expanses or candy accents.

## Typography
Georgia titles with Times New Roman fallback; Avenir Next/Arial for rules and controls. 18–20 px body, 28–44 px titles on a 1440x900 canvas. Compact serif identity without engraved ornament; no rounded display faces.

## Layout
Full-window world. Three vertical approaches with troops facing opposing formations, objective/turn above, native equipment commands on a paper rail below. One inspection area explains selected commands and targets. Keep/chest/reward use quiet paper surfaces over the same world. New campaigns open directly in battle; earned-rune packing is the first preparation decision. Supported desktop canvas 1152x720 or larger, aspect-preserving; mobile unsupported.

## Elevation & Depth
Flat illustrative layers with restrained two-tone shading, olive woodland and broad warm-stone bridges. No photographic texture, ornate metal frames or realistic rendering. Borders distinguish playable commands. Existing short hit/reposition feedback and one-shot reward seal respect reduced motion.

## Shapes
Adult-proportioned illustrated troops, lean wolf, broad castle planes, squared low-chrome controls with 4px corners. Scenery and the company use generated raster assets; command symbols, stats, instructions, fronts, selection and all controls remain native and live. Never bake interface or troops into the background.

## Components
Native Buttons expose text, focus, hover and disabled state. Target actors use focusable controls as well as mouse hit regions. Exact health and intent remain inspectable. Equipment cells show footprint, valid placement and rune linkage. Purchases state earned-gold costs.

## Do's and Don'ts
- Keep scenery quieter than characters and decisions.
- Use the same simple art throughout the game, including rewards and inventory.
- Show rules in context; never remove necessary information for minimalism.
- Preserve progress and saves, including on defeat.
- Do not reintroduce realistic illustrations, chibi proportions, dense floating labels or ornate fantasy chrome.
- Do not describe a generated concept as the working game.

## Historical implementation notes — superseded visual system

The sections below describe earlier Pocket Siege increments. Their gameplay/motion invariants remain useful; their palette, composition and shape descriptions are historical, not the approved Banner & Steel contract above.

### September 23 gameplay expansion — preserve lane
Extend the existing keep with Campaign / War contracts / Banners selectors, and the reward screen with three concrete upgrade choices. Keep palette, typography, positions and native controls. Illustrated company sprites now also appear on keep/reward/shop; a matching transparent atlas adds Merrin, Talon, ballista, armored guards, archers and sappers. Traits and banner effects remain readable text, not sprite-only information. This bounded expansion does not imply final owner acceptance of the whole visual system.

The mastery upgrade preserves this system: native two-line mastery buttons below keep heroes, inspectable rank-up buttons in unused reward space, and one optional-objective text strip above the fronts. Effects use the existing feedback footer and command inspection, not a new menu. Boss health uses a star and gold fill instead of a colliding overhead label. New rank effects apply next battle and are described at the point of reward. Supported evidence is native desktop, not mobile/browser certification.

## Interaction motion — preserve lane

Command-to-impact is the focal moment. Use short lunges, slashes, arrow/spell trails and outcome-specific pulses; no idle loops, camera shake or delayed rules. A copied presentation timeline expires within 0.68s. Projectile aftermath begins after arrival; defeated silhouettes fade before slot compression. Native hit regions follow interpolated positions and replacement timelines begin from the current rendered position. Shoulder labels avoid the preceding front's health badge. Enemy feedback excludes attacks skipped after a fixed target dies and explicitly reports absorbed block.

The final battlefield result has a skippable 0.57s presentation hold; rewards are already committed. Native button response lasts 0.14s and reward illustrations reveal once over 0.32s. Undo, navigation and reduced motion cancel unfinished effects. Reduced motion uses stationary outcome text instead of spatial effects. No palette, layout, gameplay rule, save-schema or asset changes in this increment. Existing non-16:10 stretch behavior still needs a separate adaptation pass; it does not yet meet the aspect-preserving intent above.

## First-session guidance — preserve lane

Teach through actual orders, not a modal tour. Four optional field lessons reuse the objective strip and inspection footer, temporarily replacing the optional-objective display without removing its reward. Successful attack, cross-front Volley, block and enemy-turn resolution teach the core decisions; actions are never forced or restricted. Guidance must recover from changed equipment, fallen heroes and exhausted orders. Skipping remains visible; completion and undo track actual campaign actions. Existing saves are not enrolled retroactively.

Keep existing cards, scenery and reward hierarchy. Starter preparation copy reflects actual packed gear. Contracts/banner management are labelled level-two unlocks. Reward text separates immediate skills from things that need buying/recruiting/packing. Focal animations: paired Cleave strokes with a short impact burst, and a bounded 0.65s gold level seal. Neither delays rules or hides actionable controls. No new assets or dependencies. Native visual requalification is pending; headless layout and logic checks do not certify appearance or feel.

## Side-story journey — preserve lane

Reuse the keep's selector panel for six optional quests, with chapter, prerequisite, progress and concrete rewards. Level-two guidance announces the new route. The battlefield's existing objective strip states the next destination or survival condition; coral front shading is paired with exact bombardment text. Quest losses explain timeout, escort death, gate loss or voluntary withdrawal. Contract tier tooltips name the alternate quest milestone.

Quest rewards occupy the existing blank upper-left reward area; mastery buttons and bonus-gold notices remain independent. Owned equipment uses two columns inside the existing chest panel so all eleven items remain accessible. Relics reuse native command glyphs. No new art, dependency or visual identity. Headless geometry checks cover descriptions, reward copy and equipment controls; fresh native visual evidence is still blocked by the host's application-initialization failure.
