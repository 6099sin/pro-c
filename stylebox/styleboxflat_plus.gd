@tool
extends StyleBoxFlat

class_name StyleBoxFlatPlus

@export_group("NEGATIVE expend Margin","margin_")

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_bottom: int :
	set(value):
		margin_bottom = value
		expand_margin_bottom = value

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_left: int :
	set(value):
		margin_left = value
		expand_margin_left = value

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_top: int :
	set(value):
		margin_top = value
		expand_margin_top = value

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var margin_right: int :
	set(value):
		margin_right = value
		expand_margin_right = value
