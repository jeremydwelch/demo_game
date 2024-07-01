extends Node2D
class_name Level

var game_over_time: float = 2.0
var score: float = 0.0

# Level stats
@export var spawn_mobs: bool = true
@export var mob_spawn_time: float = 1.0
@export var mob_spawn_time_decrease: float = 0.1
@export var mob_spawn_per_timeout: float = 1.0
@export var mob_spawn_per_timeout_increase: float = 0.5
@export var level_time : float = 30.0
@export var world_level: int = 1

# Enemy status
@export var slime_kill_exp: int = 1
@export var crystal_collect_exp: int = 100


@onready var player: Player = get_node(Globals.player_node_path)
var loot_table: LootTable

var mob_spawn_timer : Timer
var level_timer : Timer

var SLIME_MOB: PackedScene = load(Globals.slime_mob_scene_path)

func _ready() -> void:
  new_player_stats(player.get_max_health(), 0, 0, 0)
  process_mode = Node.PROCESS_MODE_PAUSABLE
  loot_table = LootTable.new()
  add_child(loot_table)
  start_level()
  
func start() -> void:
  start_level()
  
func start_level() -> void:
  %HUD.update_score(score)
  %HUD.update_experience(player.get_exp())
  %HUD.update_level(player.get_level())
  %HUD.update_world(world_level)
  if spawn_mobs: 
    create_mob_spawn_timer(mob_spawn_time)
  loot_table.randomize()
  create_level_timer(level_time)

func reset_level() -> void:
  # Reset player position
  player.global_position = Vector2(0, 0)
  level_timer.stop()
  level_timer.start(level_time)
  for n in get_children():
    if n.is_in_group("slime"):
        n.queue_free()
    if n.is_in_group("crystal"):
      n.queue_free()
    if n.is_in_group("heart"):
      n.queue_free()
   
  if spawn_mobs:
    mob_spawn_timer.free()
    mob_spawn_per_timeout += mob_spawn_per_timeout_increase
    mob_spawn_time -= mob_spawn_time_decrease
    create_mob_spawn_timer(mob_spawn_time)

   
func create_level_timer(time: float) -> void: 
  level_timer = Timer.new()
  level_timer.wait_time = time
  level_timer.one_shot = true
  level_timer.timeout.connect(_on_world_level_increase)
  add_child(level_timer)
  level_timer.start()
  
func create_mob_spawn_timer(spawn_time: float) -> void:
  mob_spawn_timer = Timer.new()
  mob_spawn_timer.wait_time = spawn_time
  mob_spawn_timer.timeout.connect(_on_spawn_mob)
  add_child(mob_spawn_timer)
  mob_spawn_timer.start()

func _on_spawn_mob() -> void:
  var mobs_to_spawn: int = int(mob_spawn_per_timeout)
    
  for n in mobs_to_spawn:
    # TODO choose mob type
    var new_mob: Slime = SLIME_MOB.instantiate()
    %PathFollow2D.progress_ratio = randf()
    new_mob.global_position = %PathFollow2D.global_position
    new_mob.set_level(world_level)
    add_child(new_mob)

func _on_world_level_increase() -> void:
  print("world level increased")
  world_level += 1
  %HUD.update_world(world_level)
  create_level_timer(level_time)
      
  mob_spawn_per_timeout += mob_spawn_per_timeout_increase
  mob_spawn_time -= mob_spawn_time_decrease
  

func _on_main_player_player_death() -> void:
  Globals.score = score
  await get_tree().create_timer(game_over_time).timeout
  get_tree().change_scene_to_file(Globals.game_over_scene_path)
  
func _on_update_player_health(health: int, max_health: int) -> void:
  %HUD.update_health(health, max_health)
  
func _on_crystal_collected() -> void:
  print("Crystal collected")
  update_experience(crystal_collect_exp)
  
#func _on_entity_entered_gate(body: Node2D) -> void:
  #print("entity entered gate: " + body.name + " parent: " + body.get_parent().name)
  #if body.get_parent().is_in_group("player"):
    #print("entity entered gate: " + body.name)
    ## update to second level
    #world += 1
    #score += 5
    #%HUD.update_world(world)
    #%HUD.update_score(score)
    #reset_level()

func _on_enemy_death(position : Vector2) -> void:
  score += 10
  print("Enemy position: y: " + str(position.y) + " x: " + str(position.x))
  %HUD.update_score(score)
  update_experience(slime_kill_exp)
  loot_table.generate_loot(position)
  
func _on_enemy_hit() -> void:
  score += 1
  %HUD.update_score(score)

func update_experience(exp: int):
  player.add_experience(exp)
  %HUD.update_experience(player.get_exp())
  %HUD.update_level(player.get_level())

func _on_music_finished() -> void:
  print("restarting music")
  $Music.play()

func player_level_up() -> void:
  $Stats.set_stat_points_to_spend(1)
  $Stats.pause()
  
func toggle_paused() -> void:
  print("toggled pause")

func new_player_stats(health :int, damage :int, speed :int, toughness :int) -> void:
  player.set_max_health(health)
  player.set_damage_modifier(damage)
  player.set_speed_modifier(speed)
  player.set_toughness_modifier(toughness)
  
