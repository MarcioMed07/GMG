const Utils = preload("res://Scripts/Utils.gd")
const name = "Aldous-Broder"

var last

func generate(maze):
	last = false
	maze.prepareMaze()
	maze.cellStack = []
	var cell = maze.getCell(0,0)
	cell.visit()
	maze.cellStack.push_front(cell)


func process(maze):
	if maze.cellStack.size() < maze.cells.size():
		var cell = maze.cellStack[0]
		var neiDict = maze.getNeighbors(cell.x,cell.y)
		var neiKeys = Utils.shuffle(neiDict.keys())
		for dir in neiKeys:
			if neiDict[dir].x >= 0:
				if !neiDict[dir].visited:
					neiDict[dir].setWall(Cell.oppositeWall(dir),false)
					cell.setWall(dir,false)
					neiDict[dir].visit()
					maze.cellStack.push_front(neiDict[dir])
				else:
					maze.cellStack.erase(neiDict[dir])
					maze.cellStack.push_front(neiDict[dir])
				break;
		buildTiles(maze, cell)
	else:
		maze.finishGeneration()

func buildTiles(maze, cell):
	if maze.panel.complete:
		return
	var tm = maze.get_node("TileMap")
	if last:
		buildCell(tm, last, Utils.TileColor.WHITE)
	last = cell
	buildCell(tm, cell, Utils.TileColor.RED, false)


func buildCell(tm, cell, color, buildWalls = true):
	var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
	tm.set_cellv(vec, color)
	if buildWalls:
		tm.set_cellv(vec + Vector2(0,-1), cell.walls[Cell.Wall.UP])
		tm.set_cellv(vec + Vector2(0,+1), cell.walls[Cell.Wall.DOWN])
		tm.set_cellv(vec + Vector2(-1,0), cell.walls[Cell.Wall.LEFT])
		tm.set_cellv(vec + Vector2(+1,0), cell.walls[Cell.Wall.RIGHT])
