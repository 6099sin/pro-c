extends Node2D

@export var item_scene: PackedScene
var pool: Array[Item] = []
var pool_size: int = 30

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
	var start_y = randf_range(screen_h * 0.6, screen_h * 0.85)
	
	var all_items = Utils.ITEM_DATA.keys()
	var picked_id = all_items.pick_random()
	
	# Weighted spawn logic if needed (e.g. less bombs), but for now random is fine
	# Or implement simple weight: Try to get a fruit 80% of time
	if randf() < 0.8:
		# Force restart if we got a trap, to bias towards fruit (Primitive weighting)
		while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.TRAP:
			picked_id = all_items.pick_random()
	else:
		# Force restart if we got a fruit, to bias towards trap
		while Utils.ITEM_DATA[picked_id].type == Utils.ItemType.FRUIT:
			picked_id = all_items.pick_random()
	
	item.activate(Vector2(start_x, start_y), picked_id)
	
	# Calculate Velocity (Arc toward centerish)
	var force_x = randf_range(200, 400)
	if start_x > 0: force_x *= -1 # throw left if spawned right
	
	var force_y = - randf_range(650, 950)
	
	item.linear_velocity = Vector2(force_x, force_y)
	item.angular_velocity = randf_range(-10, 10)
