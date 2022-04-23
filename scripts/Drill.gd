extends Area2D

export var damage = 1.0


func _ready():
	connect('input_event', get_parent(), '_on_Vehicle_input_event', [self])
