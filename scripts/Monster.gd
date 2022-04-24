extends RigidBody2D


var speed = 2000
var health = 2.0


func _physics_process(delta):

	var vehicle = get_node("/root/Main/Vehicle")
	if vehicle == null:
		return
	var direction = vehicle.position - position
	var vel = direction.normalized() * speed
	applied_force = vel

func do_damage(damage):
	self.health -= damage
	if self.health <= 0:
		self.die()


func die():
	queue_free()
