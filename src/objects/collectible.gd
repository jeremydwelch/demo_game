extends StaticBody2D
class_name Collectible

@export var ttl : float = 15.0
@export var warning_time : float = 5.0
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
  $Hurtbox.area_entered.connect(_on_hurtbox_body_entered)
  animation_player.play("idle")
  var timer = Timer.new()
  timer.one_shot = true
  timer.wait_time = ttl - warning_time
  timer.timeout.connect(_on_warning)
  add_child(timer)
  timer.start()

func _on_warning() -> void:
  animation_player.play("blinking")
  var timer = Timer.new()
  timer.one_shot = true
  timer.wait_time = warning_time
  timer.timeout.connect(_on_disappear)
  add_child(timer)
  timer.start()
  
func _on_disappear() -> void:
  queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
  _on_disappear()
