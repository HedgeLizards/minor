extends Node2D


const Monster = preload("res://scenes/Monster.tscn")

const EMPTY_TILE = -1
const GROUND_TILE = 0
const IRON_TILE = 1

var grid = {}


class TileType:
	var tileid
	var occluding
	var maxhealth
	var destructible
	func _init(tileid, maxhealth = 1.0, occluding = true, destructible = true):
		self.tileid = tileid
		self.occluding = occluding
		self.maxhealth = maxhealth
		self.destructible = destructible

var EMPTY = TileType.new(EMPTY_TILE, 0.0, false, false)
var MONSTER = TileType.new(EMPTY_TILE, 0.0, false, false)
var GROUND = TileType.new(GROUND_TILE, 1.0)
var IRON = TileType.new(IRON_TILE, 2.0)

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

func _ready():
	randomize()

	$Tiles.clear()
	$Occlusion.clear()
	var filling = repeat(EMPTY, 5) + repeat(GROUND, 50) + repeat(IRON, 1) + repeat(MONSTER, 4)

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
		if tile.typ == MONSTER:
			spawn_monster(pos)
		update_visibility(Vector2(pos.x + 1, pos.y))
		update_visibility(Vector2(pos.x - 1, pos.y))
		update_visibility(Vector2(pos.x, pos.y + 1))
		update_visibility(Vector2(pos.x, pos.y - 1))

func spawn_monster(map_pos):
	var pos = $Tiles.to_global($Tiles.map_to_world(map_pos))
	var monster = Monster.instance()
	monster.global_position = pos
	add_child(monster)

func _process(delta):
	var drills = get_tree().get_nodes_in_group("drillbits")
	for drill in drills:
		var local_position = $Tiles.to_local(drill.global_position)
		var map_position = $Tiles.world_to_map(local_position)
		var tile = grid.get(map_position)
		if tile.typ.destructible:
			var damage = drill.get_parent().damage * delta
			tile.health -= damage
			if tile.health <= 0.0:
				update_tile(map_position, Tile.new(EMPTY, true))

