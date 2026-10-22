class_name Level
extends Node2D

const GAME_OVER_DELAY: float = 2.0

@export var spawn_mobs: bool = true
@export var mob_spawn_time: float = 1.0
@export var mob_spawn_time_decrease: float = 0.1
@export var min_mob_spawn_time: float = 0.25
@export var mob_spawn_per_timeout: float = 1.0
@export var mob_spawn_per_timeout_increase: float = 0.5
@export var level_time: float = 45.0
@export var world_level: int = 1

@export var crystal_collect_exp: int = 75
@export var num_mobs: int = 3

var score: int = 0
var loot_table: LootTable
var mob_spawn_timer: Timer
var level_timer: Timer
var _mob_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _skeleton_mob_scene: PackedScene = load(Globals.skeleton_mob_scene_path)
var _wasp_mob_scene: PackedScene = load(Globals.wasp_mob_scene_path)
var _blob_mob_scene: PackedScene = load(Globals.blob_mob_scene_path)

@onready var player: Player = $main_player
@onready var stats: Stats = $Stats
@onready var hud: Hud = %HUD
@onready var path_follow: PathFollow2D = %PathFollow2D


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	new_player_stats(0, 0, 0, 0)
	loot_table = LootTable.new()
	add_child(loot_table)
	_start_level()


func player_level_up() -> void:
	stats.add_stat_points(player.get_level_up_stat_points_gained())
	stats.pause()


func new_player_stats(health: int, damage: int, speed: int, toughness: int) -> void:
	player.set_max_health_modifier(health)
	player.set_damage_modifier(damage)
	player.set_speed_modifier(speed)
	player.set_toughness_modifier(toughness)


func _start_level() -> void:
	hud.update_score(score)
	_update_experience_display()
	hud.update_world(world_level)

	level_timer = Timer.new()
	level_timer.wait_time = level_time
	level_timer.timeout.connect(_on_world_level_increase)
	add_child(level_timer)
	level_timer.start()

	if spawn_mobs:
		mob_spawn_timer = Timer.new()
		mob_spawn_timer.wait_time = mob_spawn_time
		mob_spawn_timer.timeout.connect(_on_spawn_mob)
		add_child(mob_spawn_timer)
		mob_spawn_timer.start()


func _spawn_mob() -> void:
	# TODO: Replace with a weighted, data-driven mob table.
	var rand: float = _mob_rng.randf_range(0.0, num_mobs + 1)
	var new_mob: Mob
	if rand < 1:
		new_mob = _blob_mob_scene.instantiate()
	elif rand < 2:
		new_mob = _wasp_mob_scene.instantiate()
	else:
		new_mob = _skeleton_mob_scene.instantiate()
	path_follow.progress_ratio = _mob_rng.randf()
	new_mob.global_position = path_follow.global_position
	new_mob.set_level(world_level)
	new_mob.target = player
	new_mob.enemy_health_update.connect(_on_enemy_hit)
	new_mob.enemy_death.connect(_on_enemy_death)
	add_child(new_mob)


func _add_experience(amount: int) -> void:
	player.add_experience(amount)
	_update_experience_display()


func _update_experience_display() -> void:
	hud.update_experience(player.get_exp(), player.get_exp_to_next_level())
	hud.update_level(player.get_level())


func _on_spawn_mob() -> void:
	for i in int(mob_spawn_per_timeout):
		_spawn_mob()


func _on_world_level_increase() -> void:
	world_level += 1
	hud.update_world(world_level)
	mob_spawn_per_timeout += mob_spawn_per_timeout_increase
	mob_spawn_time = maxf(mob_spawn_time - mob_spawn_time_decrease, min_mob_spawn_time)
	if mob_spawn_timer:
		mob_spawn_timer.wait_time = mob_spawn_time


func _on_main_player_player_death() -> void:
	Globals.score = score
	await get_tree().create_timer(GAME_OVER_DELAY).timeout
	# The stats/pause menu may have been opened during the death delay.
	get_tree().paused = false
	get_tree().change_scene_to_file(Globals.game_over_scene_path)


func _on_update_player_health(health: float, max_health: float) -> void:
	# The player emits this from its own _ready, before our @onready vars are set.
	# _ready calls new_player_stats, which emits it again once the HUD is available.
	if not is_node_ready():
		return
	hud.update_health(health, max_health)


func _on_crystal_collected() -> void:
	_add_experience(crystal_collect_exp)


func _on_enemy_death(death_position: Vector2, kill_exp: int) -> void:
	score += 10
	hud.update_score(score)
	_add_experience(kill_exp)
	loot_table.generate_loot(death_position)


func _on_enemy_hit() -> void:
	score += 1
	hud.update_score(score)


func _on_music_finished() -> void:
	$Music.play()
