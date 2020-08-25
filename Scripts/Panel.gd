extends Panel
var Maze = load('res://Scenes/Maze.tscn')

onready var maze: Maze = get_node("/root/Game/CanvasLayer/Divider/ViewportContainer/Viewport/Maze")
onready var divider: HSplitContainer = get_node("/root/Game/CanvasLayer/Divider")

onready var algorithmOptions: OptionButton = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/AlgorithmOptions")
onready var xSpin: SpinBox = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/DimensionHbox/XSpinVBox/XSpinBox")
onready var ySpin: SpinBox = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/DimensionHbox/YSpinVBox/YSpinBox")
onready var stepButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/StepButton")
onready var runStopButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/RunStopButton")
onready var completeButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/CompleteButton")
onready var resetButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/ResetButton")

onready var floodContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/FloodContainer")
onready var pauseFloodButton: Button = get_node("MarginContainer/VBoxContainer/FloodContainer/FloodControls/FloodHbox/PauseFloodButton")
onready var resetFloodButton: Button = get_node("MarginContainer/VBoxContainer/FloodContainer/FloodControls/FloodHbox/ResetFloodButton")
onready var floodSlider: HSlider = get_node("MarginContainer/VBoxContainer/FloodContainer/FloodControls/SpeedSlider")

onready var playerContainer: VBoxContainer = get_node("MarginContainer/VBoxContainer/PlayerContainer")
onready var playerButton: Button = get_node("MarginContainer/VBoxContainer/PlayerContainer/PlayerButton")

var step = false
var runStop = false
var complete = false

func _ready():
	for algorithm in maze.algorithms:
		algorithmOptions.add_item(algorithm.name)
	pass


func _process(delta):
	floodContainer.visible = !maze.generatingMaze
	playerContainer.visible = maze.completeMaze

func startGeneration():
	if maze.has_node("2dPlayer"):
		playerButton.text = "Create Player"
		maze.get_node("2dPlayer").queue_free()
	maze.startGeneration()


func finishGeneration():
	runStopButton.disabled = false
	runStop = false
	runStopButton.pressed = false
	stepButton.disabled = false
	algorithmOptions.disabled = false
	xSpin.editable = true
	ySpin.editable = true


func _on_Divider_dragged(offset):
	maze.fixScale()


func _on_StepButton_pressed():
	step = true
	algorithmOptions.disabled = true
	xSpin.editable = false
	ySpin.editable = false
	if !maze.generatingMaze:
		startGeneration()


func _on_RunStopButton_toggled(button_pressed):
	runStop = button_pressed
	runStopButton.text = "Stop" if button_pressed else "Run"
	algorithmOptions.disabled = true
	xSpin.editable = false
	ySpin.editable = false
	stepButton.disabled = button_pressed
	if !maze.generatingMaze && runStop:
		startGeneration()


func _on_CompleteButton_pressed():
	complete = true
	algorithmOptions.disabled = true
	xSpin.editable = false
	ySpin.editable = false
	runStopButton.disabled = true
	runStop = false
	runStopButton.pressed = false
	runStopButton.text = "Run"
	stepButton.disabled = true
	if !maze.generatingMaze:
		startGeneration()


func _on_ResetButton_pressed():
	maze.prepareMaze()
	maze.finishGeneration(false)


func _on_PauseFloodButton_pressed():
	maze.flood.floodPause()
	pauseFloodButton.text = "Pause Flood" if !maze.flood.floodPause else "Resume Flood"


func _on_ResetFloodButton_pressed():
	maze.flood.resetFlood(maze)


func _on_PlayerButton_pressed():
	_on_ResetFloodButton_pressed()
	if maze.has_node("2dPlayer"):
		playerButton.text = "Create Player"
		maze.get_node("2dPlayer").queue_free()
	else:
		playerButton.text = "Kill Player"
		var player = preload("res://Scenes/2dPlayer.tscn").instance()
		player.position = maze.get_node("TileMap").map_to_world(Vector2(1,1)) + Vector2(5,5)
		maze.add_child(player)
	pass # Replace with function body.

