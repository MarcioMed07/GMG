const Utils = preload("res://Scripts/Utils.gd")
const name = "Simple Prim"

## Prim
static func generate(maze):
	maze.prepareMaze()
	maze.cellStack = []
	var cell = maze.getCell(0,0)
	cell.visit()
	maze.cellStack.push_front(cell)
	pass


static func process(maze):
	if maze.cellStack.size() > 0:
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
				break
	else:
		maze.finishGeneration()
	pass
