Fruit Basket Dash - Developer InstructionsEngine: Godot 4.5Platform: Web (HTML5) / MobileBased on GDD v2.11. Project Directory StructureCreate the following folder structure in the FileSystem dock to maintain a clean project hierarchy.res://
├── assets/
│   ├── sprites/          # Fruits, Bomb, Basket, Backgrounds
│   ├── audio/            # SFX, Music
│   └── fonts/            # Game fonts
├── scenes/
│   ├── core/             # Main game loops (Main.tscn, MainMenu.tscn)
│   ├── objects/          # Game objects (Item.tscn, Basket.tscn, Spawner.tscn)
│   └── ui/               # HUD, GameOver screens (HUD.tscn)
├── scripts/
│   ├── autoloads/        # Global Managers (GameManager.gd, SignalBus.gd)
│   ├── core/             # Utils.gd
│   ├── objects/          # Item.gd, Basket.gd, Spawner.gd
│   └── ui/               # HUD.gd
└── resources/            # Custom resources (if needed)
2. Autoloads & Global ScriptsConfigure these in Project Settings > Globals.A. scripts/autoloads/SignalBus.gdType: Node (Autoload: SignalBus)Purpose: Centralized Event Bus (Observer Pattern).Signals:score_updated(new_score: int)time_updated(time_left: float)game_over(final_score: int, grade: String)request_sfx(sfx_name: String)B. scripts/autoloads/GameManager.gdType: Node (Autoload: GameManager)Purpose: Manage game state, score, combo, and timer.Logic:Connect to SignalBus signals._process(delta): Decrease timer. Check for Timeout.add_score(amount): Handle Combo multiplier logic (x0.1 per item, max x3.0).reset_combo(): Called on bomb hit or timeout.C. scripts/core/Utils.gdType: RefCounted (No Node required)Important: Add class_name Utils at the top of the script.Constants:SCREEN_WIDTH, SCREEN_HEIGHT (Get from DisplayServer or ProjectSettings)GRAVITY = 980.0Enums:enum ItemType { FRUIT, TRAP }enum Grade { S, A, B, C, F }Functions:static func format_time(seconds: float) -> String3. Game Object Scenes & Node TreesA. Item (Fruit/Bomb)Path: scenes/objects/Item.tscnScript: scripts/objects/Item.gd (extends RigidBody2D)Node Tree:Item (RigidBody2D)
├── Sprite2D             # Texture holder
├── CollisionShape2D     # Physics collision (CircleShape2D)
├── DetectionArea (Area2D)
│   └── CollisionShape2D # Slightly larger than physics shape (for touch detection)
└── VisibleOnScreenNotifier2D # To detect when it leaves screen (for pooling)
Script Implementation Details:Variables: type: Utils.ItemType, is_dragging: bool, velocity_cache: Vector2.Physics:input_pickable = true on RigidBody2D.Connect _input_event signal.Drag Logic: When touched, set freeze = true (or freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC). Update global_position to mouse position in _physics_process.Release Logic: When released, set freeze = false. Apply impulse if thrown (optional).Pooling Logic:Func activate(start_pos, type): Reset state, enable physics, set texture.Func deactivate(): Disable collision, hide, reset physics state, return to pool.B. BasketPath: scenes/objects/Basket.tscnScript: scripts/objects/Basket.gd (extends Node2D)Node Tree:Basket (Node2D)
├── Sprite2D (Back)      # Basket visual (behind items)
├── CenterPoint (Marker2D) # The exact point items snap to
├── SnapZone (Area2D)    # Trigger area
│   └── CollisionShape2D # CircleShape2D (Larger than basket)
└── Sprite2D (Front)     # (Optional) Basket front lip to create depth
Script Implementation Details:Connect SnapZone.body_entered (or area_entered depending on Item setup).Magnetic Snap: If an item enters SnapZone AND !item.is_dragging:Tween item position to CenterPoint.Check item.type:If FRUIT: GameManager.add_score(), Play 'Pop' animation.If TRAP: GameManager.reset_combo(), Screen Shake, Deduct score/End game.Call item.deactivate().C. Spawner (Object Pooling)Path: scenes/objects/Spawner.tscnScript: scripts/objects/Spawner.gd (extends Node2D)Node Tree:Spawner (Node2D)
└── SpawnTimer (Timer)   # Controls spawn rate
Script Implementation Details:Pool: var pool: Array[RigidBody2D] = []_ready(): Instantiate 30-50 Item scenes, deactivate() them immediately, and add to pool.get_item(): Find first inactive item in pool. If none, instantiate new (expandable pool).Side Toss Logic (on Timer timeout):Pick side: Left (x = -50) or Right (x = SCREEN_WIDTH + 50).Pick height: y = randf_range(screen_h * 0.6, screen_h * 0.85).Velocity Calculation:X Force: Towards center (positive if left spawn, negative if right).Y Force: -randf_range(650, 950) (Upwards).Apply linear_velocity to the item.4. UI Implementation (HUD)Path: scenes/ui/HUD.tscnScript: scripts/ui/HUD.gd (extends Control)Node Tree:HUD (Control)
├── TopBar (HBoxContainer)
│   ├── ScoreLabel (Label)
│   ├── TimerLabel (Label)
│   └── ComboContainer (VBoxContainer)
│       ├── ComboBar (ProgressBar)
│       └── ComboMultiplierLabel (Label)
Script Implementation Details:_ready(): SignalBus.score_updated.connect(update_score_ui), SignalBus.time_updated.connect(update_timer_ui).Use Tween for juice (scale up score when it changes).5. Game Loop ImplementationPath: scenes/core/Main.tscnNode Tree:Main (Node2D)
├── Background (Sprite2D/TextureRect)
├── Spawner (Instance)
├── Basket (Instance)    # Positioned at bottom center
└── CanvasLayer (UI Layer)
    └── HUD (Instance)
Workflow:GameManager starts the game (resets vars).Spawner starts SpawnTimer.Player interacts with Items.On GameManager timeout -> Stop Spawner -> Show Game Over UI.Key RemindersNever use queue_free() on Items during gameplay. Always deactivate() to keep garbage collection low.Physics Layers:Layer 1: World/WallsLayer 2: ItemsLayer 3: Basket DetectionTesting: Ensure the "Side Toss" forces feel right. The fruit should form an upside-down 'U' shape and fall naturally near the basket area if not touched.