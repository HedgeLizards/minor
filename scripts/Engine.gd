extends CollisionShape2D

var components = [
	[null, null, null],
	[null, null, null],
	[null, null, null]
]

func add(x, y, component, vehicle):
	components[x + 1][y + 1] = component
	component.position = position + Vector2(64 * x, 64 * y)
	
	vehicle.add_child(component)

func remove(x, y):
	components[x + 1][y + 1].queue_free()
	components[x + 1][y + 1] = null
