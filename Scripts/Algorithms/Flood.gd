class_name Flood
const Utils = preload("res://Scripts/Utils.gd")

## Flooding maze

# Flood variables
var floodQueue = []
var floodPause = false
var maxCD = 100
var CD = 0

func resetFlood(maze):
	maze.buildTiles()
	floodQueue = []


func floodPause():
	floodPause = !floodPause;


func floodProcess(delta, maze):
	if Input.is_action_just_pressed("mouse_click") && !maze.generatingMaze:
		var cell = maze.get_node("TileMap").world_to_map(maze.get_global_mouse_position()/maze.scale)
		if maze.get_node("TileMap").get_cellv(cell) == Utils.TileColor.WHITE:
			floodQueue.append(cell)
		
	if !floodPause && !floodQueue.empty():
		if CD <= 0:
			floodQueue = floodFill(floodQueue, maze)
			CD += maxCD*delta
		else:
			var speed = maze.panel.floodSlider.value
			CD -= (speed*delta)
	


func floodFill(queue, maze):
	var nextQueue = []
	for vector in queue:
		var vectorQueue = flood(vector, maze)
		for next in vectorQueue:
			nextQueue.append(next)
	return nextQueue


func flood(vector:Vector2, maze):
	var tm = maze.get_node('TileMap')
	if tm.get_cellv(vector) != Utils.TileColor.WHITE:
		return []
	tm.set_cellv(vector,Utils.TileColor.BLUE)
	var q = []
	if tm.get_cellv(vector - Vector2(1,0)) == Utils.TileColor.WHITE:
		q.append(vector - Vector2(1,0))
	if tm.get_cellv(vector + Vector2(1,0)) == Utils.TileColor.WHITE:
		q.append(vector + Vector2(1,0))
	if tm.get_cellv(vector - Vector2(0,1)) == Utils.TileColor.WHITE:
		q.append(vector - Vector2(0,1))
	if tm.get_cellv(vector + Vector2(0,1)) == Utils.TileColor.WHITE:
		q.append(vector + Vector2(0,1))
	return q
