extends "res://location/lib/script/object/description_area.gd"

@export var flag_name: String

func get_dialogue_name():
	return (
		"statue_enabled" if VarsService.get_flag(self.flag_name) 
		else "statue_disabled"
	)
	
