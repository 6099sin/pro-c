extends Control

@onready var label_alpha: Label = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/PanelContainer3/MarginContainer2/addPointAlpha
@onready var label_beta: Label = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer3/PanelContainer2/MarginContainer2/addPointBeta
@onready var label_sum: Label = $VBoxContainer/MarginContainer3/HBoxContainer/PanelContainer2/MarginContainer2/allPoint


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# label_alpha.text = "Alpha Score: %d" % GameManager.score_alpha
	# label_beta.text = "Beta Score: %d" % GameManager.score_beta
	# label_sum.text = "Total Score: %d" % GameManager.score

	label_alpha.text = "%d" % GameManager.score_alpha
	label_beta.text = "%d" % GameManager.score_beta
	label_sum.text = "%d" % GameManager.score
