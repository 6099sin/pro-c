extends RigidBody2D

class_name Item

var type: Utils.ItemType = Utils.ItemType.FRUIT
var is_dragging: bool = false
var velocity_cache: Vector2 = Vector2.ZERO

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
	freeze = true
	# Alternatively use freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC for smoother collisions while dragging
	
func end_drag():
	is_dragging = false
	freeze = false
	# Apply throw impulse if needed, based on mouse velocity

func _physics_process(_delta):
	if is_dragging:
		var target_pos = get_global_mouse_position()
		global_position = target_pos
		# Calculate velocity for throw...

func activate(start_pos: Vector2, new_type: Utils.ItemType):
	global_position = start_pos
	type = new_type
	is_dragging = false
	freeze = false
	visible = true
	
	# Reset physics
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	# Set Texture based on type
	if type == Utils.ItemType.FRUIT:
		sprite.modulate = Color(1, 0, 0) # Red for fruit placeholder
	else:
		sprite.modulate = Color(0, 0, 0) # Black for bomb placeholder

func deactivate():
	visible = false
	freeze = true
	global_position = Vector2(-1000, -1000)
	# Add back to pool logic would go here if managed by Spawner directly
	# For now, spawner will just check 'visible' or we handle it via signal

func _on_VisibleOnScreenNotifier2D_screen_exited():
	deactivate()
