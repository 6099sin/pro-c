extends Node

# Autoload: GameManager

var score: int = 0
var score_alpha: int = 0
var score_beta: int = 0
var combo_multiplier: float = 1.0
var time_left: float = 60.0
var is_game_active: bool = false
var user_name: String = ""
var user_tel: String = ""
const MAX_SCORE_ALPHA_BETA = 500
const MAX_COMBO = 3.0
const COMBO_STEP = 0.1

func _ready():
	print("Score "+ str(score_alpha)+"  Score "+str(score_beta))

func start_game():
	score = 0
	# score_alpha/beta are not reset to 0 here to keep their initial values if desired,
	# or they should be? Assuming we keep them as is or reset if they are per-game.
	# The user initialized them to 4 and 1, so maybe they persist?
	# Safest is to NOT reset them if not asked, but usually new game = new score.
	# Given the "2 bar score" context, let's assume they are per-game but starting with some offset?
	# Or maybe those are debug values. I'll stick to the current values.
	combo_multiplier = 1.0
	time_left = 60.0
	is_game_active = true
	SignalBus.score_updated_total.emit(score)
	SignalBus.score_updated_alpha.emit(score_alpha)
	SignalBus.score_updated_beta.emit(score_beta)
	SignalBus.time_updated.emit(time_left)

func _process(delta):
	if not is_game_active: return

	time_left -= delta
	if time_left <= 0:
		end_game()

	SignalBus.time_updated.emit(time_left)

# Helper to calculate points and handle combo logic centrally
func _calculate_points_and_combo(amount: int) -> int:
	if amount < 0:
		reset_combo()
		return amount # Penalty is raw
	else:
		# Just track combo, don't multiply score
		combo_multiplier = min(combo_multiplier + COMBO_STEP, MAX_COMBO)
		return amount

func add_score_alpha(amount: int):
	var points = _calculate_points_and_combo(amount)

	score_alpha = min(score_alpha + points, MAX_SCORE_ALPHA_BETA)
	score += points
	print("Score Alpha: %d" % score_alpha)
	SignalBus.score_updated_alpha.emit(score_alpha)
	SignalBus.score_updated_total.emit(score)

func add_score_beta(amount: int):
	var points = _calculate_points_and_combo(amount)

	score_beta = min(score_beta + points, MAX_SCORE_ALPHA_BETA)
	score += points
	print("Score Beta: %d" % score_beta)
	SignalBus.score_updated_beta.emit(score_beta)
	SignalBus.score_updated_total.emit(score)

func add_score(amount: int):
	var points = _calculate_points_and_combo(amount)

	score += points
	SignalBus.score_updated_total.emit(score)

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
