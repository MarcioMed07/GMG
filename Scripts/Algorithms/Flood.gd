class_name Flood
const Utils = preload("res://Scripts/Utils.gd")

## Flooding maze

# Flood variables
var floodQueue = []
var floodPause = false
var speedModifier = 0.5
var floodCD = speedModifier

func resetFlood(maze):
	maze.buildTiles()
	floodQueue = []


func floodPause():
	floodPause = !floodPause;


func floodProcess(delta, maze):
	if Input.is_action_just_pressed("mouse_click") && !maze.generatingMaze:
		floodQueue.append(maze.get_node("TileMap").world_to_map(maze.get_global_mouse_position()/maze.scale))
	if !floodPause && floodQueue.size() >0:
		floodCD+=delta
	if floodCD >= speedModifier && !floodPause:
		floodQueue = floodFill(floodQueue, maze)
		floodCD = 0;
		

func floodFill(queue, maze):
	var q = []
	for vector in queue:
		q.append(flood(vector, maze))
	return Utils.flat(q)


func flood(vector:Vector2, maze):
	var tm = maze.get_node('TileMap')
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
