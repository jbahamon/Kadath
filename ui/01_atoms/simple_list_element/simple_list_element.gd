extends Button

func _init():
	self.alignment
	
func get_button():
	return self

func assign_element(element):
	self.text = element.display_name 

func assign_null(args: Dictionary):
	self.text = args["display_name"]
