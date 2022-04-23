extends KinematicBody2D

func _physics_process(delta):
	var velocity = Vector2()
	
	if Input.is_action_pressed('ui_up'):
		velocity.y -= 200
	
	if Input.is_action_pressed('ui_down'):
		velocity.y += 200
	
	if Input.is_action_pressed('ui_left'):
		rotation_degrees -= 2
	
	if Input.is_action_pressed('ui_right'):
		rotation_degrees += 2
	
	move_and_slide(velocity.rotated(rotation))
