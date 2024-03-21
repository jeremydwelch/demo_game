extends Node2D

@onready var level: PackedScene = load("res://src/levels/level.tscn")
@onready var game_over :PackedScene = preload("res://src/ui/game_over.tscn")

func _ready() -> void:
  return

func change_to_level() -> void:
  var scene = level.instantiate()
  add_child(scene)
  scene.start()
  
  return

func change_to_game_over() -> void:
  var scene = game_over.instantiate()
  add_child(scene)
  return
  
func reset_level() -> void:
  return
