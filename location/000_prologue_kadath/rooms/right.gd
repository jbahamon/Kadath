extends LocationRoom

onready var entrance = $Entrance

const SWITCH_FLAG_NAME = "000_right_room_switch"

func _ready():
	update_entrance(PlayerVars.get_flag(SWITCH_FLAG_NAME))

func update_entrance(new_value):
	if new_value:
		entrance.room_id = "corridor"
		entrance.target_position = Vector2(0, -240)
	else:
		entrance.room_id = "center"
		entrance.target_position = Vector2(144, -100)

func _on_switch_toggled():
	var instructions = [
		"SHAKE FOR 2 FREQ 200 STR (20, 0) PRIORITY 1",
		"START_DIALOG interactions ID 1 SOURCE NONE"
	]
	yield(get_local_scene().play_custom_cutscene(instructions), "completed")
	var new_val = not PlayerVars.get_flag(SWITCH_FLAG_NAME)
	PlayerVars.set_flag(SWITCH_FLAG_NAME, new_val)
	
	update_entrance(new_val)
