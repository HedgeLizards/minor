extends CollisionShape2D

var x
var y
var solid = true
var power = true
var type = 'Engine'

func is_valid(grid, gridW, gridH):
	return name == 'Core' or [
		(x > 0 and grid[x - 1][y] != null and grid[x - 1][y].solid),
		(y > 0 and grid[x][y - 1] != null and grid[x][y - 1].solid),
		(x < gridW - 1 and grid[x + 1][y] != null and grid[x + 1][y].solid),
		(y < gridH - 1 and grid[x][y + 1] != null and grid[x][y + 1].solid)
	].has(true)
