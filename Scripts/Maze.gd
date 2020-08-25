extends Node2D
class_name Maze
const Cell = preload("res://Scripts/Cell.gd");
const Utils = preload("res://Scripts/Utils.gd")
const Flood = preload("res://Scripts/Algorithms/Flood.gd")

var algorithms = [
	preload("res://Scripts/Algorithms/Prim.gd").new(),
	preload("res://Scripts/Algorithms/AldousBroder.gd").new(),
	preload("res://Scripts/Algorithms/DepthFirst.gd").new(),
]

#Ui Variables
onready var panel: Panel =  get_node("/root/Game/CanvasLayer/Divider/Panel")

# Maze variables
var cells: Array;
var generatingMaze = false
var cellStack = []
var flood: Flood = Flood.new()
var last


func _process(delta):
	flood.floodProcess(delta,self)
		
	if panel.complete :
		panel.complete = false
		while generatingMaze:
			algorithms[panel.algorithmOptions.selected].process(self)
	elif panel.runStop :
		if !generatingMaze:
			panel.stop = false
		else:
			algorithms[panel.algorithmOptions.selected].process(self)
	elif panel.step :
		panel.step = false
		algorithms[panel.algorithmOptions.selected].process(self)
	pass


func getCell(x,y):
	return cells[y * panel.xSpin.value +x];


func getNeighbors(x,y):
	var dummy = Cell.new()
	var width = panel.xSpin.value
	var height = panel.ySpin.value
	dummy.visit()
	return {
		Cell.Wall.UP: getCell(x,y-1) if y > 0 else dummy, 			#UP
		Cell.Wall.DOWN: getCell(x,y+1) if y < height-1 else dummy,	#DOWN
		Cell.Wall.LEFT: getCell(x-1,y) if x > 0 else dummy,			#LEFT
		Cell.Wall.RIGHT: getCell(x+1,y) if x < width-1 else dummy	#RIGHT
	}


func prepareMaze():	
	var width = panel.xSpin.value
	var height = panel.ySpin.value
	generatingMaze = false
	cells = []
	var size = height*width;
	for i in range(size):
		var cell = Cell.new();
		cell.x = i%int(width);
		cell.y = i/int(width);
		cells.append(cell);
	buildTiles()
	fixScale()
	last = getCell(0,0)


func startGeneration():
	algorithms[panel.algorithmOptions.selected].generate(self)
	generatingMaze = true
	fixScale()
	pass


func finishGeneration():
	generatingMaze = false
	buildTiles()
	panel.finishGeneration()
	pass


func fixScale():
	var width = panel.xSpin.value
	var height = panel.ySpin.value
	var viewportSize = get_parent().rect_size
	var mazeSize = Vector2(width*2+1, height*2+1) * $TileMap.get_cell_size()
	var scaleFactor = 1
	if viewportSize.aspect() > mazeSize.aspect():
		scaleFactor = viewportSize.y/mazeSize.y
	else:
		scaleFactor = viewportSize.x/mazeSize.x
	scale = Vector2(scaleFactor,scaleFactor)


func buildTiles():
	var width = panel.xSpin.value
	var height = panel.ySpin.value
	$TileMap.clear()
	for x in range(-1,width*2):
		for y in range(-1,height*2):
			$TileMap.set_cell(x+1,y+1,1)
	for cell in cells:
		buildCell(cell)


func buildCell(cell):
	var tm = $TileMap
	var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
	tm.set_cellv(vec, !cell.visited)
	tm.set_cellv(vec + Vector2(0,-1), cell.walls[Cell.Wall.UP])
	tm.set_cellv(vec + Vector2(0,+1), cell.walls[Cell.Wall.DOWN])
	tm.set_cellv(vec + Vector2(-1,0), cell.walls[Cell.Wall.LEFT])
	tm.set_cellv(vec + Vector2(+1,0), cell.walls[Cell.Wall.RIGHT])
