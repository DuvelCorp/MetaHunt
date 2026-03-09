# Changelog

All notable changes to MetaHunt will be documented in this file.

## [1.1.0] - 2026-03-09

### Added
- Added new `ICU` module with dedicated options panel.
- Added ICU custom popup anchor mode with draggable anchor and direction toggle.
- Added ICU popup hide delay options (`INSTANT`, 1..10 seconds).
- Added new `Auto Quest` module for :
	- `Salt of the Scorpok` (`Bloodmage Drazial`)
	- `Arrows Are For Sissies` (`Artilleryman Sheldonore`)
- Added a Food Feed learning feature to Feed-O-Matic.
- Added Chronometer `Entrapment` effect tracking support.    

### Changed
- Loads of Frame/Handlers/Processes adjustments to optimize addon's CPU time and Memory usage.
- Updated Chronometer Improved Wing Clip effect color to `MAROON` for clearer effect-bar distinction.
- Reworked Stable Master processing to minimize swap-time overhead:
	- No auto-scan on `PET_STABLE_SHOW`.
	- Deferred stable scan moved to `PET_STABLE_CLOSED`.
	- Optional heavy workloads are skipped while stable UI is open.
- Changed Hunter Book page order, and default opening page to `Beast Lore`.
- Optimized `Pet History` result build/sort path using cached precomputed sort keys.
- Modules Auto-Buy, Auto-Quest, ICU, Feed-O-Matic are by default disabled on first use on a character.

### Fixed
- Fixed issues with zBouttons,Autostrp and Chronometer bar anchor not retaining their configured spawn position after the disabling/renabling of the Addon.
- Fixed issues with options checkbox-state not always retaining their state on startup.
- Fixed multiple issues in Feeed-O-Matic with some foods that were accepted by lvl 60 pets in Vanilla and are not anymore on Turtle.
- Fixed Chronometer spell/event disable toggles in options so disabled entries now reliably block bar creation.
- Fixed Chronometer `Feed Pet` bar missing trigger by adding `UNIT_AURA` fallback detection.
- Fixed stable swap stutter/freezes by removing heavy processing from repeated `UNIT_PET` bursts during stable interactions.


## [1.0.6] - 2026-03-05

### Fixed
- Added missing abilities to all pet families.
- Rescraped from Twow DB the previously in correct `Roar of Fortitude` pet-ability.
- Fixed an issue with Tooltip on pet action bar abilities, that were falsely displayed as not learned yet for rankless abilities.
- Restored visible Stable Master auto-scan feedback (`Stable scan complete: X slot(s).`) when opening the stable window.
- Fixed stable scan icon persistence for active pets that were never stabled by capturing current-pet icon data during stable scans.
- Hardened stable-scan bootstrap to initialize on both `PET_STABLE_SHOW` and `PET_STABLE_UPDATE` event paths.
- Fixed issues with taming pet metadata that were not properly recorded since the last update.
- Fixed issues with pet runaway interception that was broken since the last update.
- Updated version-update notification text to include clearer upgrade guidance and plain GitHub URL text for updates.
- Fixed an issue with `zTrack` buttons spells being incorrect after having respec the talents using brainwashing device.


## [1.0.5] - 2026-03-01

### Fixed
- Multiple changes to the addon to reduce its memory and CPU time footprint to the strict minimum possible.
- Restored FeedOMatic pet hunger notifications so hungry/very hungry warnings are emitted reliably again when enabled.
- Fixed Chronometer `Wing Clip` tracking by adding a safe fallback timer path for the missing trigger case.
- Fixed Chronometer `Quick Shots` bar icon by mapping the event to the correct icon texture.
- Fixed module enabled/disabled persistence to be truly per-character (`MTH_CharSavedVariables.moduleStates`) instead of account-shared.
- Fixed AutoBuy persistence fallback by removing undeclared `MTH_AutoBuy_Saved` paths and using module stores/transient runtime fallback only.
- Consolidated FeedOMatic legacy persistence to a single module-backed store (`modules.feedomatic.legacy`) with globals bound to that source.
- Switched Chronometer profile persistence to per-character module storage with one-time migration from existing account profile data.
- Switched Tooltips module options persistence to per-character module storage with one-time migration from existing account settings.

## [1.0.4] - 2026-02-27

### Added
- Added new zButton bar `zRanged` that tracks all ranged weapons in bags and allows to quickly swap them.
- Added structured localization architecture with dedicated locale packs under `locales/` and loader wiring through `init/localization.xml`.
- Added a dedicated `Messages` options panel with per-message toggles.
- Added Smart Ammo option `Enable Weapon-Swap Auto Ammo` to instantly equip best bullets/arrows when switching ranged weapon type.
- Added two new Hunter Book pages in the main tab bar: `Projectiles` and `Ammo Bags`

### Changed
- Reworked core localization runtime to support explicit locale fallback rules (`enUS`, `deDE`, `esES`, `ptBR`, `ruRU`, `zhCN`; no `frFR` target).
- Updated Hunter Book NPC finder and map vendor markers to use localized NPC names by NPC ID.
- Updated Hunter Book, item search/sort, AutoBuy item labels, and drop map markers to use localized item names by item ID.


### Fixed
- Fixed version metadata consistency so all first-party module descriptors report the same release version as the main addon.
- Fixed SmartAmmo junk-shot detection by including `Baited Shot` and `Tranquilizing Shot` in `MTH_AMMO_JUNKSHOT_SET`.
- Fixed zButtons options side effect where opening Mounts/Companions/Toys options could implicitly enable those buttons.
- Normalized zButtons checkbox defaults (`enabled`, `tooltip`, `hideonclick`, `parent.hide`, `parent.circle`, `showammoname`) so toggle states are always explicit and never nil.
- Fixed Beast Lore ability dropdown to exclude trainer-only abilities and list beast-learned abilities only.
- Removed junk `TBD` ability value from Wind Serpent dataset entry (`Venomflayer Serpent`) so it no longer appears in Beast Lore filters.
- Fixed zhunter child-button visibility restore so collapsed bars no longer hard-hide children (`ztrack` / `ztrap` expansion regression).
- Fixed pet tame metadata fallback so existing pets are not assigned current zone/time unless a real tame attempt is pending.
- Fixed Smart Ammo options copy mismatch by clarifying junk-shot swap behavior and restoring ammo target as previous equipped ammo.
- Fixed Smart Ammo default state so junk-shot swaps are enabled when no saved value exists.
- Fixed Beast Training startup prompt behavior so low-level hunters no longer receive training-scan warnings before level threshold.
- Restored hidden `/mth err` slash command behavior for debug-frame access.
- Fixed `zammo` children refresh on bag/inventory updates so newly acquired ammo types appear without `/reload`.
- Preserved `zammo` out-of-stock behavior so previously shown ammo entries still remain visible with zero/out state.
- Fixed intermittent `ztrack`/`ztrap` right-click expand/collapse issue after fresh login by preventing duplicate child-frame recreation during startup.
- Fixed `zpet` spell resolution after trainer updates by using robust spellbook lookup and immediate refresh on `LEARNED_SPELL_IN_TAB`.


## [1.0.3] - 2026-02-24

### Added
- Initial published release.
