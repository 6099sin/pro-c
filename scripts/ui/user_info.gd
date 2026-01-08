extends Control

@onready var input_tel: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer3/LineEditTel
@onready var input_name: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/LineEditName
@onready var check_box: CheckBox = $PanelContainer/MarginContainer/VBoxContainer/CenterContainer/HBoxContainer/CheckBox

# Variable to store the last valid phone number
var old_tel_text = ""
# Create a Regular Expression tool
var regex = RegEx.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# --- 1. Setup Regex to accept ONLY numbers ---
	regex.compile("^[0-9]*$") 

# --- 2. Connect the Text Changed signal for the phone number ---
	input_tel.text_changed.connect(_on_input_tel_changed)

	$PanelContainer/MarginContainer/VBoxContainer/MarginContainer/Button.pressed.connect(_on_press_comfirm)
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
func _on_press_comfirm()->void :
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
	
	get_tree().change_scene_to_file("res://scenes/core/Main.tscn")

func flash_error(control: Control):
	var tween = get_tree().create_tween()
	# Flash the control red twice to indicate an error
	tween.set_loops(2)
	tween.tween_property(control, "modulate", Color.RED, 0.15)
	tween.tween_property(control, "modulate", Color.WHITE, 0.15)
