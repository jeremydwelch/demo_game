class_name Collectible
extends StaticBody2D

@export var ttl: float = 15.0
@export var warning_time: float = 5.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.play("idle")
	_start_timer(ttl - warning_time, _on_warning)


func collect() -> void:
	queue_free()


func _start_timer(wait_time: float, callback: Callable) -> void:
	var timer: Timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_time
	timer.timeout.connect(callback)
	add_child(timer)
	timer.start()


func _on_warning() -> void:
	animation_player.play("blinking")
	_start_timer(warning_time, _on_disappear)


func _on_disappear() -> void:
	queue_free()
