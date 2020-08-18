extends Node2D
const Cell = preload("Cell.gd");

#Ui Variables
onready var panel: Panel =  get_node("/root/Game/CanvasLayer/Divider/Panel")
onready var watchBuilding: CheckBox = panel.get_node("MarginContainer/VBoxContainer/WatchCheckBox")
onready var xSpinBox: SpinBox = panel.get_node("MarginContainer/VBoxContainer/DimensionHbox/XSpinVBox/XSpinBox")
onready var ySpinBox: SpinBox = panel.get_node("MarginContainer/VBoxContainer/DimensionHbox/YSpinVBox/YSpinBox")

# Maze variables
var height: int = 4;
var width: int = 4;
var cells: Array;
var dummy: Cell = Cell.new();
var generator = funcref(self, "generateDepthFirst")
var generatorProccess
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
	var options = panel.get_node("MarginContainer/VBoxContainer/OptionButton")
	options.add_item("Depth First",0)
	options.add_item("Adous-Broder",1)
	options.add_item("Simple Prim",2)
#	generator.call_func();
	pass


func _process(delta):
	if Input.is_action_just_pressed("mouse_click"):
		floodQueue.append($TileMap.world_to_map(get_global_mouse_position()/scale))
	floodProcess(delta)
	if processingMaze:
		generatorProccess.call_func();
	while !watchBuilding.pressed && processingMaze:
		generatorProccess.call_func();
	pass


## Depth First
func generateDepthFirst():
	prepareMaze()
	var x = 0;
	var y = 0;
	cellStack = []
	var cell = getCell(x,y)
	cell.visit()
	cellStack.push_back(cell)
	processingMaze = true
	generatorProccess = funcref(self, "processDepthFirst")
	
	
func processDepthFirst():
	if cellStack.size() > 0:
		var found = false
		var cell = cellStack.pop_front()
		var neiDict = getNeighbors(cell.x,cell.y)
		var neiKeys = shuffle(neiDict.keys())
		for dir in neiKeys:
			if !neiDict[dir].visited:
				cellStack.push_front(cell)
				neiDict[dir].setWall(Cell.oppositeWall(dir),false);
				cell.setWall(dir,false)
				neiDict[dir].visit()
				cellStack.push_front(neiDict[dir])
				found = true
				break
		if !found:
			processDepthFirst()
	else:
		processingMaze = false
		buildTiles()
	if watchBuilding.pressed:
		buildTiles(true)


## Aldous-Broder
func generateAldousBroder():
	prepareMaze()
	cellStack = []
	var cell = getCell(0,0)
	cell.visit()
	cellStack.push_front(cell)
	processingMaze = true
	generatorProccess = funcref(self, "processAldousBroder")
	

func processAldousBroder():
	if cellStack.size() < cells.size():
		var cell = cellStack[0]
		var neiDict = getNeighbors(cell.x,cell.y)
		var neiKeys = shuffle(neiDict.keys())
		for dir in neiKeys:
			if neiDict[dir] != dummy:
				if !neiDict[dir].visited:
					neiDict[dir].setWall(Cell.oppositeWall(dir),false)
					cell.setWall(dir,false)
					neiDict[dir].visit()
					cellStack.push_front(neiDict[dir])
				else:
					cellStack.erase(neiDict[dir])
					cellStack.push_front(neiDict[dir])
				break;
		if watchBuilding.pressed:
			buildTiles(true)
	else:
		buildTiles()
		processingMaze = false


## Prim
func generatePrim():
	prepareMaze()
	cellStack = []
	var cell = getCell(0,0)
	cell.visit()
	cellStack.push_front(cell)
	processingMaze = true
	generatorProccess = funcref(self, "processPrim")
	pass
	

func processPrim():
	if cellStack.size() > 0:
		cellStack = shuffle(cellStack)
		var cell = cellStack.pop_front()
		var neiDict = getNeighbors(cell.x,cell.y)
		var neiKeys = shuffle(neiDict.keys())
		for dir in neiKeys:
			if !neiDict[dir].visited:
				neiDict[dir].setWall(Cell.oppositeWall(dir),false);
				cell.setWall(dir,false)
				neiDict[dir].visit()
				cellStack.push_front(neiDict[dir])
				cellStack.push_front(cell)
				break
		if watchBuilding.pressed:
			buildTiles(true)
	else:
		buildTiles()
		processingMaze = false
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
	return flat(q)


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
	return {
		Cell.Wall.UP: getCell(x,y-1) if y > 0 else dummy, 			#UP
		Cell.Wall.DOWN: getCell(x,y+1) if y < height-1 else dummy,	#DOWN
		Cell.Wall.LEFT: getCell(x-1,y) if x > 0 else dummy,			#LEFT
		Cell.Wall.RIGHT: getCell(x+1,y) if x < width-1 else dummy	#RIGHT
	}


func prepareMaze():
	width = xSpinBox.value
	height = ySpinBox.value
	dummy.visit();
	cells = []
	var size = height*width;
	for i in range(size):
		var cell = Cell.new();
		cell.x = int(i%width);
		cell.y = int(i/width);
		cells.append(cell);
	$TileMap.clear()
	last = getCell(0,0)


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
	fixScale()
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


## Easy of life stuff
func flat(arr):
	var flat_list = []
	for sublist in arr:
		if sublist:
			for item in sublist:
				flat_list.append(item)
	return flat_list

func shuffle(arr):
	var shuffled = arr.duplicate()
	shuffled.shuffle()
	var sampled = []
	for i in range(arr.size()):
		sampled.append( shuffled.pop_front() )
	return sampled


## Connections
func _on_SpeedSlider_value_changed(value):
	speedModifier = value
	pass # Replace with function body.


func _on_OptionButton_item_selected(index):
	match(index):
		0:
			generator = funcref(self, "generateDepthFirst")
		1:
			generator = funcref(self, "generateAldousBroder")
		2:
			generator = funcref(self, "generatePrim")
		_:
			generator = funcref(self, "generateDepthFirst")
	pass # Replace with function body.


func _on_GenerateButton_pressed():
	generator.call_func();
	floodQueue = []
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
