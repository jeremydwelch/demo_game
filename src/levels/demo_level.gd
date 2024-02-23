extends Node2D

var game_over_time : float = 2.0
var score : float = 0.0
var level : int = 1
var exp : int = 0

@export var wait_time : float = 1.0
@export var level_time : float = 70.0
@export var repair_kit_drop_rate : float = 10.0
@export var health_drop_rate : float = 15.0

var mob_spawn_timer : Timer
var level_timer : Timer
  
func _ready() -> void:
  %HUD.update_score(score)
  %HUD.update_experience(exp)
  %HUD.update_level(level)
  create_mob_spawn_timer()
  create_level_timer()
  
func create_level_timer() -> void: 
  level_timer = Timer.new()
  level_timer.wait_time = level_time
  level_timer.one_shot = true
  level_timer.timeout.connect(_on_main_player_player_death)
  add_child(level_timer)
  %HUD.set_timer_node(level_timer)
  level_timer.start()
  
func create_mob_spawn_timer() -> void:
  mob_spawn_timer = Timer.new()
  mob_spawn_timer.wait_time = wait_time
  mob_spawn_timer.timeout.connect(_on_spawn_mob)
  add_child(mob_spawn_timer)
  mob_spawn_timer.start()

func _on_spawn_mob() -> void:
  const SLIME_MOB = preload("res://src/actors/slime_mob.tscn")
  var new_mob = SLIME_MOB.instantiate()
  %PathFollow2D.progress_ratio = randf()
  new_mob.global_position = %PathFollow2D.global_position
  add_child(new_mob)

func _on_main_player_player_death() -> void:
  await get_tree().create_timer(game_over_time).timeout
  get_tree().change_scene_to_file("res://src/ui/game_over.tscn")
  
func _on_update_player_health(health: int, max_health: int) -> void:
  %HUD.update_health(health, max_health)

func _on_enemy_death(position : Vector2) -> void:
  score += 10
  print("Enemy position: y: " + str(position.y) + " x: " + str(position.x))
  %HUD.update_score(score)
  update_experience()
  
func _on_enemy_hit() -> void:
  score += 1
  %HUD.update_score(score)

func update_experience():
  exp += 5 
  if exp > 100:
    exp = 0
    level += 1
    %HUD.update_level(level)
  %HUD.update_experience(exp)
