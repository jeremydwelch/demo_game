extends Area2D

func _on_body_entered(body: Node2D) -> void:
  if body.has_method("take_damage"):
    var direction: Vector2 = (body.global_position - get_parent().global_position).normalized()
    body.take_damage(direction)
