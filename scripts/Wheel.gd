extends CollisionShape2D

var x
var y
var solid = false
var power = false

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
