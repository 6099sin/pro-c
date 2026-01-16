Here is the **Instruction** for adding a "Time's Up" notification with a 3-second delay before transitioning to the final score summary.

The logic involves inserting a "Time Up" state between the moment the timer hits zero and the final Game Over sequence.

---

### **Instruction: Add "Time's Up" Notification and 3-Second Delay**

#### **Step 1: Add a new signal in `SignalBus.gd**`

Create a new signal to notify the system that the time has expired, but the final game-over processing hasn't started yet.

* **File:** `scripts/autoloads/SignalBus.gd`
* **Modification:** Add the `time_up` signal.

```gdscript
extends Node

# ... existing signals ...
signal request_sfx(sfx_name: String)
signal bonus_event(is_active: bool)

# [NEW] Notification signal when the timer reaches 0
signal time_up() 

```

---

#### **Step 2: Update Game End Logic in `GameManager.gd**`

Modify the `end_game` function to emit the `time_up` signal first, wait for 3 seconds, and then proceed to the standard `game_over` sequence.

* **File:** `scripts/autoloads/GameManager.gd`
* **Modification:** Update the `end_game()` function.

```gdscript
func end_game():
    if not is_game_active: return # Prevent duplicate calls
    
    is_game_active = false
    time_left = 0
    SignalBus.time_updated.emit(0)

    # [NEW] Trigger Time Up notification and wait for 3 seconds
    print("TIME UP!")
    SignalBus.time_up.emit() 
    await get_tree().create_timer(3.0).timeout

    # After the 3-second delay, calculate grade and trigger Game Over
    var grade = calculate_grade(score)
    SignalBus.game_over.emit(score, grade)

```

---

#### **Step 3: Implement UI Notification in `HUD**`

Add a "TIME'S UP!" label to the UI that appears when the signal is received.

* **File:** `scenes/ui/HUD.tscn` (In the Godot Editor)
1. Create a new `Label` or `Panel` in the center of the screen.
2. Name it `TimeUpLabel`.
3. Set the text to "TIME'S UP!" and increase the font size.
4. Set `Visible` to `Hidden` by default.


* **File:** `scripts/ui/HUD.gd`
1. Reference the new label and connect the signal in `_ready()`.



```gdscript
# ... existing variables ...
@onready var time_up_label = $TimeUpLabel # [NEW] Reference to the new UI element

func _ready():
    # ... existing connections ...
    SignalBus.game_over.connect(update_game_over_ui)
    
    # [NEW] Connect to the time_up signal
    SignalBus.time_up.connect(_on_time_up)
    
    if time_up_label:
        time_up_label.visible = false

# [NEW FUNCTION] Show the Time's Up message
func _on_time_up():
    if time_up_label:
        time_up_label.visible = true
        # Optional: Add "Juice" with a scale-up animation
        time_up_label.scale = Vector2(0, 0)
        var tween = create_tween()
        tween.tween_property(time_up_label, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

```

---

#### **New Logic Flow Summary**

1. **Timer = 0**: `GameManager` stops the game loop and emits `SignalBus.time_up`.
2. **UI Response**: `HUD` receives the signal and displays the **"TIME'S UP!"** message.
3. **Delay**: The system waits for 3 seconds while the message remains on screen.
4. **Game Over**: `GameManager` calculates the final grade and emits `SignalBus.game_over`, which triggers the final summary and scene change.