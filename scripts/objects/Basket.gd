extends Node2D

@onready var snap_zone: Area2D = $SnapZone
@onready var center_point: Marker2D = $CenterPoint
@onready var sprite: Sprite2D = $Node2D/Sprite2D
@export var setTexture: Array[Texture2D]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const SFX_COIN = preload("res://assets/Sound/Retro Coin 2.mp3")
const SFX_ERROR = preload("res://assets/Sound/1_Error_C.wav")

func _ready():
	snap_zone.body_entered.connect(_on_body_entered)
	center_on_camera()

func center_on_camera():
	var screen_size = Utils.get_screen_size(self)
	position.x = screen_size.x / 2.0
	position.y = screen_size.y - screen_size.y / 4.0
func _on_body_entered(body):
	if body is Item and GameManager.is_game_active:
		# Don't snap if user is still holding it (optional design choice)
		if not body.is_dragging:
			# TRAP: Always triggers (Obstacle)
			if body.type == Utils.ItemType.TRAP:
				receive_item(body)
			# BONUS: Always triggers (Collectible)
			elif body.type == Utils.ItemType.BONUS and body.was_interacted:
				receive_item(body)
			# FRUIT: Only triggers if interacted (Collectible)
			elif body.type == Utils.ItemType.FRUIT and body.was_interacted:
				receive_item(body)

func receive_item(item: Item):
	# Trigger VFX immediately
	trigger_vfx(item)
	
	# Snap visuals
	var tween = create_tween()
	tween.tween_property(item, "global_position", center_point.global_position, 0.1)
	tween.tween_callback(func(): process_item(item))

@onready var pop_star_container = $PopStarPariticle

func trigger_vfx(item: Item):
	# VFX Trigger for Fruits
	if item.type == Utils.ItemType.FRUIT:
		var new_vfx = pop_star_container.duplicate()
		add_child(new_vfx)
		
		var id = item.item_id
		if id == "fruit_1":
			new_vfx.position.y = -7
		elif id == "fruit_2":
			new_vfx.position.y = 6
			
		var emitter = new_vfx.get_node("GPUParticles2D")
		emitter.emitting = true
		
		# Cleanup
		get_tree().create_timer(1.0).timeout.connect(new_vfx.queue_free)

func process_item(item: Item):
	play_hit_effect(item.type)
	
	var id = item.item_id

	# Specific items for Alpha/Beta bars
	if id == "fruit_1": # This is "alphaFood"
		GameManager.add_score_alpha(item.score)
		SignalBus.request_sfx.emit("pop")
		sfx_pick(1)
	elif id == "fruit_2": # This is "betaFood"
		GameManager.add_score_beta(item.score)
		SignalBus.request_sfx.emit("pop")
		sfx_pick(1)
	elif id in ["trap_1", "trap_2", "trap_3"]:
		GameManager.add_score_alpha(item.score) # These are candies 1-3
		SignalBus.request_sfx.emit("explosion")
		sfx_pick(0)
	elif id in ["trap_4", "trap_5"]:
		GameManager.add_score_beta(item.score) # These are candies 4-5
		SignalBus.request_sfx.emit("explosion")
		sfx_pick(0)
	# Bonus Item
	elif item.type == Utils.ItemType.BONUS:
		GameManager.activate_bonus_mode(11.0)
		GameManager.add_score(item.score)
		SignalBus.request_sfx.emit("pop") # Or use a special sound
		sfx_pick(1)
	# Fallback to general score for any other items
	else:
		GameManager.add_score(item.score)
		if item.type == Utils.ItemType.FRUIT:
			SignalBus.request_sfx.emit("pop")
			sfx_pick(1)
		else:
			SignalBus.request_sfx.emit("explosion")
			sfx_pick(0)

	item.deactivate()

func play_hit_effect(type: Utils.ItemType):
	var tween = create_tween().set_parallel(true)

	# Stretch / Squash
	sprite.scale = Vector2(0.9, 0.7)
	sprite.texture = setTexture[3] if type == Utils.ItemType.FRUIT else setTexture[0]
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Color Flash
	var flash_color = Color(0.5, 1.5, 0.5) if type == Utils.ItemType.FRUIT else Color(1.5, 0.5, 0.5)
	sprite.modulate = flash_color
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.3)

func sfx_pick(index: int) -> void:
	match index:
		0:
			audio_stream_player.stream = SFX_ERROR
		1:
			audio_stream_player.stream = SFX_COIN
	
	# สั่งเล่นหลังจากเลือก Stream แล้ว
	audio_stream_player.play()
