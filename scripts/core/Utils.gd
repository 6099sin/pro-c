class_name Utils

# Global Constants (fallback if not using ProjectSettings)
const SCREEN_WIDTH = 648
const SCREEN_HEIGHT = 1152
const GRAVITY = 980.0

# Enums
enum ItemType {FRUIT, TRAP}
enum Grade {S, A, B, C, F}

static func format_time(seconds: float) -> String:
	var m = int(seconds) / 60
	var s = int(seconds) % 60
	return "%02d:%02d" % [m, s]

static func get_screen_size(node: Node = null) -> Vector2:
	if node and node.is_inside_tree():
		return node.get_viewport_rect().size
	return Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
