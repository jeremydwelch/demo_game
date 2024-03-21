extends CharacterBody2D

@export var speed : float = 10
@export var knockback_speed : float = 250
@export var health : float = 3.0
@export var damage: float = 1.0

@onready var player : CharacterBody2D = get_node(Globals.player_node_path)
@onready var level : Node2D = get_node(Globals.level_node_path)
var slime: Node2D
var smokeScene : Resource
var is_knockback : bool
var knockback_direction : Vector2

signal enemy_health_update
signal enemy_death(position : Vector2)
const SMOKE_SCENE = preload("res://src/actors/smoke_explosion.tscn")

func _ready():
  is_knockback = false
  %Slime.play_walk()
  enemy_health_update.connect(level._on_enemy_hit)
  enemy_death.connect(level._on_enemy_death)
  add_to_group("slime")

func get_damage() -> float:
  return damage
  
func set_damage(d: float) -> void:
  damage = d

func _physics_process(delta):
  if !is_knockback:
    var direction = global_position.direction_to(player.global_position).normalized()
    velocity = direction * speed
  else:
    velocity = knockback_direction * knockback_speed
  move_and_collide(velocity * delta)

func take_damage(direction: Vector2, damage: float):
  knockback_direction = direction
  %Slime.play_hurt()
  health -= damage
  enemy_health_update.emit()
  is_knockback = true
  %Timer.start(0.1)

  if (health < 0.01):
    await %Timer.timeout
    enemy_death.emit(global_position)
    queue_free()
    var smoke = SMOKE_SCENE.instantiate()
    get_parent().add_child(smoke)
    smoke.global_position = global_position
    smoke.global_scale = %Slime.global_scale

func _on_timer_timeout() -> void:
  is_knockback = false
