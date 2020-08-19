const Utils = preload("res://Scripts/Utils.gd")
const name = "Aldous-Broder"


static func generate(maze):
	maze.prepareMaze()
	maze.cellStack = []
	var cell = maze.getCell(0,0)
	cell.visit()
	maze.cellStack.push_front(cell)


static func process(maze):
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
	else:
		maze.finishGeneration()

