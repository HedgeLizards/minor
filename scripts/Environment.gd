extends Node2D

export var reveal_all = false
const MonsterScene = preload("res://scenes/Monster.tscn")

const EMPTY_TILE = -1
const GROUND_TILE = 0
const ALUMINIUM_TILE = 1
const IRON_TILE = 2
const GOLD_TILE = 3


class TileType:
	var tileid
	func _init(tileid):
		self.tileid = tileid
	func tileid():
		return tileid
	func is_occluding():
		return false
	func maxhealth():
		return 1.0
	func is_destructible():
		return false
	func is_cave():
		return false
	func spawns():
		return []
	func loot():
		return {}

class Empty:
	extends TileType
	func _init().(EMPTY_TILE):
		pass

class Cave:
	extends Empty
	func is_cave():
		return true

class Monster:
	extends Cave
	func is_cave():
		return true
	func spawns():
		return [MonsterScene]

class Stone:
	extends TileType
	func _init().(GROUND_TILE):
		pass
	func is_occluding():
		return true
	func is_destructible():
		return true

class Ore:
	extends TileType
	var loot
	func _init(tileid, loot={}).(tileid):
		self.loot = loot
	func is_occluding():
		return true
	func is_destructible():
		return true
	func maxhealth():
		return 2.0
	func loot():
		return self.loot


var EMPTY = Empty.new()
var CAVE = Cave.new()
var MONSTER = Monster.new()
var GROUND = Stone.new()
var ALUMINIUM = Ore.new(ALUMINIUM_TILE, {"Aluminium": 1})
var IRON = Ore.new(IRON_TILE, {"Iron": 1})
var GOLD = Ore.new(GOLD_TILE, {"Gold": 1})

class Tile:
	var typ
	var visible
	var health
	func _init(typ, visible=false):
		self.health = typ.maxhealth()
		self.typ = typ
		self.visible = visible

func repeat(val, n):
	var arr = []
	for i in range(n):
		arr.append(val)
	return arr


var grid = {}


func _ready():
	randomize()

	$Tiles.clear()
	$Occlusion.clear()

	generate()

	update_visibility(Vector2(0, 0))
	if reveal_all:
		$Occlusion.visible = false


func sqr(x):
	return x * x


var filling = {
	"safe": repeat(EMPTY, 5) + repeat(GROUND, 4) + repeat(ALUMINIUM, 1),
	"basic": repeat(EMPTY, 1) + repeat(GROUND, 7) + repeat(ALUMINIUM, 2) + repeat(MONSTER, 1),
	"further": repeat(EMPTY, 1) + repeat(GROUND, 7) + repeat(ALUMINIUM, 2) + repeat(IRON, 2) + repeat(MONSTER, 1)
}

func gen_tile(pos):
	var dist = int(pos.length())
	if dist < 6:
		return EMPTY
	elif randf() > 0.1:
		return GROUND
	var filler
	if dist < 12:
		filler = filling.safe
	elif dist < 48:
		filler = filling.basic
	else:
		filler = filling.further
	return filler[randi() % len(filler)]

func generate():
	var blueprint = {}
	for x in range(-100, 100):
		for y in range(-100, 100):
			var pos = Vector2(x, y)
			if blueprint.has(pos):
				continue
			var tile = gen_tile(pos)
			blueprint[pos] = tile
			if tile == MONSTER:
				dig_cave(blueprint, pos, 6)
				dig_cave(blueprint, pos, 6)
				dig_cave(blueprint, pos, 6)
	for pos in blueprint:
		update_tile(pos, Tile.new(blueprint[pos]), false)


func dig_cave(map, pos, life=4):
	pos += [Vector2(0, 1), Vector2(1, 0), Vector2(0, -1), Vector2(-1, 0)][int(randf() * 4)]
	if life <= 0 or map.get(pos, EMPTY).is_cave():
		return
	map[pos] = CAVE
	dig_cave(map, pos, life - 1)
	#if randf() < 0.5:
	dig_cave(map, pos, life - 1)

func update_tile(pos, tile, view = false):
	grid[pos] = tile
	$Tiles.set_cellv(pos, tile.typ.tileid())
	if view:
		update_visibility(pos, true)
	else:
		$Occlusion.set_cellv(pos, 1)


func update_visibility(pos, force=false):
	var frontier = {} # actually a set
	update_visibility_(pos, frontier, force)
	for pos in frontier:
		var tile = grid.get(pos)
		if tile and not tile.visible:
			var tl = check_visibility(pos, Vector2(-1, -1))
			var bl = check_visibility(pos, Vector2(-1, 1))
			var tr = check_visibility(pos, Vector2(1, -1))
			var br = check_visibility(pos, Vector2(1, 1))
			var index = Vector2(tl + 2 * tr, bl + 2 * br)
			$Occlusion.set_cellv(pos, 2, false, false, false, index)

func check_visibility(pos, offset):
	for o in [offset, Vector2(offset.x, 0), Vector2(0, offset.y)]:
		if grid.get(pos + o, EMPTY).visible:
			return 0
	return 1


func update_visibility_(pos, frontier, force=false):
	var tile = grid.get(pos)
	if tile == null or (tile.visible and not force) or tile.typ.is_occluding():
		return
	tile.visible = true
	$Occlusion.set_cellv(pos, 0)
	for scene in tile.typ.spawns():
		spawn_monster(pos, scene)
	update_visibility_(Vector2(pos.x + 1, pos.y), frontier)
	update_visibility_(Vector2(pos.x - 1, pos.y), frontier)
	update_visibility_(Vector2(pos.x, pos.y + 1), frontier)
	update_visibility_(Vector2(pos.x, pos.y - 1), frontier)
	for x in range(-1, 2):
		for y in range(-1, 2):
			frontier[Vector2(x, y) + pos] = null

func spawn_monster(map_pos, scene):
	var pos = $Tiles.to_global($Tiles.map_to_world(map_pos + Vector2(0.5, 0.5)))
	var monster = scene.instance()
	monster.global_position = pos
	add_child(monster)

func _process(delta):
	var drills = get_tree().get_nodes_in_group("drillbits")
	for drill in drills:
		var local_position = $Tiles.to_local(drill.global_position)
		var map_pos = $Tiles.world_to_map(local_position)
		var tile = grid.get(map_pos)
		if tile != null and tile.typ.is_destructible():
			var damage = drill.get_parent().damage * delta
			tile.health -= damage
			var broken_state = 3 - int(tile.health / tile.typ.maxhealth() * 4)
			$Breaking.set_cellv(map_pos, broken_state)
			if tile.health <= 0.0:
				update_tile(map_pos, Tile.new(EMPTY), true)
				$Breaking.set_cellv(map_pos, -1)
				var inventory = get_node("/root/Main/Menu")
				var loot = tile.typ.loot()
				if loot.size() > 0:
					inventory.add(loot)



