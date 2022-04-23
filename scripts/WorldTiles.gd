extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	var drills = get_tree().get_nodes_in_group("drills")
	for drill in drills:
		var local_position = self.to_local(drill.global_position)
		var map_position = self.world_to_map(local_position)
		self.set_cell(map_position.x, map_position.y, -1)


