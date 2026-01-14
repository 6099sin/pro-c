# res://stylebox/styleboxCustom.gd
@tool # ใส่เพื่อให้เห็นผลลัพธ์ใน Editor ทันที
extends StyleBox
class_name StyleBoxCustom

@export var bg_color: Color = Color.DARK_SLATE_GRAY
@export var pattern_color: Color = Color(1, 1, 1, 0.2)

# ใน StyleBox เราต้องใช้ RID ในการวาดผ่าน RenderingServer
func _draw(rid: RID, rect: Rect2) -> void:
	# 1. วาดสี่เหลี่ยมพื้นหลัง
	# เราใช้ RenderingServer.canvas_item_add_rect แทน draw_rect
	RenderingServer.canvas_item_add_rect(rid, rect, bg_color)

	# 2. ตัวอย่างการวาดเส้น (Pattern)
	var step: float = 20.0
	for i in range(0, 10):
		var start = Vector2(rect.position.x + (i * step), rect.position.y)
		var end = Vector2(rect.position.x, rect.position.y + (i * step))

		# ใช้ RenderingServer.canvas_item_add_line แทน draw_line
		RenderingServer.canvas_item_add_line(rid, start, end, pattern_color, 2.0)
