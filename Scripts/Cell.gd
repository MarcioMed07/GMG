extends Node
class_name Cell

enum Wall{UP, DOWN, LEFT, RIGHT};

var visited: bool;
var filled: bool;
var walls = {
	Wall.UP: true,
	Wall.DOWN: true,
	Wall.LEFT: true,
	Wall.RIGHT: true,
}

var x: int = -1;
var y: int = -1;

func _ready():
	visited = false;


func visit():
	visited = true;


func fill():
	filled = true;


func setWall(wall: int, value: bool):
	walls[wall] = value;
	

func pathBetween(cell: Cell):
	var wb = []
	for wall in walls:
		if wall == false && cell.walls[oppositeWall(wall)] == false:
			wb.append(wall)
	return wb

static func oppositeWall(wall:int):
	var opposite
	match(wall):
		Wall.UP: 
			opposite = Wall.DOWN
		Wall.DOWN: 
			opposite = Wall.UP
		Wall.LEFT: 
			opposite = Wall.RIGHT
		Wall.RIGHT: 
			opposite = Wall.LEFT
	return opposite
