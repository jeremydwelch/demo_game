extends Node2D

@onready var player : CharacterBody2D = get_node("/root/demo_level/main_player")
@onready var game_over_screen : PackedScene = preload("res://src/ui/game_over.tscn")

var game_over_time : float = 2.0
  
func spawn_mob() -> void:
  const SLIME_MOB = preload("res://src/actors/slime_mob.tscn")
  var new_mob = SLIME_MOB.instantiate()
  %PathFollow2D.progress_ratio = randf()
  new_mob.global_position = %PathFollow2D.global_position
  add_child(new_mob)

func _on_main_player_player_death() -> void:
  await get_tree().create_timer(game_over_time).timeout
  get_tree().change_scene_to_packed(game_over_screen)
  
