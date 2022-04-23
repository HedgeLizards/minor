extends KinematicBody2D

onready var EngineScene = preload('res://scenes/Engine.tscn')
onready var DrillScene = preload('res://scenes/Drill.tscn')
onready var WheelScene = preload('res://scenes/Wheel.tscn')

func _ready():
	$Core.add(0, -1, DrillScene.instance(), self)
	$Core.add(-1, 0, WheelScene.instance(), self)
	$Core.add(1, 0, WheelScene.instance(), self)

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
