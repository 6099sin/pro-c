extends Control

@onready var input_tel: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer3/LineEditTel
@onready var input_name: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/LineEditName
@onready var check_box: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/CheckBox
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var button1: Button = $PlayAnimationScene/MarginContainer1/Next1/Button
@onready var button2: Button = $PlayAnimationScene/MarginContainer2/Next1/Button
@onready var button3: Button = $PlayAnimationScene/MarginContainer3/Next1/Button
@onready var button4: Button = $PlayAnimationScene/MarginContainer4/Next1/Button

# Variable to store the last valid phone number
var old_tel_text = ""
# Create a Regular Expression tool
var regex = RegEx.new()

var flipflop: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# --- 1. Setup Regex to accept ONLY numbers ---
	regex.compile("^[0-9]*$")
	# flip sound

	# Hide caret if using virtual keyboard
	if DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		input_tel.add_theme_color_override("caret_color", Color(0, 0, 0, 0))
		input_name.add_theme_color_override("caret_color", Color(0, 0, 0, 0))

# --- 2. Connect the Text Changed signal for the phone number ---
	input_tel.text_changed.connect(_on_input_tel_changed)

	$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/ComfirmButton.pressed.connect(_on_press_comfirm)
	
	# Hide the animation layer initially
	if has_node("PlayAnimationScene"):
		$PlayAnimationScene.visible = false
		# Ensure all sub-containers are hidden initially
		if has_node("PlayAnimationScene/MarginContainer1"): $PlayAnimationScene/MarginContainer1.visible = false
		if has_node("PlayAnimationScene/MarginContainer2"): $PlayAnimationScene/MarginContainer2.visible = false
		if has_node("PlayAnimationScene/MarginContainer3"): $PlayAnimationScene/MarginContainer3.visible = false
		if has_node("PlayAnimationScene/MarginContainer4"): $PlayAnimationScene/MarginContainer4.visible = false
		
	audio_stream_player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_tel_changed(new_text: String):
	# Check if the new text matches the RegEx (Numbers only) and has a valid length
	if regex.search(new_text) and new_text.length() <= 10:
		old_tel_text = new_text # If valid, save this as the new "old" text
	else:
		# If invalid (contains letters/symbols or too long), revert to the last valid text
		input_tel.text = old_tel_text
		# Move the typing cursor to the end of the line so it doesn't jump to the left
		input_tel.set_caret_column(input_tel.text.length())

# --- Button Logic ---
func _on_press_comfirm() -> void:
	var is_valid = true
	
	if input_name.text.is_empty():
		flash_error(input_name)
		is_valid = false

	if input_tel.text.length() != 10:
		flash_error(input_tel)
		is_valid = false

	if not check_box.button_pressed:
		flash_error(check_box)
		is_valid = false

	if not is_valid:
		return

	# Assuming GameManager is an autoload singleton to store user data
	if GameManager:
		GameManager.user_name = input_name.text
		GameManager.user_tel = input_tel.text

	# Start Dialog Sequence
	start_dialog_sequence()
	$MarginContainer/TextureRect.visible = true
func start_dialog_sequence() -> void:
	$PanelContainer.visible = false
	if has_node("PlayAnimationScene"):
		$PlayAnimationScene.visible = true
		
		# Step 1
		await play_dialog_step($PlayAnimationScene/MarginContainer1, "res://assets/Sound/info/1_info.ogg", button1)
		# Step 2
		await play_dialog_step($PlayAnimationScene/MarginContainer2, "res://assets/Sound/info/2_info.ogg", button2)
		# Step 3
		await play_dialog_step($PlayAnimationScene/MarginContainer3, "res://assets/Sound/info/3_info.ogg", button3)
		# Step 4
		await play_dialog_step($PlayAnimationScene/MarginContainer4, "res://assets/Sound/info/4_info.ogg", button4)
		
		# Finish
		get_tree().change_scene_to_file("res://scenes/core/Main.tscn")

func play_dialog_step(container: Control, sound_path: String, next_btn: Button) -> void:
	# Initialize state
	container.modulate.a = 0.0
	container.visible = true
	if next_btn:
		next_btn.visible = false
		
	# Fade In Container
	var tween_in = create_tween()
	tween_in.tween_property(container, "modulate:a", 1.0, 0.5)
	await tween_in.finished
	
	# Play Sound
	var stream = load(sound_path)
	if stream:
		audio_stream_player.stream = stream
		audio_stream_player.play()
		await audio_stream_player.finished
	else:
		# Fallback if sound missing
		await get_tree().create_timer(1.0).timeout
		
	# Show Next Button
	if next_btn:
		next_btn.visible = true
		next_btn.disabled = false
		
		# Wait for button press
		await next_btn.pressed
		
	# Fade Out Container
	var tween_out = create_tween()
	tween_out.tween_property(container, "modulate:a", 0.0, 0.5)
	await tween_out.finished
	container.visible = false

func flash_error(control: Control):
	var tween = get_tree().create_tween()
	# Flash the control red twice to indicate an error
	tween.set_loops(2)
	tween.tween_property(control, "modulate", Color.RED, 0.15)
	tween.tween_property(control, "modulate", Color.WHITE, 0.15)



func _mute_button_pressed() -> void:
	if flipflop:
		audio_stream_player.stop()
		flipflop = false
	else:
		audio_stream_player.play()
		flipflop = true
