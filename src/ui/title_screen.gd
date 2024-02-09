extends Control

@onready var next_scene : PackedScene = preload("res://src/levels/demo_level.tscn")

func _on_button_pressed() -> void:
  get_tree().change_scene_to_packed(next_scene)
