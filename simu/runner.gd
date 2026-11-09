extends Node2D

var dragOrigin = null
var cells : Dictionary[Vector2, bool] = {}

var editorScene = preload("res://simu/editor.tscn")

var onTick : bool = false

func addAliveCell(x : int, y : int):
	cells[Vector2(x, y)] = true

func isAlive(pos : Vector2) -> bool:
	return cells.has(pos)

func neighbor(x : int, y : int):
	return [Vector2(x-1, y-1), Vector2(x-1, y), Vector2(x-1, y+1), Vector2(x, y+1), Vector2(x+1, y+1), Vector2(x+1, y), Vector2(x+1, y-1), Vector2(x, y-1)]

func getDeadNeighbor(x : int, y : int):
	var deads = []
	for n in neighbor(x, y):
		if !isAlive(n):
			deads.append(n)
	return deads

func nbAliveNeighbor(x : int, y : int) -> int:
	var nb = 0
	for n in neighbor(x, y):
		if isAlive(n):
			nb += 1
	return nb

func _ready() -> void:
	if Global.speed == 0:
		onTick = true
	else:
		$gen.wait_time = Global.speed
	cells = Global.cells
	$Camera2D.global_position = Global.camPos
	queue_redraw()

func _on_gen_timeout() -> void:
	if !onTick:
		updateGame()

func updateGame():
	var nDeadCells = []
	var newDeadCells = []
	var newAliveCells = []
	for cell in cells.keys():
		for d in getDeadNeighbor(cell.x, cell.y):
			var nb = nbAliveNeighbor(d.x, d.y)
			if nb == 3:
				newAliveCells.append(d)
		var nb = nbAliveNeighbor(cell.x, cell.y)
		if nb < 2 || nb > 3:
			newDeadCells.append(cell)
	
	for cell in newDeadCells:
		cells.erase(cell)
	for cell in newAliveCells:
		addAliveCell(cell.x, cell.y)
	
	queue_redraw()

func _process(delta: float) -> void:
	if Input.is_action_pressed("middle"):
		if dragOrigin == null:
			dragOrigin = get_global_mouse_position()
		else:
			$Camera2D.global_position -= (get_global_mouse_position() - dragOrigin)/2
			dragOrigin = get_global_mouse_position()
	if Input.is_action_just_released("middle"):
		dragOrigin = null
	if Input.is_action_just_pressed("space"):
		Global.cells = cells
		Global.camPos = $Camera2D.global_position
		get_tree().change_scene_to_packed(editorScene)
	if onTick:
		updateGame()

func _draw():
	for cell in cells.keys():
		draw_rect(Rect2(Vector2(cell.x+0.1, cell.y+0.1),Vector2(0.9, 0.9)),Color(1.0, 1.0, 1.0, 1.0)) 
