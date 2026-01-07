extends RigidBody2D

class_name Item

var item_id: String = ""
var type: Utils.ItemType = Utils.ItemType.FRUIT
var score: int = 0
var is_dragging: bool = false
var was_interacted: bool = false
var velocity_cache: Vector2 = Vector2.ZERO
var blink_tween: Tween
# Add these to your variables in Item.gd
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

	# detection_area.input_event.connect(_on_input_event) # If using Area2D for input
	# RigidBody2D input_event is also possible if pickable is true

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				start_drag()
			else:
				end_drag()
	elif event is InputEventScreenTouch:
		if event.pressed:
			start_drag()
		else:
			end_drag()

func start_drag():
	is_dragging = true
	was_interacted = true
	freeze = true
	# Alternatively use freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC for smoother collisions while dragging

func end_drag():
	is_dragging = false
	freeze = false
	# Apply throw impulse
	linear_velocity = velocity_cache

	if type == Utils.ItemType.TRAP:
		linear_velocity *= 1.5 # Force Push Bonus!

func _physics_process(delta):
	if is_dragging:
		var target_pos = get_global_mouse_position()
		velocity_cache = (target_pos - global_position) / delta
		global_position = target_pos
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

func activate(start_pos: Vector2, new_item_id: String):
	lock_rotation = true # The item will no longer rotate via physics
	rotation = 0 # Reset to upright
	global_position = start_pos

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
