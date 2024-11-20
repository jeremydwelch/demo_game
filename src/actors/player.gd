extends CharacterBody2D
class_name Player
  
# configuration values
@export var speed: float = 50.0
@export var speed_modifier: int = 0
@export var speed_scale: float = 1.5

@export var max_health: int = 30;
@export var max_health_modifier: int = 0
@export var max_health_scale: int = 2

@export var health_collectible_modifier: float = 1.0

@export var weapon_damage: float = 10.1
@export var weapon_damage_modifier: int = 0
@export var weapon_scale: float = 1.5

@export var knockback_speed: float = 200.0
@export var knockback_speed_modifier: float = 1.0

@export var toughness: int = 0
@export var toughness_scale: float = 1.5

var current_level: int
var current_health: float
var current_experience: int

# Player level increases
@export var exp_to_next_level: int = 100
@export var exp_increase_per_level: int = 10

@export var level_up_stats_gained: int = 2

signal player_death
signal player_health_update(current_health, max_health)
signal crystal_collected
signal player_level_up

# references
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var knockback_timer: Timer = $KnockbackTimer

# class data
var direction : Vector2 = Vector2.ZERO
var is_alive : bool = true
var is_swinging: bool = false
var is_knockback : bool = false
var hit: bool = false
var knockback_direction : Vector2
  
func _ready():
  set_current_health(get_max_health())
  animation_tree.active = true
  %health_bar.max_value = get_current_health()
  %health_bar.value = get_current_health()
  player_health_update.emit(get_current_health(), get_max_health())
  add_to_group("player", true)

func _physics_process(_delta):
  get_input()
  move_and_slide()

func _process(_delta):
  update_animation()

func get_current_health() -> int:
  return current_health
  
func set_current_health(h: int) -> void:
  current_health = h
  
func get_max_health() -> int:
 return max_health + (max_health_modifier * max_health_scale)
     
func set_max_health(max: int) -> void:
  max_health = max

func set_max_health_modifier(max: int) -> void:
  max_health_modifier = max

func get_damage() -> float:
  return (weapon_damage + (weapon_damage_modifier * weapon_scale))
    
func set_damage_modifier(d: int) -> void:
  weapon_damage_modifier = d
  
func get_speed() -> float:
  return speed + (speed_modifier * speed_scale)
  
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
  print("player add exp: " + str(xp))
  current_experience += xp
  if current_experience > exp_to_next_level:
    level_up()

func get_level_up_stat_points_gained() -> int:
  return level_up_stats_gained
  
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
  print("Player Took Damage: " + str(damage) + ", Current Health: " + str(get_current_health()))

  # Player shouldn't take damage more than once per "knockback"
  # The timer is set to the length of the animation plus a little fuzz
  if hit:
    return
  hit = true
  animation_tree["parameters/conditions/hit"] = true
  knockback_timer.start()
  
  var armor_reduction = 100 - (toughness * toughness_scale)
  if armor_reduction < 10:
    armor_reduction = 10
  # Armor reduces damage by a percentage
  # but can never reduce damage to less than 10%
  var new_health = get_current_health() - (damage * (armor_reduction / 100))
  set_current_health(new_health)
  print("new health: " + str(get_current_health()))
  %health_bar.value = get_current_health()
  player_health_update.emit(get_current_health(), get_max_health())
  if get_current_health() < 0.01:
    is_alive = false
    player_death.emit() 

func update_animation():
  # print("direction is (" + str(direction.x) + " , " + str(direction.y) + ")")
  if !is_alive:
    animation_tree["parameters/conditions/is_dead"] = true
    return

  if Input.is_action_just_pressed("use"):
    animation_tree["parameters/conditions/swing"] = true
    is_swinging = true
  else:
    animation_tree["parameters/conditions/swing"] = false
  
  # The player should not be able to change the swing direction in mid animaition
  # We need to track if the player is swinging, and if they are do not update
  # the animation tree direction so that the animation can finish
  # once it is done we can allow updates again
  if is_swinging:
    return
  if (velocity == Vector2.ZERO):
    animation_tree["parameters/conditions/is_idle"] = true
    animation_tree["parameters/conditions/is_moving"] = false
  else:
    animation_tree["parameters/conditions/is_idle"] = false
    animation_tree["parameters/conditions/is_moving"] = true
    animation_tree["parameters/Idle/blend_position"] = velocity.x
    animation_tree["parameters/Run/blend_position"] = velocity.x
    animation_tree["parameters/Swing/blend_position"] = velocity.x
    animation_tree["parameters/Dead/blend_position"] = velocity.x
    animation_tree["parameters/Hit/blend_position"] = velocity.x

    

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
    current_health += (10.0 * health_collectible_modifier)
    if current_health > get_max_health():
      current_health = get_max_health()
    player_health_update.emit(current_health, get_max_health())
  elif body.get_parent().is_in_group("crystal"):
    crystal_collected.emit()
  if body.get_parent().has_method("_on_disappear"):
    body.get_parent()._on_disappear()
  print("Player max health: " + str(get_max_health()))
  print("Player current health: " + str(current_health))

func _on_knockback_timer_timeout() -> void:
  is_knockback = false # Replace with function body.
  hit = false
  animation_tree["parameters/conditions/hit"] = false


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
  if anim_name == "swing_left" || anim_name == "swing_right":
    is_swinging = false
    print("Finished hit animaition")
