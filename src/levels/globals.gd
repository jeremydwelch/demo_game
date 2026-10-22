class_name Globals
extends RefCounted

# Scene paths
static var level_scene_path: String = "res://src/levels/level.tscn"
static var skeleton_mob_scene_path: String = "res://src/actors/skeleton_mob.tscn"
static var wasp_mob_scene_path: String = "res://src/actors/wasp_mob.tscn"
static var blob_mob_scene_path: String = "res://src/actors/blob_mob.tscn"
static var game_over_scene_path: String = "res://src/ui/game_over.tscn"
static var heart_scene_path: String = "res://src/objects/heart.tscn"
static var crystal_scene_path: String = "res://src/objects/crystal.tscn"

# Values shared between scenes
static var score: int = 0
static var high_score: int = 0
