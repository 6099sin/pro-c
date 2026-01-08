extends Node

# Autoload: GameManager

var score: int = 0
var score_alpha: int=4
var score_beta: int=1
var combo_multiplier: float = 1.0
var time_left: float = 60.0
var is_game_active: bool = false
var user_name: String = ""
var user_tel: String = ""
const MAX_SCORE_ALPHA_BETA = 500
const MAX_COMBO = 3.0
const COMBO_STEP = 0.1

func _ready():
	# For testing, we might want to start manually or have a main menu
	pass

func start_game():
	score = 0
	combo_multiplier = 1.0
	time_left = 60.0
	is_game_active = true
	SignalBus.score_updated_alpha.emit(score)
	SignalBus.score_updated_beta.emit(score)
	SignalBus.time_updated.emit(time_left)

func _process(delta):
	if not is_game_active: return

	time_left -= delta
	if time_left <= 0:
		end_game()

	SignalBus.time_updated.emit(time_left)

func add_score(amount: int):
	if amount < 0:
		reset_combo()
		score += amount
	else:
		# Apply combo multiplier
		var final_points = int(amount * combo_multiplier)
		score += final_points

		# Increase combo
		combo_multiplier = min(combo_multiplier + COMBO_STEP, MAX_COMBO)

	SignalBus.score_updated_alpha.emit(score)
	SignalBus.score_updated_beta.emit(score)

func reset_combo():
	combo_multiplier = 1.0
	# Optional: feedback for combo break

func end_game():
	is_game_active = false
	time_left = 0
	SignalBus.time_updated.emit(0)

	var grade = calculate_grade(score)
	SignalBus.game_over.emit(score, grade)

func calculate_grade(final_score: int) -> String:
	if final_score >= 1000: return "S"
	elif final_score >= 800: return "A"
	elif final_score >= 500: return "B"
	elif final_score >= 200: return "C"
	else: return "F"
