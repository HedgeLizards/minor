extends KinematicBody2D

const COMPONENT_SIZE = Vector2(64, 64)
const COLOR_EMPTY = Color(0, 0.5, 1, 0.5)

var coreX = 1
var coreY = 1

onready var shapes = [$Core]
onready var components = [
	[null, null, null],
	[null, $Core, null],
	[null, null, null]
]

onready var EngineScene = preload('res://scenes/Engine.tscn')
onready var DrillScene = preload('res://scenes/Drill.tscn')
onready var WheelScene = preload('res://scenes/Wheel.tscn')

func _ready():
	add_component(DrillScene, 0, -1)
	add_component(WheelScene, -1, 0)
	add_component(WheelScene, 1, 0)

func add_component(scene, x, y):
	var component = scene.instance()
	
	if component is CollisionShape2D:
		shapes.push_back(component)
	
	components[coreX + x][coreY + y] = component
	component.position = Vector2(x, y) * COMPONENT_SIZE
	
	add_child(component)

func remove_component(x, y):
	components[coreX + x][coreY + y].queue_free()
	components[coreX + x][coreY + y] = null

func _on_Vehicle_input_event(viewport, event, shape_idx, component = null):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if component == null:
			component = shapes[shape_idx]
		
		component.rotation_degrees += 90

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		print((to_local(event.position) / COMPONENT_SIZE).round())

#func _draw():
#	for x in range(components.size()):
#		for y in range(components[x].size()):
#			if components[x][y] == null:
#				draw_rect(Rect2(
#					Vector2((x - coreX - 0.5), (y - coreY - 0.5)) * COMPONENT_SIZE + Vector2(2, 2),
#					COMPONENT_SIZE - Vector2(4, 4)
#				), COLOR_EMPTY)

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
