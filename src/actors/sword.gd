extends Area2D

@onready var player : CharacterBody2D = get_node(Globals.player_node_path)

func _on_body_entered(body: Node2D) -> void:
  if body.has_method("take_damage"):
    var direction: Vector2 = (body.global_position - get_parent().global_position).normalized()
    body.take_damage(direction, player.get_damage())
