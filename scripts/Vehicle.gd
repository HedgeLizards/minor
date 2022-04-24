extends RigidBody2D

const COMPONENT_SIZE = Vector2(64, 64)
const COLOR_EMPTY = Color(0, 0.5, 1, 0.5)

var gridW = 3
var gridH = 3
var coreX = 1
var coreY = 1
var placing

onready var grid = [[null, null, null], [null, $Core, null], [null, null, null]]

onready var EngineScene = preload('res://scenes/Engine.tscn')
onready var DrillScene = preload('res://scenes/Drill.tscn')
onready var WheelScene = preload('res://scenes/Wheel.tscn')

onready var viewport = get_viewport()

func _ready():
	$Core.x = 1
	$Core.y = 1
	
	add_component(DrillScene.instance(), 0, -1)
	add_component(WheelScene.instance(), -1, 0)
	add_component(WheelScene.instance(), 1, 0)

func add_component(component, x, y):
	component.position = Vector2(x, y) * COMPONENT_SIZE
	component.x = x + coreX
	component.y = y + coreY
	
	grid[component.x][component.y] = component
	
	add_child(component)

func add_placeholder(template):
	placing = get('%sScene' % template.name).instance()
	
	$Sprite.texture = template.get_node('Icon').texture_normal
	$Sprite.position = to_local(viewport.get_mouse_position() - viewport.canvas_transform.origin)
	$Sprite.visible = true

func _input(event):
	if placing == null:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			var cell = (to_local(event.position - viewport.canvas_transform.origin) / COMPONENT_SIZE).round() + Vector2(coreX, coreY)
			
			if cell.x >= 0 and cell.y >= 0 and cell.x < gridW and cell.y < gridH and grid[cell.x][cell.y] != null:
				placing = grid[cell.x][cell.y]
				
				$Sprite.texture = placing.get_node('Sprite').frames.get_frame('default', 0)
				$Sprite.position = placing.position
				$Sprite.visible = true
				
				placing.visible = false
				
				grid[placing.x][placing.y] = null
				
				update()
	elif event is InputEventMouseMotion:
		$Sprite.position = to_local(event.position - viewport.canvas_transform.origin)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		var cell = (to_local(event.position - viewport.canvas_transform.origin) / COMPONENT_SIZE).round() + Vector2(coreX, coreY)
		
		if cell.x >= 0 and cell.y >= 0 and cell.x < gridW and cell.y < gridH and grid[cell.x][cell.y] == null:
			if placing.is_inside_tree():
				grid[placing.x][placing.y] = null
			
			grid[cell.x][cell.y] = placing
			
			var xOld = placing.x
			var yOld = placing.y
			
			placing.x = cell.x
			placing.y = cell.y
			
			if [
				(xOld == null or xOld == 0 or grid[xOld - 1][yOld] == null or grid[xOld - 1][yOld].is_valid(grid, gridW, gridH)),
				(yOld == null or yOld == 0 or grid[xOld][yOld - 1] == null or grid[xOld][yOld - 1].is_valid(grid, gridW, gridH)),
				(xOld == null or xOld == gridW - 1 or grid[xOld + 1][yOld] == null or grid[xOld + 1][yOld].is_valid(grid, gridW, gridH)),
				(yOld == null or yOld == gridH - 1 or grid[xOld][yOld + 1] == null or grid[xOld][yOld + 1].is_valid(grid, gridW, gridH)),
				placing.is_valid(grid, gridW, gridH)
			].has(false):
				grid[cell.x][cell.y] = null
				
				if placing.is_inside_tree():
					grid[xOld][yOld] = placing
					
					placing.x = xOld
					placing.y = yOld
					placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
				else:
					placing.queue_free()
			elif placing.is_inside_tree():
				placing.position = (cell - Vector2(coreX, coreY)) * COMPONENT_SIZE
			elif $'../Menu'.craft(placing.type):
				add_component(placing, cell.x - coreX, cell.y - coreY)
			else:
				placing.queue_free()
		elif placing.is_inside_tree():
			placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
		else:
			placing.queue_free()
		
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
	if placing != null and (Input.is_action_pressed('turnleft') or Input.is_action_pressed('turnright')):
		$Sprite.position = to_local(viewport.get_mouse_position() - viewport.canvas_transform.origin)

func _integrate_forces(state):
	var velocity = Vector2()
	
	if Input.is_action_pressed('forward'):
		velocity.y -= 200
	
	if Input.is_action_pressed('backward'):
		velocity.y += 200
	
	state.angular_velocity = (float(Input.is_action_pressed('turnright')) - float(Input.is_action_pressed('turnleft'))) * 2
	
	state.linear_velocity = velocity.rotated(rotation)
