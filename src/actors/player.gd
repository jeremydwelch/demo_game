extends CharacterBody2D
class_name Player
  
# configuration values
@export var speed: float = 100.0
@export var speed_modifier: int = 0

@export var max_health: int = 30;

@export var health_collectible_modifier: float = 1.0

@export var weapon_damage: float = 10.0
@export var weapon_damage_modifier: int = 0

@export var knockback_speed: float = 200.0
@export var knockback_speed_modifier: float = 1.0

@export var toughness: int = 0

var current_level: int
var current_health: float
var current_experience: int

# Player level increases
@export var exp_to_next_level: int = 100
@export var exp_increase_per_level: int = 0

signal player_death
signal player_health_update(current_health, max_health)
signal crystal_collected
signal player_level_up

# references
@onready var animation_tree : AnimationTree = $AnimationTree

# class data
var direction : Vector2 = Vector2.ZERO
var is_alive : bool = true

var is_knockback : bool = false
var knockback_direction : Vector2
  
func _ready():
  current_health = max_health
  animation_tree.active = true
  %health_bar.max_value = current_health
  %health_bar.value = current_health
  player_health_update.emit(current_health, max_health)

func _physics_process(_delta):
  get_input()
  move_and_slide()

func _process(_delta):
  update_animation()

func get_max_health() -> int:
 return max_health
     
func set_max_health(max: int) -> void:
  max_health = max

func get_damage() -> float:
  return (weapon_damage + weapon_damage_modifier)
    
func set_damage_modifier(d: int) -> void:
  weapon_damage_modifier = d
  
func get_speed() -> float:
  return speed + speed_modifier
  
func set_speed_modifier(s: int) -> void:
  speed_modifier = s
  
func set_toughness_modifier(t: int) -> void:
  toughness = t

func get_level() -> int:
  return current_level

func set_level(l: int) -> void:
  current_level = l

func get_exp() -> int:
  return current_experience
  
func set_exp(xp: int) -> void:
  current_experience = xp
  
func add_experience(xp: float) -> void:
  current_experience += xp
  if current_experience > exp_to_next_level:
    level_up()
    
func level_up() -> void:
  # Set new player stats
  var new_level = get_level() + 1
  exp_to_next_level += exp_increase_per_level
  set_level(new_level)
  set_exp(0)
  player_level_up.emit()

func get_input():
  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  direction = Input.get_vector("left", "right", "up", "down").normalized()
  if is_knockback:
    velocity = knockback_direction * knockback_speed * knockback_speed_modifier
  elif is_alive:
    velocity = direction * (get_speed())
  else:
    velocity = Vector2.ZERO

func take_player_damage(damage: float):
  print("Player Took Damage")
  
  var armor_reduction = 100 - toughness
  if armor_reduction < 10:
    armor_reduction = 10
  # Armor reduces damage by a percentage
  # but can never reduce damage to less than 10%
  current_health -= (damage * (armor_reduction / 100))
  %health_bar.value = current_health
  player_health_update.emit(current_health, get_max_health())
  if current_health < 0.01:
    is_alive = false
    player_death.emit() 

func update_animation():
  if !is_alive:
    animation_tree["parameters/conditions/is_dead"] = true
    return

  if Input.is_action_just_pressed("use"):
    animation_tree["parameters/conditions/swing"] = true
  else:
    animation_tree["parameters/conditions/swing"] = false
  if (velocity == Vector2.ZERO):
    animation_tree["parameters/conditions/is_idle"] = true
    animation_tree["parameters/conditions/is_moving"] = false
  else:
    animation_tree["parameters/conditions/is_idle"] = false
    animation_tree["parameters/conditions/is_moving"] = true
    animation_tree["parameters/Idle/blend_position"] = direction
    animation_tree["parameters/Run/blend_position"] = direction
    animation_tree["parameters/Swing/blend_position"] = direction
    animation_tree["parameters/Dead/blend_position"] = direction

func _on_hurtbox_body_entered(body: Node2D) -> void:
  if !is_alive:
    return
  var d: float = 1.0
  if body.has_method("get_damage"):
    d = body.get_damage()
  take_player_damage(d)

func _on_collectible_box_entered(body: Node2D) -> void:
  print("Player Collectible Box entered " + body.get_parent().name)
 
  if body.get_parent().is_in_group("heart"):
    if current_health < get_max_health():
      current_health += (10.0 * health_collectible_modifier)
      player_health_update.emit(current_health, get_max_health())
  elif body.get_parent().is_in_group("crystal"):
    crystal_collected.emit()

func _on_knockback_timer_timeout() -> void:
  is_knockback = false # Replace with function body.
