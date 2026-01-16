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
