class_name GameOver
extends CanvasLayer

@onready var high_score_label: Label = $ColorRect/HighScore


func _ready() -> void:
	if Globals.score > Globals.high_score:
		Globals.high_score = Globals.score
	high_score_label.text = "High Score: " + str(Globals.high_score)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(Globals.level_scene_path)
