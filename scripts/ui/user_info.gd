extends Control

@onready var input_tel: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/LineEditTel
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_input_tel_changed(new_text: String):
	# Check if the new text matches the RegEx (Numbers only)
	if regex.search(new_text):
		old_tel_text = new_text # If valid, save this as the new "old" text
	else:
		# If invalid (contains letters/symbols), revert to the last valid text
		input_tel.text = old_tel_text
		# Move the typing cursor to the end of the line so it doesn't jump to the left
		input_tel.set_caret_column(input_tel.text.length())

# --- Button Logic ---
