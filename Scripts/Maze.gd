extends Node2D
const Cell = preload("Cell.gd");
const Utils = preload("Utils.gd")

const algorithms = [
	preload("res://Scripts/Algorithms/Prim.gd"),
	preload("res://Scripts/Algorithms/DepthFirst.gd"),
	preload("res://Scripts/Algorithms/AldousBroder.gd")
]

#Ui Variables
onready var panel: Panel =  get_node("/root/Game/CanvasLayer/Divider/Panel")
onready var watchBuilding: CheckBox = panel.get_node("MarginContainer/VBoxContainer/WatchCheckBox")
onready var xSpinBox: SpinBox = panel.get_node("MarginContainer/VBoxContainer/DimensionHbox/XSpinVBox/XSpinBox")
onready var ySpinBox: SpinBox = panel.get_node("MarginContainer/VBoxContainer/DimensionHbox/YSpinVBox/YSpinBox")
onready var options: OptionButton = panel.get_node("MarginContainer/VBoxContainer/OptionButton")

# Maze variables
var height: int = 4;
var width: int = 4;
var cells: Array;
var processingMaze = false
var cellStack = []

# Flood variables
var floodQueue = []
var floodPause = false
var speedModifier = 0.5
var floodCD = speedModifier
var last


func _ready():
	width = xSpinBox.value
	height = ySpinBox.value
	var speedModifier = panel.get_node("MarginContainer/VBoxContainer/SpeedSlider").value
	for algorithm in algorithms:
		options.add_item(algorithm.name)
#	generator.call_func();
	pass


func _process(delta):
	if Input.is_action_just_pressed("mouse_click"):
		floodQueue.append($TileMap.world_to_map(get_global_mouse_position()/scale))
	floodProcess(delta)
		
	while processingMaze:
		algorithms[options.selected].process(self)
		if watchBuilding.pressed:
			buildTiles(true)
			break
	pass


## Flooding maze
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


## Maze Utils
func getCell(x,y):
	return cells[y * width +x];


func getNeighbors(x,y):
	var dummy = Cell.new()
	dummy.visit()
	return {
		Cell.Wall.UP: getCell(x,y-1) if y > 0 else dummy, 			#UP
		Cell.Wall.DOWN: getCell(x,y+1) if y < height-1 else dummy,	#DOWN
		Cell.Wall.LEFT: getCell(x-1,y) if x > 0 else dummy,			#LEFT
		Cell.Wall.RIGHT: getCell(x+1,y) if x < width-1 else dummy	#RIGHT
	}


func prepareMaze():
	
	width = xSpinBox.value
	height = ySpinBox.value
	cells = []
	var size = height*width;
	for i in range(size):
		var cell = Cell.new();
		cell.x = int(i%width);
		cell.y = int(i/width);
		cells.append(cell);
	$TileMap.clear()
	fixScale()
	last = getCell(0,0)
	

func finishGeneration():
	processingMaze = false
	buildTiles()
	options.disabled = false


func fixScale():
	var viewportSize = get_parent().rect_size
	var mazeSize = Vector2(width*2+1, height*2+1) * $TileMap.get_cell_size()
	var scaleFactor = 1
	if viewportSize.aspect() > mazeSize.aspect():
		scaleFactor = viewportSize.y/mazeSize.y
	else:
		scaleFactor = viewportSize.x/mazeSize.x
	scale = Vector2(scaleFactor,scaleFactor)


func buildTiles(building = false):
	var tm = $TileMap
	if building && cellStack.size() > 0:
		var cell = cellStack[0]
		if last:
			var lastVec = Vector2(last.x*2,last.y*2) + Vector2(+1,+1)
			tm.set_cellv(lastVec, !last.visited)
		last = cell
		var vec = Vector2(cell.x*2,cell.y*2) + Vector2(+1,+1)
		tm.set_cellv(vec, 3)
		tm.set_cellv(vec + Vector2(0,-1), cell.walls[Cell.Wall.UP])
		tm.set_cellv(vec + Vector2(0,+1), cell.walls[Cell.Wall.DOWN])
		tm.set_cellv(vec + Vector2(-1,0), cell.walls[Cell.Wall.LEFT])
		tm.set_cellv(vec + Vector2(+1,0), cell.walls[Cell.Wall.RIGHT])
		
	else:
		tm.clear()
		for x in range(-1,width*2):
			for y in range(-1,height*2):
				$TileMap.set_cell(x+1,y+1,1)
		for cell in cells:
			var vec = Vector2(cell.x*2,cell.y*2)
			tm.set_cellv(vec + Vector2(+1,+1), !cell.visited)
			tm.set_cellv(vec + Vector2(0+1,-1+1), cell.walls[Cell.Wall.UP])
			tm.set_cellv(vec + Vector2(0+1,+1+1), cell.walls[Cell.Wall.DOWN])
			tm.set_cellv(vec + Vector2(-1+1,0+1), cell.walls[Cell.Wall.LEFT])
			tm.set_cellv(vec + Vector2(+1+1,0+1), cell.walls[Cell.Wall.RIGHT])


## Connections
func _on_SpeedSlider_value_changed(value):
	speedModifier = value
	pass # Replace with function body.


func _on_GenerateButton_pressed():
	algorithms[options.selected].generate(self)
	floodQueue = []
	processingMaze = true
	options.disabled = true
	pass # Replace with function body.


func _on_PauseFloodButton_pressed():
	floodPause = !floodPause;
	var button = panel.get_node("MarginContainer/VBoxContainer/FloodHbox/PauseFloodButton")
	button.text = "Play Flood" if floodPause else "Pause Flood"
	pass # Replace with function body.


func _on_ResetFloodButton_pressed():
	buildTiles()
	floodQueue = []
	pass # Replace with function body.


func _on_XSpinBox_value_changed(value):
#	width = value
	pass # Replace with function body.


func _on_YSpinBox_value_changed(value):
#	height = value
	pass # Replace with function body.


func _on_Divider_dragged(offset):
	fixScale()
	pass # Replace with function body.
