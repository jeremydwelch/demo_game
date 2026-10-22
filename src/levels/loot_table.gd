class_name LootTable
extends Node

const LOOT_ROLL_MAX: float = 1000.0

var heart_drop_rate: float = 100.0
var crystal_drop_rate: float = 300.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _heart_scene: PackedScene = load(Globals.heart_scene_path)
var _crystal_scene: PackedScene = load(Globals.crystal_scene_path)


func generate_loot(drop_position: Vector2) -> void:
	var roll: float = _rng.randf_range(0.0, LOOT_ROLL_MAX)
	if roll < heart_drop_rate:
		_drop(_heart_scene, drop_position)
	elif roll < heart_drop_rate + crystal_drop_rate:
		_drop(_crystal_scene, drop_position)


func _drop(scene: PackedScene, drop_position: Vector2) -> void:
	var loot: Node2D = scene.instantiate()
	add_child(loot)
	loot.global_position = drop_position
