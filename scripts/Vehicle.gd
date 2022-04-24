extends RigidBody2D

const COMPONENT_SIZE = Vector2(64, 64)
const COLOR_EMPTY = Color(0, 0.5, 1, 0.5)

var gridW = 5
var gridH = 3
var coreX = 2
var coreY = 1
var placing setget set_placing
var oldRotation

onready var grid = [
	[null, null, null],
	[null, null, null],
	[null, $Core, null],
	[null, null, null],
	[null, null, null]
]

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
	self.placing = get('%sScene' % template.name).instance()
	
	$Sprite.texture = template.get_node('Icon').texture_normal
	$Sprite.position = to_local(viewport.get_mouse_position() - viewport.canvas_transform.origin)
	$Sprite.visible = true

func set_placing(new_value):
	placing = new_value
	
	if placing == null:
		$'../Menu/Controls'.visible = false
	else:
		$'../Menu/Controls'.visible = true
		$'../Menu/Controls/Rotate'.visible = !placing.solid
		$'../Menu/Controls/Deconstruct'.visible = placing.is_inside_tree()
		
		$Sprite.rotation = placing.rotation
		
		oldRotation = placing.rotation
	
	update()

func _input(event):
	if placing == null:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			var core = Vector2(coreX, coreY)
			var cell = (to_local(event.position - viewport.canvas_transform.origin) / COMPONENT_SIZE).round() + core
			
			if cell.x >= 0 and cell.y >= 0 and cell.x < gridW and cell.y < gridH and cell != core and grid[cell.x][cell.y] != null:
				self.placing = grid[cell.x][cell.y]
				
				$Sprite.texture = placing.get_node('Sprite').frames.get_frame('default', 0)
				$Sprite.position = placing.position
				$Sprite.visible = true
				
				placing.visible = false
				
				grid[placing.x][placing.y] = null
	elif event is InputEventMouseMotion:
		$Sprite.position = to_local(event.position - viewport.canvas_transform.origin)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		var core = Vector2(coreX, coreY)
		var cell = (to_local(event.position - viewport.canvas_transform.origin) / COMPONENT_SIZE).round() + core
		
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
					placing.rotation = oldRotation
				else:
					placing.queue_free()
			elif placing.is_inside_tree():
				placing.position = (cell - core) * COMPONENT_SIZE
				
				resize_grid()
			elif $'../Menu'.craft(placing.type):
				add_component(placing, cell.x - coreX, cell.y - coreY)
				
				resize_grid()
			else:
				placing.queue_free()
		elif placing.is_inside_tree():
			grid[placing.x][placing.y] = placing
			
			placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
			placing.rotation = oldRotation
		else:
			placing.queue_free()
		
		$Sprite.visible = false
		placing.visible = true
		
		self.placing = null
	elif event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_R:
				if not placing.solid:
					$Sprite.rotation_degrees += 90
					placing.rotation_degrees += 90
			KEY_BACKSPACE:
				if placing.is_inside_tree():
					$'../Menu'.deconstruct(placing.type)
					
					grid[placing.x][placing.y] = null
					
					placing.queue_free()
					
					$Sprite.visible = false
					
					self.placing = null
			KEY_ESCAPE:
				if placing.is_inside_tree():
					grid[placing.x][placing.y] = placing
					
					placing.position = Vector2(placing.x - coreX, placing.y - coreY) * COMPONENT_SIZE
					placing.rotation = oldRotation
					placing.visible = true
				else:
					placing.queue_free()
				
				$Sprite.visible = false
				
				self.placing = null

func resize_grid():
	var has_solid = false
	
	for y in range(gridH):
		if grid[0][y] != null and grid[0][y].solid:
			has_solid = true
	
	if has_solid:
		var column = []
		
		for y in range(gridH):
			column.push_back(null)
		
		grid.push_front(column)
		
		gridW += 1
		coreX += 1
	else:
		has_solid = false
		
		for y in range(gridH):
			if grid[1][y] != null and grid[1][y].solid:
				has_solid = true
		
		if not has_solid:
			grid.pop_front()
			
			gridW -= 1
			coreX -= 1
	
	has_solid = false
	
	for y in range(gridH):
		if grid[gridW - 1][y] != null and grid[gridW - 1][y].solid:
			has_solid = true
	
	if has_solid:
		var column = []
		
		for y in range(gridH):
			column.push_back(null)
		
		grid.push_back(column)
		
		gridW += 1
	else:
		has_solid = false
		
		for y in range(gridH):
			if grid[gridW - 2][y] != null and grid[gridW - 2][y].solid:
				has_solid = true
		
		if not has_solid:
			grid.pop_back()
			
			gridW -= 1
	
	has_solid = false
	
	for x in range(gridW):
		if grid[x][0] != null and grid[x][0].solid:
			has_solid = true
	
	if has_solid:
		for row in grid:
			row.push_front(null)
		
		gridH += 1
		coreY += 1
	else:
		has_solid = false
		
		for x in range(gridW):
			if grid[x][1] != null and grid[x][1].solid:
				has_solid = true
		
		if not has_solid:
			for row in grid:
				row.pop_front()
			
			gridH -= 1
			coreY -= 1
	
	has_solid = false
	
	for x in range(gridW):
		if grid[x][gridH - 1] != null and grid[x][gridH - 1].solid:
			has_solid = true
	
	if has_solid:
		for row in grid:
			row.push_back(null)
		
		gridH += 1
	else:
		has_solid = false
		
		for x in range(gridW):
			if grid[x][gridH - 2] != null and grid[x][gridH - 2].solid:
				has_solid = true
		
		if not has_solid:
			for row in grid:
				row.pop_back()
			
			gridH -= 1
	
	for x in range(gridW):
		for y in range(gridH):
			if grid[x][y] != null:
				grid[x][y].x = x
				grid[x][y].y = y

func _draw():
	if placing != null:
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

	#var vel = -(float(Input.is_action_pressed('forward')) - float(Input.is_action_pressed('backward'))) * 2_000_000
	#var rot = (float(Input.is_action_pressed('turnright')) - float(Input.is_action_pressed('turnleft'))) * 30_000_000
	#applied_torque = rot
	#applied_force = Vector2(0, vel).rotated(rotation)



func _integrate_forces(state):
	var velocity = Vector2()

	if Input.is_action_pressed('forward'):
		velocity.y -= 200

	if Input.is_action_pressed('backward'):
		velocity.y += 200

	state.angular_velocity = (float(Input.is_action_pressed('turnright')) - float(Input.is_action_pressed('turnleft'))) * 2

	state.linear_velocity = velocity.rotated(rotation)

