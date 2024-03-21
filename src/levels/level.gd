extends Node2D
class_name Level

var game_over_time: float = 2.0
var score: float = 0.0
var world: int = 1

# Level stats
@export var mob_spawn_time: float = 1.0
var mob_spawn_time_decrease: float = 0.1
var mob_spawn_per_timeout: float = 1.0
var mob_spawn_per_timeout_increase: float = 0.3
@export var level_time : float = 45.0

# Enemy status
var slime_kill_exp: int = 5

@export var crystal_time_add : float = 5.0
@onready var player: Player = get_node(Globals.player_node_path)
var loot_table: LootTable

var mob_spawn_timer : Timer
var level_timer : Timer

var SLIME_MOB = load(Globals.slime_mob_scene_path)

func _ready() -> void:
  loot_table = LootTable.new()
  add_child(loot_table)
  start_level()
  
func start() -> void:
  start_level()

func start_level() -> void:
  %HUD.update_score(score)
  %HUD.update_experience(player.get_exp())
  %HUD.update_level(player.get_level())
  %HUD.update_world(world)
  create_mob_spawn_timer()
  create_level_timer()
  loot_table.randomize()
#
#func reset_level() -> void:
  #
    
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
  mob_spawn_timer.wait_time = mob_spawn_time
  mob_spawn_timer.timeout.connect(_on_spawn_mob)
  add_child(mob_spawn_timer)
  mob_spawn_timer.start()

func _on_spawn_mob() -> void:
  var mobs_to_spawn: int = int(mob_spawn_per_timeout)
  for n in mobs_to_spawn:
    var new_mob = SLIME_MOB.instantiate()
    %PathFollow2D.progress_ratio = randf()
    new_mob.global_position = %PathFollow2D.global_position
    add_child(new_mob)

func _on_main_player_player_death() -> void:
  await get_tree().create_timer(game_over_time).timeout
  get_tree().change_scene_to_file(Globals.game_over_scene_path)
  
func _on_update_player_health(health: int, max_health: int) -> void:
  %HUD.update_health(health, max_health)
  
func _on_crystal_collected() -> void:
  print("Crystal collected")
  %HUD.add_time(crystal_time_add)
  
func _on_entity_entered_gate(body: Node2D) -> void:
  if body.is_in_group("player"):
    print("entity entered gate: " + body.name)
    # update to second level
    world += 1
    %HUD.update_world(world)

func _on_enemy_death(position : Vector2) -> void:
  score += 10
  print("Enemy position: y: " + str(position.y) + " x: " + str(position.x))
  %HUD.update_score(score)
  update_experience()
  loot_table.generate_loot(position)
  
func _on_enemy_hit() -> void:
  score += 1
  %HUD.update_score(score)

func update_experience():
  player.add_experience(slime_kill_exp)
  %HUD.update_experience(player.get_exp())
  %HUD.update_level(player.get_level())
