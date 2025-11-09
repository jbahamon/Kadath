extends LocationRoom

@export var secret_room_bounds: Rect2i

func setup() -> void:
	if VarsService.get_flag("cavern_of_flame.sanctorum"):
		self.used_rect = self.used_rect.merge(self.secret_room_bounds)
