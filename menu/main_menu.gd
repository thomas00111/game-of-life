extends Control

var runnerScene = preload("res://simu/runner.tscn")
var editorScene = preload("res://simu/editor.tscn")

func _on_run_pressed() -> void:
	get_tree().change_scene_to_packed(runnerScene)

func _on_editor_pressed() -> void:
	get_tree().change_scene_to_packed(editorScene)
