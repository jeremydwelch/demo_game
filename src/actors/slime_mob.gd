extends CharacterBody2D

@export var speed : float = 50
@export var knockback_speed : float = 200
@export var health : int = 3

@onready var player : CharacterBody2D = get_node("/root/demo_level/main_player")
var slime: Node2D
var smokeScene : Resource
var is_knockback : bool
var knockback_direction : Vector2

func _ready():
  is_knockback = false
  %Slime.play_walk()

func _physics_process(delta):
  if !is_knockback:
    var direction = global_position.direction_to(player.global_position);
    velocity = direction * speed
  else:
    velocity = knockback_direction * knockback_speed
  move_and_collide(velocity * delta)

func take_damage(direction: Vector2):
  knockback_direction = direction
  %Slime.play_hurt()
  health -= 1
  is_knockback = true
  %Timer.start(0.1)

  if (health < 1):
    queue_free()
    const SMOKE_SCENE = preload("res://src/actors/smoke_explosion.tscn")
    var smoke = SMOKE_SCENE.instantiate()
    get_parent().add_child(smoke)
    smoke.global_position = global_position
    smoke.global_scale = %Slime.global_scale

func _on_timer_timeout() -> void:
  is_knockback = false
