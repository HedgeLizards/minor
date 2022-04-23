extends KinematicBody2D

const COMPONENT_SIZE = Vector2(64, 64)
const COLOR_EMPTY = Color(0, 0.5, 1, 0.5)

var gridW = 3
var gridH = 3
var coreX = 1
var coreY = 1
var placing = null

onready var grid = [[null, null, null], [null, $Core, null], [null, null, null]]
onready var shapes = [$Core]

onready var EngineScene = preload('res://scenes/Engine.tscn')
onready var DrillScene = preload('res://scenes/Drill.tscn')
onready var WheelScene = preload('res://scenes/Wheel.tscn')

onready var viewport = get_viewport()

func _ready():
	$Core.x = 1
	$Core.y = 1
	
	add_component(DrillScene, 0, -1)
	add_component(WheelScene, -1, 0)
	add_component(WheelScene, 1, 0)

func add_component(scene, x, y):
	var component = scene.instance()

	component.position = Vector2(x, y) * COMPONENT_SIZE
	component.x = x + coreX
	component.y = y + coreY
	
	grid[component.x][component.y] = component
	
	if component is CollisionShape2D:
		shapes.push_back(component)
	
	add_child(component)

func _on_Vehicle_input_event(viewport, event, shape_idx, component = null):
	if placing == null and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		if component != null:
			placing = component
		elif shapes[shape_idx] != $Core:
			placing = shapes[shape_idx]
		else:
			return
		
		grid[placing.x][placing.y] = null
		
		placing.visible = false
		
		$Sprite.visible = true
		$Sprite.transform = placing.transform
		$Sprite.texture = placing.get_node('Sprite').texture
		$Sprite.modulate = placing.get_node('Sprite').modulate # temporary
		
		update()

func _unhandled_input(event):
	if placing == null:
		return
	
	if event is InputEventMouseMotion:
		$Sprite.position = to_local(event.position - viewport.canvas_transform.origin)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		var cell = (to_local(event.position - viewport.canvas_transform.origin) / COMPONENT_SIZE).round() + Vector2(coreX, coreY)
		
		if cell.x >= 0 and cell.y >= 0 and cell.x < gridW and cell.y < gridH and grid[cell.x][cell.y] == null:
			grid[placing.x][placing.y] = null
			grid[cell.x][cell.y] = placing
			
			var xOld = placing.x
			var yOld = placing.y
			
			placing.x = cell.x
			placing.y = cell.y
			
			if [
				(xOld == 0 or grid[xOld - 1][yOld] == null or grid[xOld - 1][yOld].is_valid(grid, gridW, gridH)),
				(yOld == 0 or grid[xOld][yOld - 1] == null or grid[xOld][yOld - 1].is_valid(grid, gridW, gridH)),
				(xOld == gridW - 1 or grid[xOld + 1][yOld] == null or grid[xOld + 1][yOld].is_valid(grid, gridW, gridH)),
				(yOld == gridH - 1 or grid[xOld][yOld + 1] == null or grid[xOld][yOld + 1].is_valid(grid, gridW, gridH)),
				placing.is_valid(grid, gridW, gridH)
			].has(false):
				grid[placing.x][placing.y] = null
				grid[xOld][yOld] = placing
				
				placing.x = xOld
				placing.y = yOld
				placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
			else:
				placing.position = (cell - Vector2(coreX, coreY)) * COMPONENT_SIZE
		else:
			placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
		
		$Sprite.visible = false
		
		placing.visible = true
		placing = null
		
		update()

func _draw():
	for x in range(gridW):
		for y in range(gridH):
			if grid[x][y] == null:
				draw_rect(Rect2(
					Vector2((x - coreX - 0.5), (y - coreY - 0.5)) * COMPONENT_SIZE + Vector2(2, 2),
					COMPONENT_SIZE - Vector2(4, 4)
				), COLOR_EMPTY)

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
	
	if placing != null and (Input.is_action_pressed('turnleft') or Input.is_action_pressed('turnright')):
		$Sprite.position = to_local(viewport.get_mouse_position() - viewport.canvas_transform.origin)
	
	move_and_slide(velocity.rotated(rotation))
