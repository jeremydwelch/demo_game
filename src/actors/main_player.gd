extends CharacterBody2D
  
# configuration values
@export var speed : float = 100.0
@export var knockback_speed : float = 200.0
@export var health : int = 5;
@export var damage_rate : float = 500;

signal player_death

# references
@onready var animation_tree : AnimationTree = $AnimationTree

# class data
var direction : Vector2 = Vector2.ZERO
var is_alive : bool = true

var is_knockback : bool = false
var knockback_direction : Vector2
  
func _ready():
  animation_tree.active = true
  %health_bar.max_value = health
  %health_bar.value = health

func _physics_process(delta):
  get_input()
  move_and_slide()

func _process(_delta):
  update_animation()

func get_input():
  # Get the input direction and handle the movement/deceleration.
  # As good practice, you should replace UI actions with custom gameplay actions.
  direction = Input.get_vector("left", "right", "up", "down").normalized()
  if is_knockback:
    velocity = knockback_direction * knockback_speed
  elif is_alive:
    velocity = direction * speed
  else:
    velocity = Vector2.ZERO

func take_player_damage():
  print("Player Took Damage")
  health -= 1
  %health_bar.value = health
  if health < 1:
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
  take_player_damage()


func _on_knockback_timer_timeout() -> void:
  is_knockback = false # Replace with function body.
