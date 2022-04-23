extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const EMPTY_TILE = -1
const GROUND_TILE = 1
const GOLD_TILE = 2

var grid = {}


class TileType:
	var tileid
	var occluding
	var maxhealth
	func _init(tileid, occluding, maxhealth = 1.0):
		self.tileid = tileid
		self.occluding = occluding
		self.maxhealth = maxhealth

var EMPTY = TileType.new(EMPTY_TILE, false)
var GROUND = TileType.new(GROUND_TILE, true)
var GOLD = TileType.new(GOLD_TILE, true)

class Tile:
	var typ
	var visible
	var health
	func _init(typ, visible):
		self.health = typ.maxhealth
		self.typ = typ
		self.visible = visible

func repeat(val, n):
	var arr = []
	for i in range(n):
		arr.append(val)
	return arr

# Called when the node enters the scene tree for the first time.
func _ready():
	#grid[Vector2(321, 567)] = "abc"
	#print(grid[Vector2(321, 567)])

	$Tiles.clear()
	$Occlusion.clear()
	var filling = repeat(EMPTY, 5) + repeat(GROUND, 50) + repeat(GOLD, 1)

	for x in range(-100, 100):
		for y in range(-100, 100):
			var pos = Vector2(x, y)
			var tile
			if abs(x) + abs(y) < 8:
				tile = EMPTY
			else:
				tile = filling[randi() % len(filling)]
			grid[pos] = Tile.new(tile, false)

			$Tiles.set_cellv(pos, tile.tileid)
			$Occlusion.set_cellv(pos, 1)

	update_visibility(Vector2(0, 0))

func update_tile(pos, tile):
	if tile.typ == grid[pos].typ:
		return
	grid[pos] = tile
	$Tiles.set_cellv(pos, tile.typ.tileid)
	update_visibility(pos, true)

func update_visibility(pos, force=false):
	var tile = grid.get(pos)
	if tile == null:
		return
	var was_visible = tile.visible
	tile.visible = true
	$Occlusion.set_cellv(pos, 0)
	if not tile.typ.occluding and (not was_visible or force):
		update_visibility(Vector2(pos.x + 1, pos.y))
		update_visibility(Vector2(pos.x - 1, pos.y))
		update_visibility(Vector2(pos.x, pos.y + 1))
		update_visibility(Vector2(pos.x, pos.y - 1))


func _process(delta):
	var drills = get_tree().get_nodes_in_group("drillbits")
	for drill in drills:
		var local_position = $Tiles.to_local(drill.global_position)
		var map_position = $Tiles.world_to_map(local_position)
		update_tile(map_position, Tile.new(EMPTY, true))


