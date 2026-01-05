extends Node2D

@export var item_scene: PackedScene
@export var pool_size: int = 30

@export_group("Spawn Settings")
@export_range(0.0, 1.0) var fruit_ratio: float = 0.8
@export_range(0.0, 1.0) var spawn_y_min_ratio: float = 0.6
@export_range(0.0, 1.0) var spawn_y_max_ratio: float = 0.85
@export var min_scale: float = 1.0
@export var max_scale: float = 1.0

var pool: Array[Item] = []

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	# Preload item scene if not set in inspector (stub)
	if not item_scene:
		# item_scene = load("res://scenes/objects/Item.tscn")
		pass

	# Initialize Pool
	# Defer initialization to ensure scene tree is ready if we instance via code
	call_deferred("init_pool")

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func init_pool():
	if not item_scene: return

	for i in range(pool_size):
		var item = item_scene.instantiate()
		item.visible = false
		item.freeze = true
		add_child(item)
		pool.append(item)

func get_inactive_item() -> Item:
	for item in pool:
		if not item.visible:
			return item
	return null

func _on_spawn_timer_timeout():
	if not GameManager.is_game_active: return

	var item = get_inactive_item()
	if item:
		spawn_item(item)

func spawn_item(item: Item):
	var screen_size = Utils.get_screen_size(self)
	var screen_w = screen_size.x
	var screen_h = screen_size.y

	# Randomize Side
	var start_x = -50 if randf() < 0.5 else screen_w + 50
	var start_y = randf_range(screen_h * spawn_y_min_ratio, screen_h * spawn_y_max_ratio)

	var all_items = Utils.ITEM_DATA.keys()
	all_items.erase("bonus")
	var picked_id = all_items.pick_random()

	# Weighted spawn logic if needed (e.g. less bombs), but for now random is fine
	# Or implement simple weight: Try to get a fruit 80% of time
	if randf() < fruit_ratio:
		# Force restart if we got a trap, to bias towards fruit (Primitive weighting)
		while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.TRAP:
			picked_id = all_items.pick_random()
	else:
		# Force restart if we got a fruit, to bias towards trap
		while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.FRUIT:
			picked_id = all_items.pick_random()

	item.activate(Vector2(start_x, start_y), picked_id)

	# Random Scale
	var rnd_scale = randf_range(min_scale, max_scale)
	item.scale = Vector2(rnd_scale, rnd_scale)

	# Calculate Velocity (Arc toward centerish)
	var force_x = randf_range(200, 400)
	if start_x > 0: force_x *= -1 # throw left if spawned right

	var force_y = - randf_range(650, 950)

	item.linear_velocity = Vector2(force_x, force_y)
	item.angular_velocity = randf_range(-10, 10)
