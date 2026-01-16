extends Control

func _ready():
	# Wait for 3 seconds then change to Main scene
	await get_tree().create_timer(5.0).timeout
	get_tree().change_scene_to_file("res://scenes/core/Main.tscn")
