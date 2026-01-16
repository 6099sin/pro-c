extends Node

func _ready():
	# Auto-start game for testing
	GameManager.start_game()
	GameManager.play_music()
	SignalBus.game_over.connect(_on_game_over)

func _on_game_over(_score: int, _grade: String):
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/EndGame.tscn")
