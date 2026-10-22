class_name WorldTransition
extends ColorRect

## Path to the scene to change to when transition_to() is called without an argument.
@export_file("*.tscn") var next_scene_path: String = ""

@onready var _anim_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# Play the fade backwards to fade in.
	_anim_player.play_backwards("fade")


func transition_to(next_scene: String = next_scene_path) -> void:
	_anim_player.play("fade")
	await _anim_player.animation_finished
	get_tree().change_scene_to_file(next_scene)
