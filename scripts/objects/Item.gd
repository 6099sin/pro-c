extends RigidBody2D

class_name Item

var item_id: String = ""
var type: Utils.ItemType = Utils.ItemType.FRUIT
var score: int = 0
var is_dragging: bool = false
var was_interacted: bool = false
var velocity_cache: Vector2 = Vector2.ZERO
var blink_tween: Tween
var spawner: Node
# Add these to your variables in Item.gd
var drag_touch_index: int = -1
var target_drag_pos: Vector2 = Vector2.ZERO
@export var max_angle_deg: float = 45.0
@export var min_angle_deg: float = -45.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var detection_area: Area2D = $DetectionArea

# Textures (load these or assign in inspector in real project, using placeholders here)
# var fruit_texture = preload(...)
# var bomb_texture = preload(...)

func _ready():
	input_pickable = true
	detection_area.area_entered.connect(_on_detection_area_entered)

	# detection_area.input_event.connect(_on_input_event) # If using Area2D for input
	# RigidBody2D input_event is also possible if pickable is true

func _input_event(_viewport, event, _shape_idx):
	if is_dragging:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				drag_touch_index = -1 # Mouse ID
				start_drag(get_global_mouse_position())
	elif event is InputEventScreenTouch:
		if event.pressed:
			drag_touch_index = event.index
			var pos = get_canvas_transform().affine_inverse() * event.position
			start_drag(pos)

func _input(event):
	if not is_dragging:
		return
	
	if event is InputEventScreenTouch:
		if event.index == drag_touch_index and not event.pressed:
			end_drag()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and drag_touch_index == -1:
			end_drag()
	elif event is InputEventScreenDrag:
		if event.index == drag_touch_index:
			target_drag_pos = get_canvas_transform().affine_inverse() * event.position
	elif event is InputEventMouseMotion:
		if drag_touch_index == -1:
			target_drag_pos = get_global_mouse_position()

func start_drag(start_pos: Vector2):
	is_dragging = true
	was_interacted = true
	freeze = true
	target_drag_pos = start_pos
	# Alternatively use freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC for smoother collisions while dragging

func end_drag():
	is_dragging = false
	freeze = false
	drag_touch_index = -1
	# Apply throw impulse
	linear_velocity = velocity_cache

	if type == Utils.ItemType.TRAP:
		linear_velocity *= 1.5 # Force Push Bonus!

func _physics_process(delta):
	if is_dragging:
		velocity_cache = (target_drag_pos - global_position) / delta
		global_position = target_drag_pos
	else:
		# 1. Convert degrees to radians for Godot's rotation property
		var min_rad = deg_to_rad(min_angle_deg)
		var max_rad = deg_to_rad(max_angle_deg)

		# 2. Clamp the current rotation
		var clamped_rotation = clamp(rotation, min_rad, max_rad)

		# 3. If rotation hits the limit, stop the spinning (angular velocity)
		if rotation != clamped_rotation:
			rotation = clamped_rotation
			angular_velocity = 0 # Prevents the "vibrating" look at the edge

func _on_detection_area_entered(area: Area2D):
	var other_item = area.get_parent()
	if not other_item is Item:
		return

	# Conditions for merging
	if (other_item.item_id == item_id and
		spawner and
		not is_dragging and not other_item.is_dragging and
		sleeping and other_item.sleeping and
		get_instance_id() < other_item.get_instance_id()): # Prevents double merge calls
			spawner.handle_merge(self, other_item)

func activate(start_pos: Vector2, new_item_id: String, spawner_node: Node):
	lock_rotation = true # The item will no longer rotate via physics
	rotation = 0 # Reset to upright
	global_position = start_pos
	spawner = spawner_node # Store spawner reference

	item_id = new_item_id
	var data = Utils.ITEM_DATA[item_id]
	type = data.type
	score = data.score

	if data.texture_path != "":
		var tex = load(data.texture_path)
		if tex:
			sprite.texture = tex
			sprite.modulate = Color.WHITE # Reset color if using real texture
	else:
		# Fallback to color tint
		sprite.modulate = data.color

	is_dragging = false
	was_interacted = false
	freeze = false
	visible = true

	# Reset physics
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0

	# Set Texture based on type (Handled in activate)
	if type == Utils.ItemType.TRAP:
		blink_tween = create_tween().set_loops()
		blink_tween.tween_property(sprite, "modulate", data.color, 0.5)
		blink_tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)

func deactivate():
	if blink_tween and blink_tween.is_valid():
		blink_tween.kill()

	visible = false
	freeze = true
	global_position = Vector2(-1000, -1000)
	# Add back to pool logic would go here if managed by Spawner directly
	# For now, spawner will just check 'visible' or we handle it via signal

func _on_VisibleOnScreenNotifier2D_screen_exited():
	deactivate()
