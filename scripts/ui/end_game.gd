extends Control

@onready var label_alpha: Label = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer2/PanelContainer3/MarginContainer2/addPointAlpha
@onready var label_beta: Label = $VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MarginContainer3/PanelContainer2/MarginContainer2/addPointBeta
@onready var label_sum: Label = $VBoxContainer/MarginContainer3/HBoxContainer/PanelContainer2/MarginContainer2/allPoint
@onready var back_to_play: Button = $VBoxContainer/MarginContainer4/Next1/BackToPlay

# URL ของ Google Apps Script (อันใหม่ล่าสุดที่ลงท้ายด้วย /exec)
const GOOGLE_SCRIPT_URL = "https://script.google.com/macros/s/AKfycbxMJEdN0VfFA5rKxS-kYqWYu-9EUP19JIPddGj3Q5w5nV8P5jwfUTcG7vhgDJwK_ZjN/exec"

# รหัสผ่านสำหรับสั่งรีเซ็ต (ต้องตรงกับใน Google Script)
const RESET_PASSWORD = "MY_SUPER_SECRET_PASSWORD"
# ตัวที่ 1: สำหรับ "ส่ง" ข้อมูล (Submit / Reset)
@onready var submit_sender: HTTPRequest = $HTTPRequest

# ตัวที่ 2: สำหรับ "รับ" ข้อมูล (Leaderboard)
@onready var leaderboard_receiver: HTTPRequest = $LeaderboardRequest

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# label_alpha.text = "Alpha Score: %d" % GameManager.score_alpha
	# label_beta.text = "Beta Score: %d" % GameManager.score_beta
	# label_sum.text = "Total Score: %d" % GameManager.score
	label_alpha.text = "%d" % GameManager.score_alpha
	label_beta.text = "%d" % GameManager.score_beta
	label_sum.text = "%d" % (GameManager.score_alpha + GameManager.score_beta)
	
	if has_node("Promote"):
		var promote = $Promote
		promote.visible = true
		promote.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(5.0)
		tween.tween_property(promote, "modulate:a", 0.0, 1.0)
		tween.tween_callback(func(): promote.visible = false)
	
	submit_sender.request_completed.connect(_on_submit_completed)
	#print(GameManager.user_tel)
	#submit_score(GameManager.user_name, GameManager.user_tel, GameManager.score)
	#submit_score("cd","1234567890",12,"Level_1")
	submit_score(GameManager.user_name,Utils.format_phone_number(GameManager.user_tel),int(GameManager.score_alpha+GameManager.score_beta),"Level_1")
	back_to_play.pressed.connect(_press_backToPlay)
func submit_score(p_name: String, p_phone: String, p_score: int, sheet_name: String = "Sheet1"):
	# var final_name = p_name if not p_name.is_empty() else GameManager.user_name
	# var final_phone = final_name if not p_phone.is_empty() else GameManager.user_tel
	# Default to p_score, trust the caller. If logic requires fallback to GameManager.score it should be handled by caller or here if -1 passed.
	# Assuming p_score is always valid.
	
	var data = {
		"name": p_name,
		"phone": p_phone,
		"score": p_score,
		"sheet_name": sheet_name,
		"timestamp": Time.get_unix_time_from_system()
	}
	print(data)
	_send_post_request(data)
	
	
func _send_post_request(data_dict: Dictionary):
	var json_body = JSON.stringify(data_dict)
	var headers = ["Content-Type: application/json"] # Changed to application/json for better standard compliance, unless text/plain is strictly required for CORS hack. Keeping text/plain if originally intended?
	# Original comment said: text/plain because of CORS. Google Apps Script usually handles this via Simple Request.
	# Let's stick to text/plain to be safe if that was the intention, or switch to standard.
	# Standard practice for google apps script simple requests often uses text/plain to avoid preflight options.
	headers = ["Content-Type: text/plain"]
	
	var error = submit_sender.request(GOOGLE_SCRIPT_URL, headers, HTTPClient.METHOD_POST, json_body)

	if error != OK:
		print("❌ Error: ไม่สามารถเริ่มส่งข้อมูลได้ (Code: %s)" % error)
	else:
		print("⏳ กำลังส่งข้อมูลไปยัง Server...")

func _on_submit_completed(_result, response_code, _headers, body):
	# ยอมรับ 200 (Success) และ 405 (Google Redirect Error ที่ถือว่าผ่าน)
	if response_code == 200 or response_code == 405:
		var response_text = body.get_string_from_utf8()

		if response_code == 405:
			print("✅ ส่งสำเร็จ! (Google Redirect 405)")
		else:
			print("✅ Server ตอบกลับ: ", response_text)

	elif response_code == 302:
		print("⚠️ เจอ Redirect (302) - ข้อมูลน่าจะเข้าแล้ว")
	else:
		print("❌ ส่งไม่สำเร็จ Error Code: ", response_code)

func _press_backToPlay()->void:
	# ก่อนอื่น ตรวจสอบว่าเกมกำลังรันอยู่บนเว็บเบราว์เซอร์หรือไม่
	if OS.has_feature("web"):
		# เราใช้ JavaScriptBridge เพื่อรันโค้ด JavaScript แบบดิบๆ (Raw JavaScript)
		# window.location.reload() คือคำสั่งรีเฟรช URL ปัจจุบัน
		JavaScriptBridge.eval("window.location.reload();")
	else:
		print("Refresh Browser: ไม่ได้รันบนแพลตฟอร์มเว็บ ข้ามการทำงานนี้")
