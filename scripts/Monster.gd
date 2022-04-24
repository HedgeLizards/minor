extends RigidBody2D


var speed = 200
var health = 2.0
var path = []
var target = null
onready var vehicle = get_node("/root/Main/Vehicle")
onready var env = get_node("/root/Main/Environment")
var timeout = 0.5

func _process(delta):
	timeout -= delta
	if timeout <= 0:
		if global_position.distance_to(vehicle.global_position) < 128:
			target = vehicle.global_position
		else:
			plan()
		timeout = 0.2

func _integrate_forces(state):
	if target == null:
		return

	var direction = target - position
	var vel = direction.normalized() * speed
	state.linear_velocity = vel

func do_damage(damage):
	self.health -= damage
	if self.health <= 0:
		self.die()

func plan():
	path = []
	target = null
	if path.empty() or global_position.distance_to(vehicle.global_position) < 32:
		var end = env.calc_id(env.world_to_tile(vehicle.global_position))
		var start = env.calc_id(env.world_to_tile(global_position))
		if env.astar.has_point(end) and env.astar.has_point(start):
			path = env.astar.get_point_path(start, end)
			if path.size() > 1:
				target = env.tile_to_world(path[1])
			elif path.size() > 0:
				target = env.tile_to_world(path[0])



func die():
	queue_free()
