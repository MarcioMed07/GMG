const Utils = preload("res://Scripts/Utils.gd")
const name = "Depth First"

var last
var notFoundCount = 0

func generate(maze):
	maze.prepareMaze()
	notFoundCount = 0
	var x = 0;
	var y = 0;
	maze.cellStack = []
	var cell = maze.getCell(x,y)
	cell.visit()
	maze.cellStack.push_back(cell)
	
	
func process(maze):
	if maze.cellStack.size() > 0:
		var found = false
		var cell = maze.cellStack.pop_front()
		var neiDict = maze.getNeighbors(cell.x,cell.y)
		var neiKeys = Utils.shuffle(neiDict.keys())
		for dir in neiKeys:
			if !neiDict[dir].visited:
				maze.cellStack.push_front(cell)
				buildCell(cell,maze,Utils.TileColor.RED,Utils.TileColor.PINK, false)
				if notFoundCount == 0:
					buildCell(last,maze,Utils.TileColor.PINK,Utils.TileColor.PINK)
				else:
					buildCell(last,maze,Utils.TileColor.WHITE,Utils.TileColor.WHITE)
				notFoundCount = 0
				neiDict[dir].setWall(Cell.oppositeWall(dir),false);
				cell.setWall(dir,false)
				neiDict[dir].visit()
				maze.cellStack.push_front(neiDict[dir])
				found = true
				break
		if !found:
			if notFoundCount > 0:
				buildCell(cell,maze,Utils.TileColor.RED,Utils.TileColor.WHITE, false)
				buildCell(last,maze,Utils.TileColor.WHITE,Utils.TileColor.WHITE)
			else:
				buildCell(cell,maze,Utils.TileColor.RED,Utils.TileColor.PINK)
				buildCell(last,maze,Utils.TileColor.PINK,Utils.TileColor.PINK, false)
			notFoundCount +=1

		last = cell
	else:
		maze.finishGeneration()


func buildCell(cell, maze, color, wallColor, drawWalls = true):
	if maze.panel.complete:
		return
	if !cell:
		return
	var tm = maze.get_node("TileMap")
	var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
	tm.set_cellv(vec, color)
	if drawWalls:
		tm.set_cellv(vec + Vector2(0,-1),1 if cell.walls[Cell.Wall.UP] else wallColor)
		tm.set_cellv(vec + Vector2(0,+1),1 if cell.walls[Cell.Wall.DOWN] else wallColor)
		tm.set_cellv(vec + Vector2(-1,0),1 if cell.walls[Cell.Wall.LEFT] else wallColor)
		tm.set_cellv(vec + Vector2(+1,0),1 if cell.walls[Cell.Wall.RIGHT] else wallColor)
