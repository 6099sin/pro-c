extends Control

@onready var score_label_alpha: Label = $TopBar/ScoreLabel
@onready var score_label_2: Label = $TopBar/ScoreLabel2
@onready var timer_label = $TopBar/TimerLabel
@onready var combo_bar = $TopBar/ComboContainer/ComboBar
@onready var combo_label = $TopBar/ComboContainer/ComboMultiplierLabel
@onready var game_over_panel = $TopBar/GradeLabel
@onready var progressAlpha_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer3/ProgressBar
@onready var progressBeta_bar: ProgressBar = $MarginContainer/VBoxContainer/PanelContainer2/ProgressBar
@onready var timer_bar: ProgressBar = $MarginContainer2/HBoxContainer/PanelContainer3/ProgressBar
@onready var bonus_time_indicator: Panel = $BonusTime
@onready var bonus_time_indicatorEnd: Panel = $BonusTimeEnd
@onready var before_start = $before_start
var HUD_FILL_BAR = preload("uid://b4ll0t0y4e38t")
@onready var bonus_timer_text: Label = $MarginContainer3/BonusTimer
@onready var timer: Timer = bonus_timer_text.get_child(0)

@onready var add_point_alpha: Label = $MarginContainer/VBoxContainer/PanelContainer3/MarginContainer2/addPointAlpha
@onready var add_point_beta: Label = $MarginContainer/VBoxContainer/PanelContainer2/MarginContainer2/addPointBeta

var alpha_tween: Tween
var beta_tween: Tween
var time_tween: Tween

var current_alpha_score: int = 0
var current_beta_score: int = 0


@onready var hud_bottom = $MarginContainer
@onready var hud_left = $MarginContainer2

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
	
	# Initialize popup labels to invisible
	if add_point_alpha:
		add_point_alpha.modulate.a = 0.0
	if add_point_beta:
		add_point_beta.modulate.a = 0.0

	# Initialize progress bars for alpha and beta scores
	progressAlpha_bar.max_value = GameManager.MAX_SCORE_ALPHA_BETA / 2
	progressBeta_bar.max_value = GameManager.MAX_SCORE_ALPHA_BETA / 2
	
	# Initialize local score tracking without triggering animation
	current_alpha_score = GameManager.score_alpha
	current_beta_score = GameManager.score_beta
	
	update_alpha_bar_ui(GameManager.score_alpha, false)
	update_beta_bar_ui(GameManager.score_beta, false)

	if bonus_time_indicator:
		bonus_time_indicator.visible = false

	# Hide HUD initially
	if hud_bottom: hud_bottom.modulate.a = 0.0
	if hud_left: hud_left.modulate.a = 0.0

	# Show before_start warning
	if before_start:
		before_start.visible = true
		before_start.modulate.a = 1.0
		get_tree().paused = true

		# Wait 1.5 seconds
		await get_tree().create_timer(1.5, true, false, true).timeout

		# Sweep Fade Out (Warning) & Fade In (HUD)
		var tween = create_tween().set_parallel(true)
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(before_start, "modulate:a", 0.0, 0.5)
		if hud_bottom: tween.tween_property(hud_bottom, "modulate:a", 1.0, 0.5)
		if hud_left: tween.tween_property(hud_left, "modulate:a", 1.0, 0.5)
		
		await tween.finished

		before_start.visible = false
		get_tree().paused = false

	# 1. เชื่อมต่อ Signal เมื่อเวลาหมด (หากต้องการทำเหตุการณ์บางอย่าง)
	timer.timeout.connect(_on_timer_timeout)
	timer.stop()

func update_main_score_ui_Alpha(new_score: int): # Renamed from update_score_ui_alpha
	score_label_alpha.text = "Score: %d" % new_score
	# Juice: Scale punch
	if is_inside_tree():
		var tween = create_tween()
		score_label_alpha.scale = Vector2(1.5, 1.5)
		tween.tween_property(score_label_alpha, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)

func update_alpha_bar_ui(new_alpha_score: int, animate_popup: bool = true):
	if animate_popup:
		var delta = new_alpha_score - current_alpha_score
		if delta != 0:
			show_score_popup(add_point_alpha, delta)
	
	current_alpha_score = new_alpha_score
	
	if alpha_tween and alpha_tween.is_valid():
		alpha_tween.kill()
	alpha_tween = create_tween()
	alpha_tween.tween_property(progressAlpha_bar, "value", new_alpha_score, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Optional: add juice here for alpha bar update

func update_beta_bar_ui(new_beta_score: int, animate_popup: bool = true): # New function
	if animate_popup:
		var delta = new_beta_score - current_beta_score
		if delta != 0:
			show_score_popup(add_point_beta, delta)
			
	current_beta_score = new_beta_score
	
	if beta_tween and beta_tween.is_valid():
		beta_tween.kill()
	beta_tween = create_tween()
	beta_tween.tween_property(progressBeta_bar, "value", new_beta_score, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	# Optional: add juice here for beta bar update

func show_score_popup(label: Label, delta: int):
	if label == null: return
	
	if delta > 0:
		label.text = "+%d" % delta
		# Optional: Set color for positive? Using existing color for now.
	else:
		label.text = "%d" % delta
		# Optional: Set color for negative?
		
	# Reset alpha to 0 just in case
	label.modulate.a = 0.0
	label.visible = true
	
	var tween = create_tween()
	# Fade In
	tween.tween_property(label, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# Wait
	tween.tween_interval(0.5)
	# Fade Out
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func update_timer_ui(time_left: float):
	timer_label.text = Utils.format_time(time_left)

	# Only use tween if the difference is significant (e.g. bonus/penalty), otherwise direct set is smoother for frame-by-frame
	if abs(timer_bar.value - time_left) > 1.0:
		# If we are already animating a large jump, let it finish to avoid stuttering
		if time_tween and time_tween.is_valid() and time_tween.is_running():
			pass
		else:
			time_tween = create_tween()
			time_tween.tween_property(timer_bar, "value", time_left, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	else:
		# If the difference is small, only snap if we are NOT currently in the middle of a big tween
		if time_tween and time_tween.is_valid() and time_tween.is_running():
			pass
		else:
			timer_bar.value = time_left

	if time_left < 10:
		timer_bar.scale = Vector2(1.2, 1)
		var tween = create_tween()
		tween.tween_property(timer_bar, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BOUNCE)
		var stylebox = HUD_FILL_BAR.duplicate()
		stylebox.bg_color = Color(1, 0, 0, 0.4)
		if stylebox is StyleBoxFlat:
			timer_bar.add_theme_stylebox_override("fill", stylebox)
			var get_UI_StyleBox = timer_bar.get_theme_stylebox("fill").duplicate()
			# 2. Create the Tween
			var tween2 = create_tween()
			# 3. Target the 'stylebox' reference directly to animate its 'bg_color'
			var target_color = Color(1.0, 0.0, 0.0, 1.0)
			tween2.tween_property(get_UI_StyleBox, "bg_color", target_color, 0.5).set_trans(Tween.TRANS_SINE)

		timer_label.modulate = Color(1, 0, 0)
	else:
		timer_label.modulate = Color(1, 1, 1)

@onready var confetti = $Confitte
@onready var win_sound = $WinSound

func update_game_over_ui(final_score: int, grade: String):
	game_over_panel.text = "Grade: %s" % grade
	game_over_panel.visible = true
	
	if confetti:
		confetti.visible = true
		confetti.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(7.0)
		tween.tween_property(confetti, "modulate:a", 0.0, 1.0)
		tween.tween_callback(func(): confetti.visible = false)
		
	if win_sound:
		win_sound.play()

func _process(_delta):
	# Update combo UI continuously if needed or via signal
	if GameManager.is_game_active:
		combo_bar.value = (GameManager.combo_multiplier - 1.0) / (GameManager.MAX_COMBO - 1.0) * 100
		combo_label.text = "x%.1f" % GameManager.combo_multiplier

		combo_label.text = "x%.1f" % GameManager.combo_multiplier
	if !timer.is_stopped():
		var time_remaining = snapped(timer.time_left, 0)
		bonus_timer_text.text = str(time_remaining) + "s"
func _on_bonus_event(is_active: bool):
	if is_active:
		if bonus_time_indicator:
			bonus_time_indicator.visible = true

		# Pause for intro
		get_tree().paused = true
		await get_tree().create_timer(3.0).timeout
		get_tree().paused = false
		bonus_timer_text.visible = true
		timer.start()
		# Hide indicator after intro
		if bonus_time_indicator:
			bonus_time_indicator.visible = false

func _on_timer_timeout() -> void:
	print("หมดเวลาแล้ว!")
	bonus_timer_text.visible = false
	if bonus_time_indicatorEnd:
		bonus_time_indicatorEnd.visible = true
	get_tree().paused = true
	await get_tree().create_timer(3.0).timeout
	get_tree().paused = false
	if bonus_time_indicatorEnd:
		bonus_time_indicatorEnd.visible = false
