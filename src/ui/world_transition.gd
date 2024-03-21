extends ColorRect


# Path to the next scene to transition to
@export var next_scene_path : String = "*.tscn"

# Reference to the _AnimationPlayer_ node
@onready var _anim_player := $AnimationPlayer

func _ready() -> void:
  # Plays the animation backward to fade in
  print("Playing fade backwards")
  _anim_player.play_backwards("fade")


func transition_to(next_scene : String = next_scene_path) -> void:
  # Plays the Fade animation and wait until it finishes
  print("Playing fade forwards")
  _anim_player.play("fade")
  await _anim_player.animation_finished
  # Changes the scene
  print("next scene: " + next_scene)
  get_tree().change_scene_to_file(next_scene)
