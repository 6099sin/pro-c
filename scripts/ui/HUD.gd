extends Control

@onready var score_label = $TopBar/ScoreLabel
@onready var timer_label = $TopBar/TimerLabel
@onready var combo_bar = $TopBar/ComboContainer/ComboBar
@onready var combo_label = $TopBar/ComboContainer/ComboMultiplierLabel
@onready var game_over_panel = $TopBar/GradeLabel
@onready var progressAlpha_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer3/ProgressBar
@onready var progressBeta_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer2/ProgressBar
var HUD_FILL_BAR = preload("uid://b4ll0t0y4e38t")



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
	progressAlpha_bar.value = new_score
	progressBeta_bar.value = new_score
	# Juice: Scale punch
	if is_inside_tree():
		var tween = create_tween()
		score_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(score_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

func update_timer_ui(time_left: float):
	timer_label.text = Utils.format_time(time_left)
	$MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.value = time_left
	if time_left < 10:
		$MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.scale = Vector2(1.2,1)
		var tween = create_tween()
		tween.tween_property($MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
		var stylebox = HUD_FILL_BAR.duplicate()
		stylebox.bg_color= Color(1, 0, 0, 0.4)
		if stylebox is StyleBoxFlat:
			$MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.add_theme_stylebox_override("fill", stylebox)
			var get_UI_StyleBox = $MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.get_theme_stylebox("fill").duplicate()
			# 2. Create the Tween
			var tween2 = create_tween()
			# 3. Target the 'stylebox' reference directly to animate its 'bg_color'
			var target_color = Color(0.969, 0.247, 0.432, 1.0)
			tween2.tween_property(get_UI_StyleBox, "bg_color", target_color, 0.5).set_trans(Tween.TRANS_SINE)
			
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
