const Utils = preload("res://Scripts/Utils.gd")
const name = "Depth First"


static func generate(maze):
	maze.prepareMaze()
	var x = 0;
	var y = 0;
	maze.cellStack = []
	var cell = maze.getCell(x,y)
	cell.visit()
	maze.cellStack.push_back(cell)
	
	
static func process(maze):
	if maze.cellStack.size() > 0:
		var found = false
		var cell = maze.cellStack.pop_front()
		var neiDict = maze.getNeighbors(cell.x,cell.y)
		var neiKeys = Utils.shuffle(neiDict.keys())
		for dir in neiKeys:
			if !neiDict[dir].visited:
				maze.cellStack.push_front(cell)
				neiDict[dir].setWall(Cell.oppositeWall(dir),false);
				cell.setWall(dir,false)
				neiDict[dir].visit()
				maze.cellStack.push_front(neiDict[dir])
				found = true
				break
		if !found:
			process(maze)
	else:
		maze.finishGeneration()
