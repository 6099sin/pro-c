extends Node2D

@onready var snap_zone: Area2D = $SnapZone
@onready var center_point: Marker2D = $CenterPoint

func _ready():
	snap_zone.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is Item:
		# Don't snap if user is still holding it (optional design choice)
		if not body.is_dragging:
			# Only snap if the user has interacted with it (touched it)
			if body.was_interacted:
				receive_item(body)

func receive_item(item: Item):
	# Snap visuals
	var tween = create_tween()
	tween.tween_property(item, "global_position", center_point.global_position, 0.1)
	tween.tween_callback(func(): process_item(item))

func process_item(item: Item):
	if item.type == Utils.ItemType.FRUIT:
		GameManager.add_score(10)
		SignalBus.request_sfx.emit("pop")
	else:
		GameManager.add_score(-10)
		SignalBus.request_sfx.emit("explosion")
		# Maybe trigger game over or penalty?
		# GameManager.end_game() # if bombs are fatal
	
	item.deactivate()
