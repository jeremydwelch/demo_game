extends CanvasLayer
class_name GameOver

@onready var next_scene : PackedScene = preload("res://src/levels/level.tscn")

func _ready() -> void:
  if Globals.score > Globals.high_score:
    Globals.high_score = Globals.score
  $ColorRect/HighScore.text = "High Score: " + str(Globals.high_score)

func _on_button_pressed() -> void:
  get_tree().change_scene_to_packed(next_scene)
