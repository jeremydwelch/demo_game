extends CanvasLayer

@onready var next_scene : PackedScene = preload("res://src/levels/level.tscn")

func _on_button_pressed() -> void:
  get_tree().change_scene_to_packed(next_scene)
