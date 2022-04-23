extends KinematicBody2D

func _physics_process(delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed('forward'):
		velocity.y -= 200
	
	if Input.is_action_pressed('backward'):
		velocity.y += 200
	
	if Input.is_action_pressed('turnleft'):
		rotation_degrees -= 2
	
	if Input.is_action_pressed('turnright'):
		rotation_degrees += 2
	
	move_and_slide(velocity.rotated(rotation))
