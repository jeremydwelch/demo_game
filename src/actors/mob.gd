extends CharacterBody2D
class_name Mob

@export var speed : float = 10
@export var speed_increase :float = 1.0
@export var knockback_speed : float = 250
@export var health : float = 25.0
@export var health_increase: float = 5.0
@export var damage: float = 5.0
@export var damage_increase: float = 5.0
@export var mob_level: int = 0

@onready var player : CharacterBody2D = get_node(Globals.player_node_path)
@onready var level : Node2D = get_node(Globals.level_node_path)
var smokeScene : Resource
var is_knockback : bool
var knockback_direction : Vector2

signal enemy_health_update
signal enemy_death(position : Vector2)
static var SMOKE_SCENE = load("res://src/actors/smoke_explosion.tscn")

# references
@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
  is_knockback = false
  animation_tree.active = true
  enemy_health_update.connect(level._on_enemy_hit)
  enemy_death.connect(level._on_enemy_death)
  add_to_group("mob")
  add_to_group(get_mob_name())
  
func get_mob_name() -> String:
  return "mob"
  
func set_level(l: int) -> void:
  mob_level = l
  set_damage(get_damage() + (mob_level * damage_increase))
  set_speed(get_speed() + (mob_level * speed_increase))
  set_health(get_health() + (mob_level * health_increase))
  

func get_damage() -> float:
  return damage
  
func set_damage(d: float) -> void:
  damage = d

func set_speed(s: float) -> void:
  speed = s

func get_speed() -> float:
  return speed  

func set_health(h: float) -> void:
  health = h
  
func get_health() -> float:
  return health

func get_knockback_speed() -> float:
  return knockback_speed
  
func set_knockback_speed(k: float) -> void:
  knockback_speed = k

func _physics_process(delta):
  if !is_knockback:
    var direction = global_position.direction_to(player.global_position).normalized()
    velocity = direction * speed
  else:
    velocity = knockback_direction * knockback_speed
  move_and_collide(velocity * delta)
  
func _process(_delta): 
  update_animation()
  
func update_animation():
  var direction = player.global_position.x - global_position.x
  if (velocity == Vector2.ZERO):
    animation_tree["parameters/conditions/is_idle"] = true
    animation_tree["parameters/conditions/is_moving"] = false
  else:
    animation_tree["parameters/conditions/is_idle"] = false
    animation_tree["parameters/conditions/is_moving"] = true
    animation_tree["parameters/Idle/blend_position"] = direction
    animation_tree["parameters/Run/blend_position"] = direction
    animation_tree["parameters/Hit/blend_position"] = direction
  return

func take_damage(direction: Vector2, damage: float):
  knockback_direction = direction
  animation_tree["parameters/conditions/hit"] = true
  print(get_mob_name() + " took damage: " + str(damage))
  health -= damage
  print(get_mob_name() + " has health: " + str(health))
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
    # smoke.global_scale = global_scale

func _on_timer_timeout() -> void:
  is_knockback = false
  animation_tree["parameters/conditions/hit"] = false
