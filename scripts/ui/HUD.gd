extends Control

@onready var score_label = $TopBar/ScoreLabel
@onready var timer_label = $TopBar/TimerLabel
@onready var combo_bar = $TopBar/ComboContainer/ComboBar
@onready var combo_label = $TopBar/ComboContainer/ComboMultiplierLabel
@onready var game_over_panel = $TopBar/GradeLabel

func _ready():
	SignalBus.score_updated.connect(update_score_ui)
	SignalBus.time_updated.connect(update_timer_ui)
	SignalBus.game_over.connect(update_game_over_ui)
	# Initial UI state
	update_score_ui(0)
	update_timer_ui(60.0)
	game_over_panel.visible = false

func update_score_ui(new_score: int):
	score_label.text = "Score: %d" % new_score
	
	# Juice: Scale punch
	if is_inside_tree():
		var tween = create_tween()
		score_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(score_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

func update_timer_ui(time_left: float):
	timer_label.text = Utils.format_time(time_left)
	if time_left < 10:
		timer_label.modulate = Color(1, 0, 0)
	else:
		timer_label.modulate = Color(1, 1, 1)

func update_game_over_ui(final_score: int, grade: String):
	game_over_panel.text = "Grade: %s" % grade
	game_over_panel.visible = true
func _process(_delta):
	# Update combo UI continuously if needed or via signal
	if GameManager.is_game_active:
		combo_bar.value = (GameManager.combo_multiplier - 1.0) / (GameManager.MAX_COMBO - 1.0) * 100
		combo_label.text = "x%.1f" % GameManager.combo_multiplier
