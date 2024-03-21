extends Control

#@onready var next_scene : PackedScene = preload("res://src/levels/demo_level.tscn")
@onready var _transition_rect : PackedScene = preload("res://src/ui/world_transition.tscn")

func _on_button_pressed() -> void:
  var transition = _transition_rect.instantiate()
  add_child(transition)
  transition.transition_to(Globals.level_scene_path)
  #get_tree().change_scene_to_packed(next_scene)
