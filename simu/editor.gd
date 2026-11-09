extends Node2D

var dragOrigin = null
var cells : Dictionary[Vector2, bool] = {}

var save : bool = true

var runnerScene = load("res://simu/runner.tscn")

func addAliveCell(x : int, y : int):
	cells[Vector2(x, y)] = true

enum Library {point, glider, lightweight}
var pose : Library = Library.point

func glider(x : int, y : int):
	return [Vector2(x-1, y), Vector2(x, y), Vector2(x+1, y), Vector2(x+1, y+1), Vector2(x, y+2)]

func lightweight(x : int, y : int):
	return [Vector2(x-2, y+1), Vector2(x-2, y-1), Vector2(x-1, y-2), Vector2(x, y-2), Vector2(x+1, y-2), Vector2(x+2, y-2), Vector2(x+2, y-1), Vector2(x+2, y), Vector2(x+1, y+1)]

func addStruct(struct : Array):
	for cell in struct:
		addAliveCell(cell.x, cell.y)

func _ready() -> void:
	$CanvasLayer/sideBar/LabelSpeed.text = "wait : " + str(Global.speed)
	$CanvasLayer/sideBar/HSlider.value = Global.speed
	cells = Global.cells
	$Camera2D.global_position = Global.camPos
	pose = Library.point

func _process(delta: float) -> void:
	if !$CanvasLayer/center.visible:
		if get_global_mouse_position().x > ($Camera2D.global_position.x*10 - (get_viewport_rect().size.x/2 - get_viewport_rect().size.x/6))/10:
			if !$CanvasLayer/library.visible || $CanvasLayer/library.visible && get_global_mouse_position().x < ($Camera2D.global_position.x*10 + (get_viewport_rect().size.x/2 - get_viewport_rect().size.x/6))/10:
				if Input.is_action_pressed("leftMouse"):
					if pose == Library.point:
						addAliveCell(floor(get_global_mouse_position().x), floor(get_global_mouse_position().y))
					elif pose == Library.glider:
						addStruct(glider(floor(get_global_mouse_position().x), floor(get_global_mouse_position().y)))
					elif pose == Library.lightweight:
						addStruct(lightweight(floor(get_global_mouse_position().x), floor(get_global_mouse_position().y)))
				if Input.is_action_pressed("rightMouse"):
					cells.erase(Vector2(floor(get_global_mouse_position().x), floor(get_global_mouse_position().y)))
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
			get_tree().change_scene_to_packed(runnerScene)
	if Input.is_action_just_pressed("esc"):
		$CanvasLayer/center.visible = false
	queue_redraw()

func _draw():
	for cell in cells.keys():
		draw_rect(Rect2(Vector2(cell.x+0.1, cell.y+0.1),Vector2(0.9, 0.9)),Color(1.0, 1.0, 1.0, 1.0))

func _on_run_pressed() -> void:
	Global.cells = cells
	Global.camPos = $Camera2D.global_position
	get_tree().change_scene_to_packed(runnerScene)

func _on_noise_pressed() -> void:
	cells.clear()
	for i in range(50):
		for j in range(50):
			if randi_range(0, 1)==0:
				addAliveCell(i-25, j-25)


func _on_h_slider_drag_ended(value_changed: bool) -> void:
	$CanvasLayer/sideBar/LabelSpeed.text = "wait : " + str($CanvasLayer/sideBar/HSlider.value)
	Global.speed = $CanvasLayer/sideBar/HSlider.value

func _on_clear_pressed() -> void:
	cells.clear()

func _on_save_pressed() -> void:
	$CanvasLayer/center.visible = true
	save = true

func _on_button_confirm_pressed() -> void:
	if $CanvasLayer/center/LineEditFile.text != null:
		if save:
			var cellsString : String = ""
			for cell in cells.keys():
				cellsString += str(cell.x) + ":" + str(cell.y) + "\n"
			var file = FileAccess.open("res://save/" + $CanvasLayer/center/LineEditFile.text + ".gol", FileAccess.WRITE)
			file.store_string(cellsString)
		else:
			var file = FileAccess.open("res://save/" + $CanvasLayer/center/LineEditFile.text + ".gol", FileAccess.READ)
			if file != null:
				var content = file.get_as_text()
				for cell in content.split("\n"):
					if cell != "":
						addAliveCell(int(cell.split(":").get(0)) + floor($Camera2D.global_position.x), int(cell.split(":").get(1)) + floor($Camera2D.global_position.y))
		$CanvasLayer/center.visible = false

func _on_load_pressed() -> void:
	$CanvasLayer/center.visible = true
	save = false

func _on_library_pressed() -> void:
	if $CanvasLayer/library.visible:
		$CanvasLayer/library.visible = false
	else:
		$CanvasLayer/library.visible = true

func _on_glider_pressed() -> void:
	pose = Library.glider

func _on_lightweight_pressed() -> void:
	pose = Library.lightweight

func _on_point_pressed() -> void:
	pose = Library.point
