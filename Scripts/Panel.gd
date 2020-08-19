extends Panel
var Maze = load('res://Scenes/Maze.tscn')

onready var maze: Maze = get_node("/root/Game/CanvasLayer/Divider/ViewportContainer/Maze")

onready var algorithmOptions: OptionButton = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/AlgorithmOptions")
onready var xSpin: SpinBox = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/DimensionHbox/XSpinVBox/XSpinBox")
onready var ySpin: SpinBox = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/DimensionHbox/YSpinVBox/YSpinBox")
onready var stepButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/StepButton")
onready var runStopButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/RunStopButton")
onready var completeButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/CompleteButton")
onready var resetButton: Button = get_node("MarginContainer/VBoxContainer/AlgorithmContainer/HBoxContainer/ResetButton")

var step = false
var runStop = false
var complete = false

func _ready():
	for algorithm in maze.algorithms:
		algorithmOptions.add_item(algorithm.name)
	pass

func startGeneration():
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
	pass # Replace with function body.


func _on_StepButton_pressed():
	step = true
	algorithmOptions.disabled = true
	xSpin.editable = false
	ySpin.editable = false
	if !maze.generatingMaze:
		startGeneration()
	pass # Replace with function body.


func _on_RunStopButton_toggled(button_pressed):
	runStop = button_pressed
	runStopButton.text = "Stop" if button_pressed else "Run"
	algorithmOptions.disabled = true
	xSpin.editable = false
	ySpin.editable = false
	stepButton.disabled = button_pressed
	if !maze.generatingMaze && runStop:
		startGeneration()
	pass # Replace with function body.


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
	pass # Replace with function body.


func _on_ResetButton_pressed():
	maze.prepareMaze()
	maze.finishGeneration()
	pass # Replace with function body.
