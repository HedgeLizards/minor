extends KinematicBody2D


var speed = 200


func _physics_process(delta):

	var direction = get_node("/root/Main/Vehicle").position - position
	var vel = direction.normalized() * speed
	move_and_slide(vel)

