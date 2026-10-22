extends Control

const WORLD_TRANSITION_SCENE: PackedScene = preload("res://src/ui/world_transition.tscn")


func _on_button_pressed() -> void:
	var transition: WorldTransition = WORLD_TRANSITION_SCENE.instantiate()
	add_child(transition)
	transition.transition_to(Globals.level_scene_path)
