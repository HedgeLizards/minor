extends Area2D

func _ready():
	connect('input_event', get_parent(), '_on_Vehicle_input_event', [self])
