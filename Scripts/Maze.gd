extends Node2D
class_name Maze
const Cell = preload("res://Scripts/Cell.gd");
const Utils = preload("res://Scripts/Utils.gd")

const algorithms = [
	preload("res://Scripts/Algorithms/Prim.gd"),
	preload("res://Scripts/Algorithms/DepthFirst.gd"),
	preload("res://Scripts/Algorithms/AldousBroder.gd")
]

#Ui Variables
onready var panel: Panel =  get_node("/root/Game/CanvasLayer/Divider/Panel")

# Maze variables
var cells: Array;
var generatingMaze = false
var cellStack = []

# Flood variables
var floodQueue = []
var floodPause = false
var speedModifier = 0.5
var floodCD = speedModifier
var last


func _ready():
	pass


func _process(delta):
	if Input.is_action_just_pressed("mouse_click"):
		floodQueue.append($TileMap.world_to_map(get_global_mouse_position()/scale))
	floodProcess(delta)
		
	if panel.complete :
		panel.complete = false
		while generatingMaze:
			algorithms[panel.algorithmOptions.selected].process(self)
	elif panel.runStop :
		if !generatingMaze:
			panel.stop = false
		else:
			algorithms[panel.algorithmOptions.selected].process(self)
			buildTiles(true)
	elif panel.step :
		panel.step = false
		algorithms[panel.algorithmOptions.selected].process(self)
		buildTiles(true)
	pass


## Maze Utils
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
	$TileMap.clear()
	buildTiles()
	fixScale()
	last = getCell(0,0)
	

func startGeneration():
	algorithms[panel.algorithmOptions.selected].generate(self)
	floodQueue = []
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


func buildTiles(building = false, neighbors = true):
	var width = panel.xSpin.value
	var height = panel.ySpin.value
	if building && cellStack.size() > 0:
		var cell = cellStack[0]
		if !last:
			last = getCell(0,0)
		if neighbors:
			for lastNei in getNeighbors(last.x,last.y).values():
				if lastNei.x >=0:
					buildCell(lastNei)
		buildCell(last)
		last = cell
		buildCell(cell,building)
		if neighbors:
			for nei in getNeighbors(cell.x,cell.y).values():
				if nei.x >=0:
					buildCell(nei)
	else:
		$TileMap.clear()
		for x in range(-1,width*2):
			for y in range(-1,height*2):
				$TileMap.set_cell(x+1,y+1,1)
		for cell in cells:
			buildCell(cell)


func buildCell(cell, building = false):
	var tm = $TileMap
	var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
	tm.set_cellv(vec, 3 if building && cell.visited else !cell.visited)
	tm.set_cellv(vec + Vector2(0,-1), cell.walls[Cell.Wall.UP])
	tm.set_cellv(vec + Vector2(0,+1), cell.walls[Cell.Wall.DOWN])
	tm.set_cellv(vec + Vector2(-1,0), cell.walls[Cell.Wall.LEFT])
	tm.set_cellv(vec + Vector2(+1,0), cell.walls[Cell.Wall.RIGHT])


## Flooding maze
func resetFlood():
	buildTiles()
	floodQueue = []
	
	
func floodPause():
	floodPause = !floodPause;
	var button = panel.get_node("MarginContainer/VBoxContainer/FloodHbox/PauseFloodButton")
	button.text = "Play Flood" if floodPause else "Pause Flood"

func floodProcess(delta):
	if !floodPause && floodQueue.size() >0:
		floodCD+=delta
	if floodCD >= speedModifier && !floodPause:
		floodQueue = floodFill(floodQueue)
		floodCD = 0;
		

func floodFill(queue):
	var q = []
	for vector in queue:
		q.append(flood(vector))
	return Utils.flat(q)


func flood(vector:Vector2):
	var tm = $TileMap
	if tm.get_cellv(vector) != 0:
		return
	tm.set_cellv(vector,2)
	var q = []
	if tm.get_cellv(vector - Vector2(1,0)) == 0:
		q.append(vector - Vector2(1,0))
	if tm.get_cellv(vector + Vector2(1,0)) == 0:
		q.append(vector + Vector2(1,0))
	if tm.get_cellv(vector - Vector2(0,1)) == 0:
		q.append(vector - Vector2(0,1))
	if tm.get_cellv(vector + Vector2(0,1)) == 0:
		q.append(vector + Vector2(0,1))
	return q
