extends CharacterBody2D

@export var speed : float = 10
@export var knockback_speed : float = 100
@export var health : int = 3

@onready var player : CharacterBody2D = get_node("/root/demo_level/main_player")
@onready var level : Node2D = get_node("/root/demo_level")
var slime: Node2D
var smokeScene : Resource
var is_knockback : bool
var knockback_direction : Vector2

signal enemy_health_update
signal enemy_death(position : Vector2)

func _ready():
  is_knockback = false
  %Slime.play_walk()
  enemy_health_update.connect(level._on_enemy_hit)
  enemy_death.connect(level._on_enemy_death)
  #level._on_enemy_death.connect(enemy_death)

func _physics_process(delta):
  if !is_knockback:
    var direction = global_position.direction_to(player.global_position).normalized()
    velocity = direction * speed
  else:
    velocity = knockback_direction * knockback_speed
  move_and_collide(velocity * delta)

func take_damage(direction: Vector2):
  knockback_direction = direction
  %Slime.play_hurt()
  health -= 1
  enemy_health_update.emit()
  is_knockback = true
  %Timer.start(0.1)

  if (health < 1):
    enemy_death.emit(global_position)
    queue_free()
    const SMOKE_SCENE = preload("res://src/actors/smoke_explosion.tscn")
    var smoke = SMOKE_SCENE.instantiate()
    get_parent().add_child(smoke)
    smoke.global_position = global_position
    smoke.global_scale = %Slime.global_scale

func _on_timer_timeout() -> void:
  is_knockback = false
