const Utils = preload("res://Scripts/Utils.gd")
const name = "Simple Prim"

var last = []

func generate(maze):
	maze.prepareMaze()
	maze.cellStack = []
	var cell = maze.getCell(0,0)
	cell.visit()
	last = [cell]
	maze.cellStack.push_front(cell)
	pass


func process(maze):
	if maze.cellStack.size() > 0:
		var found = false
		while !last.empty():
			var lastCell = last.pop_front()
			buildCell(maze, lastCell, Utils.TileColor.WHITE, true)
		maze.cellStack = Utils.shuffle(maze.cellStack)
		var cell = maze.cellStack.pop_front()
		var neiDict = maze.getNeighbors(cell.x,cell.y)
		var neiKeys = Utils.shuffle(neiDict.keys())
		for dir in neiKeys:
			if !neiDict[dir].visited:
				neiDict[dir].setWall(Cell.oppositeWall(dir),false);
				cell.setWall(dir,false)
				neiDict[dir].visit()
				maze.cellStack.push_front(neiDict[dir])
				maze.cellStack.push_front(cell)
				found = neiDict[dir]
				break
		if !found:
			process(maze)
		else:
			buildCell(maze, found, Utils.TileColor.RED, true)
			buildCell(maze, cell, Utils.TileColor.RED, false)
			last.append(cell)
			last.append(found)

	else:
		maze.finishGeneration()
	pass


func buildCell(maze, cell, color, buildWalls = true):
	var tm = maze.get_node("TileMap")
	var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
	tm.set_cellv(vec, color)
	if buildWalls:
		tm.set_cellv(vec + Vector2(0,-1),Utils.TileColor.BLACK if cell.walls[Cell.Wall.UP] else color)
		tm.set_cellv(vec + Vector2(0,+1),Utils.TileColor.BLACK if cell.walls[Cell.Wall.DOWN] else color)
		tm.set_cellv(vec + Vector2(-1,0),Utils.TileColor.BLACK if cell.walls[Cell.Wall.LEFT] else color)
		tm.set_cellv(vec + Vector2(+1,0),Utils.TileColor.BLACK if cell.walls[Cell.Wall.RIGHT] else color)
