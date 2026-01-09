extends Control

@onready var score_label_alpha: Label = $TopBar/ScoreLabel
@onready var score_label_2: Label = $TopBar/ScoreLabel2
@onready var timer_label = $TopBar/TimerLabel
@onready var combo_bar = $TopBar/ComboContainer/ComboBar
@onready var combo_label = $TopBar/ComboContainer/ComboMultiplierLabel
@onready var game_over_panel = $TopBar/GradeLabel
@onready var progressAlpha_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer3/ProgressBar
@onready var progressBeta_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer2/ProgressBar
@onready var bonus_time_indicator = $BonusTime
var HUD_FILL_BAR = preload("uid://b4ll0t0y4e38t")


func _ready():
	# Connect to main score and timer updates
	SignalBus.score_updated_total.connect(update_main_score_ui_Alpha) # Main numeric score
	SignalBus.time_updated.connect(update_timer_ui)
	SignalBus.game_over.connect(update_game_over_ui)

	# Connect to alpha and beta score updates
	SignalBus.score_updated_alpha.connect(update_alpha_bar_ui)
	SignalBus.score_updated_beta.connect(update_beta_bar_ui)
	SignalBus.bonus_event.connect(_on_bonus_event)

	# Initial UI state (assuming GameManager is already initialized)
	update_main_score_ui_Alpha(GameManager.score) # Initialize with current GameManager score
	update_timer_ui(GameManager.time_left) # Initialize with current GameManager time
	game_over_panel.visible = false

	# Initialize progress bars for alpha and beta scores
	progressAlpha_bar.max_value = GameManager.MAX_SCORE_ALPHA_BETA / 2
	progressBeta_bar.max_value = GameManager.MAX_SCORE_ALPHA_BETA / 2
	update_alpha_bar_ui(GameManager.score_alpha) # Initialize with current GameManager score_alpha
	update_alpha_bar_ui(GameManager.score_alpha) # Initialize with current GameManager score_alpha
	update_beta_bar_ui(GameManager.score_beta) # Initialize with current GameManager score_beta
	if bonus_time_indicator:
		bonus_time_indicator.visible = false


func update_main_score_ui_Alpha(new_score: int): # Renamed from update_score_ui_alpha
	score_label_alpha.text = "Score: %d" % new_score
	# Juice: Scale punch
	if is_inside_tree():
		var tween = create_tween()
		score_label_alpha.scale = Vector2(1.5, 1.5)
		tween.tween_property(score_label_alpha, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

func update_alpha_bar_ui(new_alpha_score: int):
	progressAlpha_bar.value = new_alpha_score
	# Optional: add juice here for alpha bar update

func update_beta_bar_ui(new_beta_score: int): # New function
	progressBeta_bar.value = new_beta_score
	# Optional: add juice here for beta bar update

func update_timer_ui(time_left: float):
	timer_label.text = Utils.format_time(time_left)
	$MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.value = time_left
	if time_left < 10:
		$MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar.scale = Vector2(1.2, 1)
		var tween = create_tween()
		tween.tween_property($MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
		var stylebox = HUD_FILL_BAR.duplicate()
		stylebox.bg_color = Color(1, 0, 0, 0.4)
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

		combo_label.text = "x%.1f" % GameManager.combo_multiplier

func _on_bonus_event(is_active: bool):
	if is_active:
		if bonus_time_indicator:
			bonus_time_indicator.visible = true
		
		# Pause for intro
		get_tree().paused = true
		await get_tree().create_timer(3.0).timeout
		get_tree().paused = false
		
		# Hide indicator after intro
		if bonus_time_indicator:
			bonus_time_indicator.visible = false
