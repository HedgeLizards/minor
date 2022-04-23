extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const EMPTY = -1
const GROUND = 1
const GOLD = 2

var filling = repeat(EMPTY, 5) + repeat(GROUND, 50) + repeat(GOLD, 1)

func repeat(val, n):
	var arr = []
	for i in range(n):
		arr.append(val)
	return arr

# Called when the node enters the scene tree for the first time.
func _ready():
	self.clear()

	for x in range(-100, 100):
		for y in range(-100, 100):
			if abs(x) + abs(y) < 8:
				continue
			var tile = filling[randi() % len(filling)]
			self.set_cell(x, y, tile)


func _process(delta):
	var drills = get_tree().get_nodes_in_group("drills")
	for drill in drills:
		var local_position = self.to_local(drill.global_position)
		var map_position = self.world_to_map(local_position)
		self.set_cellv(map_position, EMPTY)


