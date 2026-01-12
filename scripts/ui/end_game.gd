extends Control

@onready var label_alpha: Label = $CenterContainer/VBoxContainer/LabelAlpha
@onready var label_beta: Label = $CenterContainer/VBoxContainer/LabelBeta
@onready var label_sum: Label = $CenterContainer/VBoxContainer/LabelSum


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_alpha.text = "Alpha Score: %d" % GameManager.score_alpha
	label_beta.text = "Beta Score: %d" % GameManager.score_beta
	label_sum.text = "Total Score: %d" % GameManager.score
