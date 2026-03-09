# GodotTools

A modular game tools library for Godot 4 providing reusable systems for multiplayer, gameplay, UI, and more. Each subdirectory is a self-contained plugin with its own `plugin.cfg`.

---

## Directory Overview

| Module | Description |
|---|---|
| [uuid.gd](uuid.gd) | UUID v4 generation utility |
| [asset_loading/](asset_loading/) | Load external resource packs (.zip) at runtime |
| [audio/](audio/) | Spatial audio spawning, cooldown players, UI sound themes |
| [external/](external/) | Third-party integrations (beehave, gloot, Steam) |
| [game_system/](game_system/) | Core gameplay: player controllers, health, inventory, equipment, interaction, navigation |
| [graphics/](graphics/) | Visual effects (outline shader) |
| [network/](network/) | Object property sync and replication status across multiplayer |
| [node_utility/](node_utility/) | General-purpose node utilities, signals, serialization, spawning |
| [pathfinding/](pathfinding/) | NavigationServer3D path validation queries |
| [player_prefs/](player_prefs/) | JSON key-value persistence, save/load system |
| [ui/](ui/) | Reusable UI: windows, menus, options, FPS counter, volume, cursors |
| [webrtc_signaling/](webrtc_signaling/) | Full multiplayer framework: signaling, player spawning, lobby UI |

---

## Module Details

### uuid.gd
UUID v4 generation. Class: `Uuid` (extends `RefCounted`).

| Method | Description |
|---|---|
| `static v4() -> String` | Generate a random UUID v4 |
| `static v4_rng(rng: RandomNumberGenerator) -> String` | Generate with custom RNG |
| `as_array() -> Array` | UUID as byte array |
| `as_string() -> String` | UUID as string |
| `is_equal(other) -> bool` | Compare two UUIDs |

---

### asset_loading/
Loads an external `assets.zip` resource pack on startup (non-editor builds only). Registered as autoload singleton `LoadAssets`.

---

### audio/

#### AudioStreamPlayer3DSpawner (`audio/AudioStreamPlayerSpawner/`)
Spawns one-shot 3D audio at the node's position with RPC support.
- `spawn()` — play the audio stream
- Properties: `stream: AudioStream`, `add_to_root: bool`

#### CooldownAudioStreamPlayer3D (`audio/cooldown_audio_stream_player/`)
`AudioStreamPlayer3D` that enforces a minimum interval between plays.
- Properties: `cooldown: float`

#### UISoundTheme (`audio/ui_sound_themes/`)
Automatically hooks into `BaseButton` signals to play contextual sounds (hover, press, release). Supports theme groups with inheritance via `SoundTheme` resources.

---

### external/

#### beehave/ — Behavior Trees
Extensions for the [beehave](https://github.com/bitbrain/beehave) framework.

| Class | Extends | Purpose |
|---|---|---|
| `Consideration` | `Node` | Base utility value calculator with tick rate and invert support |
| `UtilitySelectorComposite` | `Composite` | Selects child with highest utility score |
| `FailureCooldownDecorator` | `Decorator` | Cooldown period after child failure |
| `RandomCooldownDecorator` | `CooldownDecorator` | Cooldown with random variance |
| `SuccessTriggerDecorator` | `Decorator` | Locks in SUCCESS once child succeeds |
| `UtilityDecorator` | `AlwaysSucceedDecorator` | Abstract base for utility calculation |
| `AverageUtilityDecorator` | `UtilityDecorator` | Averages consideration values |
| `ExpressionUtilityDecorator` | `UtilityDecorator` | Custom expression-based utility |

Signals on `Consideration`: `value_changed(value: float)`

#### gloot/ — Inventory & Loot
Extensions for the [gloot](https://github.com/peter-kish/gloot) inventory framework.

**Item Providers:**
| Class | Purpose |
|---|---|
| `GlootItemProvider` | Base: provides items from an inventory by `item_type` |
| `GlootItemIdProvider` | Match items by `prototype_id` |
| `GlootSpecificOneTimeItemProvider` | Provide a single specific item once |

**Equipment & Effects:**
- `GlootItemSlotEquipmentEffect` — Applies/unapplies `EquipmentEffect` resources when items are equipped/unequipped. Tracks effect stacks.

**Loot System:**
- `LootTableFiller` — Fills an inventory from weighted `LootWeight` entries. Strategies: `ONCE` or `CUMULATIVE`.
- `LootWeight` — Resource with `prototype_id: String`, `weight: float`.

**UI Helpers:**
| Class | Purpose |
|---|---|
| `InventoryQuickStacker` | Auto-merge item stacks |
| `InventoryQuickTransfer` | Quick transfer between inventories |
| `GlootInventoryDragResizer` | Dynamic drag preview sizing |
| `HighlightDraggedEquipmentSlots` | Highlight valid equipment slots |
| `ShiftClickToUnequip` | Shift+click to unequip items |
| `CtrlInventoryOverlay` | Overlay display on inventory items |

#### steam/ — Steam Integration
- `SteamInit` — Initializes Steamworks API, reads `steam_appid.txt`.
- `SteamSignalingClient` — `SignalingClient` implementation using `SteamMultiplayerPeer` for lobby-based multiplayer.

---

### game_system/

#### PlayerController/ — Player Movement & Camera

**FPS Controller** (`game_system/PlayerController/fps/`):
- `Player` (extends `CharacterBody3D`) — First-person controller with sprint, crouch, prone.
- Supporting nodes: `fps_arms`, `fall_damage`, `lean`, `screen_shake`, `sprint_fov`, `stand_state`, `weapon_sway`, `recoil`, `player_death_cam`, `minimap_ui`, `world_text`

**TPS Controller** (`game_system/PlayerController/tps/`):
- `Player` — Third-person camera with configurable distance/height.
- `tps_camera` — Camera mechanics.

**2D Topdown Controller** (`game_system/PlayerController/topdown/`):
- `player_2d` — 2D top-down movement controller.

**Shared:** `shooter_controller` (base shooter mechanics), `smoothing` (movement smoothing).

#### consumable/ — Item Consumption
- `Consumable` (extends `Resource`) — Holds `effects: Array[ConsumableEffect]`. Call `consume(consumer_root, item_provider)`.
- `ConsumableEffect` — Abstract. Override `apply(root)` and `get_text()`.
- `Consumer` — Abstract base. Override `start_consumption(consumable, callback)`.
- `AnimatedConsumer` — Plays animation during consumption.
- `ImmediateConsumer` — Instant consumption.
- `ItemProvider` — Abstract interface for item lookup.

#### damageable/ — Health & Damage

**Damageable** (extends `Node`):
| Property | Type |
|---|---|
| `current_hp` | `float` |
| `max_hp` | `float` |
| `damage_modifiers` | `Array[DamageModifier]` |

| Method | Description |
|---|---|
| `damage(amount, source, ignore_modifiers, collision_shape)` | Apply damage |
| `is_dead() -> bool` | Check if dead |

| Signal | Description |
|---|---|
| `current_hp_changed(hp)` | HP changed |
| `current_hp_reduced(amount)` | HP reduced |
| `current_hp_changed_by_source(hp, source)` | HP changed with source info |
| `died` | Entity died |
| `revived` | Entity revived |

**Damage Modifiers:**
- `DamageModifier` — Abstract base
- `PercentageDamageModifier` — Percentage-based reduction
- `FlatPercentageDamageModifierPenetration` — Flat percentage with penetration
- `IndexedDamageModifier` — Per-collision-shape modifiers

**Utilities:** `DamageableRegen` (passive regen), `DeathSound`, `HurtSound`, `HurtVignette` (UI)

#### equipment/ — Equipment Effects
- `EquipmentEffect` (extends `Resource`) — Abstract. Override `apply(root)`, `unapply(root)`, `get_text()`. Has `EffectType` enum: `BUFF` / `DEBUFF`.
- Built-in: `MaxHPOnEquip`, `MovementSpeedOnEquip`.

#### interactable/ — Interaction System
- `Interactable` (extends `Node`) — Object that can be interacted with.
  - Properties: `interact_time`, `authority_only`, `interact_text`
  - Signal: `interacted(interactor)`, `no_param_interacted`
  - Method: `interact(interactor)` — triggers interaction (with RPC).
- `Interactor` — Abstract base for entities that interact.

#### level_bounds/ — Out-of-Bounds
- `LevelBounds` — Defines level extents.
- `DamageableKiller` / `Area3DDamageableKiller` — Kill or damage entities outside bounds.

#### metahuman/ — Character Customization
- `Metahuman` — Character color customization.
- `ColorSetter` — Applies colors to materials.

#### navigation_agents/ — NPC Movement
**3D:** `NavigationNode3D`, `NavigationCharacterBody3D`
**2D:** `NavigationNode2D`, `FourDirectionAnimationTree`, `FourDirectionAnimatedSprite2D`, `TwoDirectionAnimatedSprite2D`
**Utility:** `FloorSticker` — keeps character on ground.

#### notifications/ — Notification System
- `Notifications` (extends `Node`) — Global dispatcher. Call `emit(message, custom_toast_scene)`.
- Signal: `notification(Notification)`. Supports RPC broadcast.
- `Toast` / `ToastManager` — Toast UI display and lifecycle.

#### selectable/ — Selection System
- `Selectable2D` (extends `Area2D`) — 2D selectable object.
- `Selector` — Manages selection actions.

#### ticking/ — Damage Over Time
- `TickingResource` (extends `Resource`) — Base periodic effect.
- `TickingDamage` — Periodic damage application.

#### two_state_animatables/ — Open/Close Animations
- `TwoStateAnimatable` (extends `Node3D`) — State machine with open/close.
  - Methods: `play_open()`, `play_close()`, `toggle_open()`, `is_open()`
  - Properties: `open_animation`, `close_animation`, `open_on_ready`, `locked`
  - Signal: `locked_changed`
- `Door` — Door implementation.
- `UnlockInteractable` — Lockable interactable (requires key item).

---

### graphics/
- `outline_shader.gd` — Outline shader framework (tool script).

---

### network/

#### ObjectSync (`network/object_sync/`)
Synchronizes object properties across multiplayer peers using ZSTD compression.
- `attach(object_changed_signal, emit_recursive)` — Begin syncing.
- Uses `Serializer` for data compression.

#### NetworkSync (`network/sync/`)
Tracks replication status of nodes across the network.
- `replicated(node) -> bool` (async) — Wait until a node is replicated.
- Signal: `replicated_status(path, timed_out)`

---

### node_utility/

#### Core Utilities
| Class | Purpose |
|---|---|
| `Signals` | Safe signal connect/disconnect with lifecycle management |
| `TreeSync` | `await wait_for_inside_tree(node)` — async tree synchronization |
| `Serializer` | `serialize(obj)` / `deserialize(data, obj)` — JSON-based object serialization |
| `NodeDeleteSignaller` | Emits `predelete` signal before node deletion |

#### Spawning
| Class | Purpose |
|---|---|
| `OnDemandPathSpawner` | Spawn scenes from paths on demand |
| `OnDemandPackedSceneSpawner` | Spawn packed scenes (deprecated) |

#### Synchronization
| Class | Purpose |
|---|---|
| `PhysicsSync` | Physics state synchronization |
| `TransformChangedSignaller` | Emit signal on transform changes |

#### Node Management
| Class | Purpose |
|---|---|
| `FollowTarget` | Make a node follow another node |
| `AnimationTicker` | Tick-based animation control |
| `AutoRebakingNavObstacle3D` | Auto-update navigation obstacles |
| `NavAgentHeightAdjuster` | Adjust navigation agent height |
| `LightChecker` | Check if node is in light |
| `MultiplayerSynchronizerWorkaround` | Fix multiplayer sync edge cases |

#### Threading
- `WorkerthreadpoolExtended` — Extended thread pool utilities.

---

### pathfinding/
- `NavigationServerQueries` (extends `Node`) — Path validation.
  - `has_path_to(navAgent, startPos, targetPos) -> bool`

---

### player_prefs/

#### KeyValueStore (extends `Node`)
JSON-based persistent key-value storage.

| Method | Description |
|---|---|
| `set_value(key, value, save)` | Set and optionally persist |
| `get_value(key, default)` | Get value with fallback |
| `has_key(key) -> bool` | Check existence |
| `delete_key(key, save)` | Remove key |
| `save()` | Write to disk |

Signal: `value_changed(key)`

- `PlayerPrefs` — Singleton extending `KeyValueStore`, auto-saves to `user://playerprefs.save`.
- `SaveData` / `SaveGames` — Save file and collection management.

---

### ui/

| Component | Purpose |
|---|---|
| `ControlWindow` | Draggable window with close button, exclusivity support |
| `InputActionButton` | Button that triggers Godot input actions |
| `CustomCursor` | Custom mouse cursor display |
| `EscapeMenuNode` | Escape menu with leave/quit options |
| `EmbeddedUI` | Embed Control nodes into 3D world |
| `FPSCounter` | Framerate display |
| `InputPassthroughWindow` | Allow input through UI layers |
| `PlayerReady` | Player readiness UI with widget |
| `SplashScreen` | Splash screen display |
| `TopdownItemPlacer` | UI for placing items in top-down view |
| `VisibilityReparenter` | Reparent node on visibility change |
| `Volume` | Audio volume slider control |
| `DisableUINoAuthority` | Hide UI elements without network authority |

**Options Menu** (`ui/options_menu/`): Keybinds, video (3D scale, FSR, fullscreen, VSync, FPS cap, UI scale), performance (multiprocess, port), controls (mouse sensitivity), logs.

---

### webrtc_signaling/ — Multiplayer Framework

#### Client Layer
| Class | Purpose |
|---|---|
| `SignalingClient` | Abstract base — signals: `connected`, `disconnected`, `room_list_received`, `lobby_joined`, `join_error` |
| `MultiplayerClient` | Standard WebRTC client |
| `MultiplayerLocalhostClient` | Local testing (no network) |
| `WSWebRTCClient` | WebSocket-based WebRTC |

#### Server Layer
- `WSWebRTCServer` — WebSocket signaling server.
- `JoinPacket` — Network packet structure.

#### Game Layer
| Class | Purpose |
|---|---|
| `PlayerSpawner` | `MultiplayerSpawner` with custom `spawn(id)` and signal `player_spawning(id, player)` |
| `SceneSwitcher` | Handle scene transitions in multiplayer |
| `SpawnerShifter` / `SpawnerShifter3D` | Modify spawned objects |

#### UI Layer
`MainMenu`, `MainUI`, `ClientUI`, `LoadingScreen`, `PlayerList`, `AuthorityActions`, `RoomTabContainer`, `Multiprocess`, `PlayerInfo`

---

## Key Patterns

- **Signal Safety**: Use `Signals.safe_connect()` for auto-cleanup on node deletion.
- **Network Authority**: Methods check `is_multiplayer_authority()` and use RPCs for cross-peer calls.
- **Composition over Inheritance**: Systems are composed of small, focused nodes.
- **Resource-Based Config**: Data is defined in `.tres` Resource files.
- **Serialization**: `Serializer.serialize()` / `deserialize()` for network data and persistence.
- **Async**: `await` and `call_deferred()` for safe ordering of operations.
