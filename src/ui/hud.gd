class_name Hud
extends CanvasLayer

@onready var score_label: Label = $NinePatchRect/Score
@onready var health_bar: ProgressBar = $NinePatchRect/Health
@onready var experience_bar: ProgressBar = $NinePatchRect/Experience
@onready var level_label: Label = $NinePatchRect/Level
@onready var world_label: Label = $NinePatchRect/World


func update_score(score: int) -> void:
	score_label.text = "Score: " + str(score)


func update_health(health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = health


func update_experience(value: int, max_value: int) -> void:
	experience_bar.max_value = max_value
	experience_bar.value = value


func update_level(level: int) -> void:
	level_label.text = "Level: " + str(level)


func update_world(world: int) -> void:
	world_label.text = "World: " + str(world)
