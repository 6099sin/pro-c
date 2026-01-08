extends Node2D

@export var item_scene: PackedScene
@export var pool_size: int = 30

@export_group("Spawn Settings")
@export_range(0.0, 1.0) var fruit_ratio: float = 0.8
@export_range(0.0, 1.0) var spawn_y_min_ratio: float = 0.6
@export_range(0.0, 1.0) var spawn_y_max_ratio: float = 0.85
@export var min_scale: float = 1.0
@export var max_scale: float = 1.0

const MERGE_MAP: Dictionary = {
	"t1": "t2",
	"t2": "f1",
	"f1": "f2",
	"f2": "f3",
}

var pool: Array[Item] = []

@onready var spawn_timer: Timer = $SpawnTimer

func _ready():
	randomize()
	# Preload item scene if not set in inspector (stub)
	if not item_scene:
		# item_scene = load("res://scenes/objects/Item.tscn")
		pass

	# Initialize Pool
	# Defer initialization to ensure scene tree is ready if we instance via code
	call_deferred("init_pool")

	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()
	
	SignalBus.bonus_event.connect(_on_bonus_event)

func init_pool():
	ensure_pool_size(pool_size)

func ensure_pool_size(target_size: int):
	if not item_scene: return
	
	var current_size = pool.size()
	if current_size >= target_size: return
	
	var amount_to_add = target_size - current_size
	for i in range(amount_to_add):
		_create_and_add_item()

func _create_and_add_item():
	var item = item_scene.instantiate()
	item.visible = false
	item.freeze = true
	add_child(item)
	pool.append(item)

func _on_bonus_event(is_active: bool):
	if is_active:
		# Expand pool to 50 for bonus event
		ensure_pool_size(50)

func get_inactive_item() -> Item:
	for item in pool:
		if not item.visible:
			return item
	return null

func _on_spawn_timer_timeout():
	if not GameManager.is_game_active: return

	var spawn_count = 1
	if GameManager.is_bonus_active:
		# Spawn 4 items at once during bonus
		spawn_count = 4

	for i in range(spawn_count):
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
	# Don't natively pick bonus from the main list unless we explicitly want to add it there
	all_items.erase("bonus")
	
	var picked_id = ""

	# Check Bonus Mode
	if GameManager.is_bonus_active:
		# 100% Fruit Ratio
		picked_id = all_items.pick_random()
		while Utils.ITEM_DATA[picked_id].type != Utils.ItemType.FRUIT:
			picked_id = all_items.pick_random()
	else:
		# Normal Spawn Logic
		if randf() < 0.05: # Increased to 5% for better visibility
			picked_id = "bonus"
			print("SPAWN: Bonus Item Created!")
		else:
			picked_id = all_items.pick_random()
			
			if randf() < fruit_ratio:
				# Bias towards Fruit
				while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.TRAP:
					picked_id = all_items.pick_random()
			else:
				# Bias towards Trap
				while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.FRUIT:
					picked_id = all_items.pick_random()

	item.activate(Vector2(start_x, start_y), picked_id, self)

	# Random Scale
	var rnd_scale = randf_range(min_scale, max_scale)
	item.scale = Vector2(rnd_scale, rnd_scale)

	# Calculate Velocity (Arc toward centerish)
	var force_x = randf_range(200, 400)
	if start_x > 0: force_x *= -1 # throw left if spawned right

	var force_y = - randf_range(650, 950)

	item.linear_velocity = Vector2(force_x, force_y)
	item.angular_velocity = randf_range(-10, 10)


func handle_merge(item1: Item, item2: Item):
	if not MERGE_MAP.has(item1.item_id):
		return

	var next_item_id = MERGE_MAP[item1.item_id]
	var merge_pos = (item1.global_position + item2.global_position) / 2
	var combined_score = item1.score + item2.score

	item1.deactivate()
	item2.deactivate()

	var new_item = get_inactive_item()
	if new_item:
		new_item.activate(merge_pos, next_item_id, self)
		# Add a small scale-in effect for polish
		new_item.scale = Vector2.ZERO
		var tween = create_tween()
		var final_scale = randf_range(min_scale, max_scale)
		tween.tween_property(new_item, "scale", Vector2(final_scale, final_scale), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	GameManager.add_score(combined_score + Utils.ITEM_DATA[next_item_id].score)
