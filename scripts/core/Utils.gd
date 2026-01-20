class_name Utils

# Global Constants (fallback if not using ProjectSettings)
const SCREEN_WIDTH = 648
const SCREEN_HEIGHT = 1152
const GRAVITY = 980.0

# Enums
enum ItemType {FRUIT, TRAP,BONUS}
enum Grade {S, A, B, C, F}

const ITEM_DATA = {
	# Fruits
	"fruit_1": {"type": ItemType.FRUIT, "score": 20, "color": Color(1, 0.8, 0.2), "texture_path": "res://assets/UI/Item/Alpha.png"}, # Gold/Orange
	"fruit_2": {"type": ItemType.FRUIT, "score": 20, "color": Color(0.0, 0.843, 0.906, 1.0), "texture_path": "res://assets/UI/Item/Beta.png"}, # Red
	"fruit_3": {"type": ItemType.FRUIT, "score": 10, "color": Color(0.0, 0.843, 0.906, 1.0), "texture_path": "res://assets/UI/Item/2FL.png"}, # Red
	"bonus": {"type": ItemType.BONUS, "score": 5, "color": Color(0.2, 0.8, 0.2), "texture_path": "res://assets/UI/Item/Bonus.png"}, # Green

	# Traps (All -5)
	"trap_1": {"type": ItemType.TRAP, "score": - 5, "color": Color(0.712, 0.446, 0.002, 1.0), "texture_path": "res://assets/UI/Item/Candy1.png"}, # Dark Grey
	"trap_2": {"type": ItemType.TRAP, "score": - 5, "color": Color(0.712, 0.446, 0.002, 1.0), "texture_path": "res://assets/UI/Item/Candy2.png"}, # Dark Purple
	"trap_3": {"type": ItemType.TRAP, "score": - 5, "color": Color(0.712, 0.446, 0.002, 1.0), "texture_path": "res://assets/UI/Item/Candy3.png"}, # Dark Blue
	"trap_4": {"type": ItemType.TRAP, "score": - 5, "color": Color(0.712, 0.446, 0.002, 1.0), "texture_path": "res://assets/UI/Item/Candy4.png"}, # Dark Brown
	"trap_5": {"type": ItemType.TRAP, "score": - 5, "color": Color(0.712, 0.446, 0.002, 1.0), "texture_path": "res://assets/UI/Item/Candy5.png"}, # Dark Cyan
}

static func format_time(seconds: float) -> String:
	var m = int(seconds) / 60
	var s = int(seconds) % 60
	return "%02d:%02d" % [m, s]

static func get_screen_size(node: Node = null) -> Vector2:
	if node and node.is_inside_tree():
		return node.get_viewport_rect().size
	return Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)

static func format_phone_number(digits: String) -> String:
	# Ensure we only have numbers and exactly 10 of them
	var clean_digits = ""
	var regex = RegEx.new()
	regex.compile("\\d+") # Match only digits

	for result in regex.search_all(digits):
		clean_digits += result.get_string()

	if clean_digits.length() != 10:
		push_warning("format_phone_number: Input must be exactly 10 digits.")
		return digits # Return original if invalid

	# Use String.format or sub-string slicing
	# Slicing is highly efficient for fixed-length formatting
	var area_code = clean_digits.substr(0, 3)
	var prefix    = clean_digits.substr(3, 3)
	var line_num  = clean_digits.substr(6, 4)

	return "%s-%s-%s" % [area_code, prefix, line_num]
