extends Area2D

signal interacted_with


func trigger_interaction():
	emit_signal("interacted_with")
