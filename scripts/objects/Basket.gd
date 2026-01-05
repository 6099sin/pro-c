extends Node2D

@onready var snap_zone: Area2D = $SnapZone
@onready var center_point: Marker2D = $CenterPoint
@onready var sprite: Sprite2D = $Node2D/Sprite2D
@export var setTexture: Array[Texture]
func _ready():
	snap_zone.body_entered.connect(_on_body_entered)
	center_on_camera()

func center_on_camera():
	var screen_size = Utils.get_screen_size(self)
	position.x = screen_size.x / 2.0

func _on_body_entered(body):
	if body is Item:
		# Don't snap if user is still holding it (optional design choice)
		if not body.is_dragging:
			# TRAP: Always triggers (Obstacle)
			if body.type == Utils.ItemType.TRAP:
				receive_item(body)
			# FRUIT: Only triggers if interacted (Collectible)
			elif body.type == Utils.ItemType.FRUIT and body.was_interacted:
				receive_item(body)

func receive_item(item: Item):
	# Snap visuals
	var tween = create_tween()
	tween.tween_property(item, "global_position", center_point.global_position, 0.1)
	tween.tween_callback(func(): process_item(item))

func process_item(item: Item):
	play_hit_effect(item.type)
	
	if item.type == Utils.ItemType.FRUIT:
		GameManager.add_score(item.score)
		SignalBus.request_sfx.emit("pop")
	else:
		GameManager.add_score(item.score)
		SignalBus.request_sfx.emit("explosion")
		# Maybe trigger game over or penalty?
		# GameManager.end_game() # if bombs are fatal
	
	item.deactivate()

func play_hit_effect(type: Utils.ItemType):
	var tween = create_tween().set_parallel(true)
	
	# Stretch / Squash
	sprite.scale = Vector2(0.9, 0.7)
	sprite.texture=setTexture[3] if type == Utils.ItemType.FRUIT else setTexture[0]
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Color Flash
	var flash_color = Color(0.5, 1.5, 0.5) if type == Utils.ItemType.FRUIT else Color(1.5, 0.5, 0.5)
	sprite.modulate = flash_color
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)
