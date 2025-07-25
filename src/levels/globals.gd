extends Node

class_name Globals

# Node Paths
static var level_node_path: String = "/root/level"
static var player_node_path: String = "/root/level/main_player"
static var stats_node_path: String = "/root/level/Stats"

# Scene Paths
static var level_scene_path: String = "res://src/levels/level.tscn"
static var slime_mob_scene_path: String = "res://src/actors/slime_mob.tscn"
static var skeleton_mob_scene_path: String = "res://src/actors/skeleton_mob.tscn"
static var wasp_mob_scene_path: String = "res://src/actors/wasp_mob.tscn"
static var blob_mob_scene_path: String = "res://src/actors/blob_mob.tscn"
static var game_over_scene_path: String = "res://src/ui/game_over.tscn"
static var heart_scene_path: String = "res://src/objects/heart.tscn"
static var crystal_scene_path: String = "res://src/objects/crystal.tscn"


# Global Variables Between Scenes
static var score: int
static var high_score: int
