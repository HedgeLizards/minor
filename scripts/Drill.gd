extends Area2D

export var damage = 1.0

var x
var y
var solid = false
var power = false
var type = 'Drill'

func is_valid(grid, gridW, gridH):
	return [
		(x > 0 and grid[x - 1][y] != null and grid[x - 1][y].solid),
		(y > 0 and grid[x][y - 1] != null and grid[x][y - 1].solid),
		(x < gridW - 1 and grid[x + 1][y] != null and grid[x + 1][y].solid),
		(y < gridH - 1 and grid[x][y + 1] != null and grid[x][y + 1].solid)
	].has(true) and [
		(x > 0 and grid[x - 1][y] != null and grid[x - 1][y].power),
		(y > 0 and grid[x][y - 1] != null and grid[x][y - 1].power),
		(x < gridW - 1 and grid[x + 1][y] != null and grid[x + 1][y].power),
		(y < gridH - 1 and grid[x][y + 1] != null and grid[x][y + 1].power),
		(x > 0 and y > 0 and grid[x - 1][y - 1] != null and grid[x - 1][y - 1].power),
		(x > 0 and y < gridH - 1 and grid[x - 1][y + 1] != null and grid[x - 1][y + 1].power),
		(x < gridW - 1 and y > 0 and grid[x + 1][y - 1] != null and grid[x + 1][y - 1].power),
		(x < gridW - 1 and y < gridH - 1 and grid[x + 1][y + 1] != null and grid[x + 1][y + 1].power)
	].has(true)

func _ready():
	connect('input_event', get_parent(), '_on_Vehicle_input_event', [self])



func _physics_process(delta):
	var enemies = $Weapon.get_overlapping_bodies()
	for enemy in enemies:
		enemy.do_damage(damage * delta)
