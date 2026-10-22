extends Area2D

@onready var player: Player = get_parent()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		var direction: Vector2 = player.global_position.direction_to(body.global_position)
		body.take_damage(direction, player.get_damage())
