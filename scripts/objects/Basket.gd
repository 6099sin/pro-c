extends Node2D

@onready var snap_zone: Area2D = $SnapZone
@onready var center_point: Marker2D = $CenterPoint

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const SFX_COIN = preload("res://assets/Sound/Retro Coin 2.mp3")
const SFX_ERROR = preload("res://assets/Sound/1_Error_C.wav")

@onready var animated_sprite: AnimatedSprite2D
@onready var visual_container: Node2D = $Node2D
@onready var aura_face: Sprite2D = $Node2D/aura_face
@onready var aura_body: Sprite2D = $Node2D/aura_body
@export_range(0.0, 1.0) var vertical_ratio: float = 0.75   # 0.75 คืออยู่ค่อนไปทางล่าง (75% ของจอ)

const AURA_BODY_1 = preload("res://assets/UI/Baby/aura_body_1.png")
const AURA_BODY_2 = preload("res://assets/UI/Baby/aura_body_2.png")

var current_state_index: int = 0

func _ready():
	snap_zone.body_entered.connect(_on_body_entered)
	center_on_camera()

	# Setup AnimatedSprite
	setup_animations()

	# Connect to score updates to change appearance
	SignalBus.score_updated_alpha.connect(_on_score_updated)
	SignalBus.score_updated_beta.connect(_on_score_updated)

	# Initialize appearance
	update_appearance()

func setup_animations():
	# Hide/Remove old sprite if it exists (it's in the scene file)
	if visual_container.has_node("Sprite2D"):
		visual_container.get_node("Sprite2D").visible = false
		visual_container.get_node("Sprite2D").queue_free()

	# Create AnimatedSprite2D
	animated_sprite = AnimatedSprite2D.new()
	visual_container.add_child(animated_sprite)

	var sprite_frames = SpriteFrames.new()

	# Load frames for Levels 1 to 5 (mapped to indices 0 to 4)
	# File pattern: res://assets/Sprites/PRO_C_animtionSprite/LV.{i}/PRO_C_LV.{i}0{j}.png
	# Level i goes from 1 to 5.
	for i in range(1, 6): # 1, 2, 3, 4, 5
		var anim_name = "state_" + str(i - 1) # state_0 to state_4
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_loop(anim_name, true)
		sprite_frames.set_animation_speed(anim_name, 10.0) # Adjust FPS as needed

		for j in range(10): # 0 to 9
			var frame_index_str = "0" + str(j)
			var path = "res://assets/Sprites/PRO_C_animtionSprite/LV.%d/PRO_C_LV.%d%s.png" % [i, i, frame_index_str]
			var texture = load(path)
			if texture:
				sprite_frames.add_frame(anim_name, texture)
			else:
				push_warning("Failed to load frame: " + path)

	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.play("state_0")

func _on_score_updated(_new_score: int):
	# Removed check for is_hit_animating to allow state update even during animation (or we can keep it, but state index is needed for aura)
	# But we'll keep the visual update check logic inside update_appearance or similar if needed.
	# For now, let's allow it to update internal state always, but animation might wait.
	# Actually, original code blocked it. Let's unblock it but manage animation carefully.
	if not is_hit_animating:
		update_appearance()
	else:
		# Just update the index silently if needed, but easier to just let update_appearance handle it
		# We'll stick to original logic: wait for hit anim to finish before changing base state visual
		# duplicate logic to update index? No, let's just calc index on the fly or force update.
		# Let's calculate index separately if we really need it up to date for aura.
		_calculate_state_index()

func _calculate_state_index():
	var max_score = max(GameManager.score_alpha, GameManager.score_beta)
	if max_score < 100:
		current_state_index = 0
	elif max_score < 200:
		current_state_index = 1
	elif max_score < 300:
		current_state_index = 2
	elif max_score < 400:
		current_state_index = 3
	else:
		current_state_index = 4

func update_appearance():
	_calculate_state_index()

	# Play the corresponding animation
	if animated_sprite and animated_sprite.sprite_frames.has_animation("state_" + str(current_state_index)):
		animated_sprite.play("state_" + str(current_state_index))

var is_hit_animating: bool = false

func center_on_camera():
	var screen_size = Utils.get_screen_size(self)
	position.x = screen_size.x / 2.0
	position.y = screen_size.y * vertical_ratio
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
	play_aura_effect(item)

	var id = item.item_id

	# Specific items for Alpha/Beta bars
	if id == "fruit_1": # This is "alphaFood"
		GameManager.add_score_alpha(item.score)
		sfx_pick(1)
	elif id == "fruit_2": # This is "betaFood"
		GameManager.add_score_beta(item.score)
		sfx_pick(1)
	elif id in ["trap_1", "trap_2", "trap_3"]:
		GameManager.add_score_alpha(item.score) # These are candies 1-3
		sfx_pick(0)
	elif id in ["trap_4", "trap_5"]:
		GameManager.add_score_beta(item.score) # These are candies 4-5
		sfx_pick(0)
	# Bonus Item
	elif item.type == Utils.ItemType.BONUS:
		GameManager.activate_bonus_mode(11.0)
		GameManager.add_score(item.score)
		sfx_pick(1)
	# Fallback to general score for any other items
	else:
		GameManager.add_score(item.score)
		if item.type == Utils.ItemType.FRUIT:
			sfx_pick(1)
		else:
			sfx_pick(0)

	item.deactivate()

func play_aura_effect(item: Item):
	_calculate_state_index()

	var id = item.item_id

	# ตรวจสอบเงื่อนไขก่อน แล้วค่อยสร้าง Tween เมื่อจำเป็นเท่านั้น
	if id == "fruit_1" : # Alpha items
		var tween = create_tween() # <--- ย้ายเข้ามาสร้างข้างในนี้
		aura_face.self_modulate.a = 0
		tween.tween_property(aura_face, "self_modulate:a", 1.0, 0.2)
		tween.tween_property(aura_face, "self_modulate:a", 0.0, 0.2)

	elif id == "fruit_2" : # Beta items
		var tween = create_tween() # <--- ย้ายเข้ามาสร้างข้างในนี้

		# Texture switching
		if current_state_index >= 3:
			aura_body.texture = AURA_BODY_2
		else:
			aura_body.texture = AURA_BODY_1

		aura_body.self_modulate.a = 0
		tween.tween_property(aura_body, "self_modulate:a", 1.0, 0.2)
		tween.tween_property(aura_body, "self_modulate:a", 0.0, 0.2)

	# ถ้าเป็นไอเทม BONUS หรือไอเทมอื่นๆ โค้ดจะข้ามมาถึงตรงนี้โดยไม่มีการสร้าง Tween ทำให้ไม่เกิด Error ครับ

func play_hit_effect(type: Utils.ItemType):
	is_hit_animating = true
	var tween = create_tween().set_parallel(true)

	# Stretch / Squash
	animated_sprite.scale = Vector2(0.9, 0.7)

	# Temporary Animation Switch for Hit
	# Happy (Fruit) -> State 3 (Old B3) -> state_3
	# Sad (Trap) -> State 0 (Old B0) -> state_0
	if type == Utils.ItemType.FRUIT:
		# animated_sprite.play("state_3")
		pass
	else:
		# animated_sprite.play("state_0")
		pass
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Color Flash
	var flash_color = Color(0.965, 0.851, 0.502) if type == Utils.ItemType.FRUIT else Color(1.5, 0.5, 0.5)
	animated_sprite.modulate = flash_color
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.3)

	# Revert to correct state texture after effect
	tween.chain().tween_callback(func():
		is_hit_animating = false
		update_appearance()
	)

func sfx_pick(index: int) -> void:
	match index:
		0:
			audio_stream_player.stream = SFX_ERROR
			SignalBus.request_sfx.emit("explosion")
		1:
			audio_stream_player.stream = SFX_COIN
			SignalBus.request_sfx.emit("pop")

	# สั่งเล่นหลังจากเลือก Stream แล้ว
	audio_stream_player.play()
