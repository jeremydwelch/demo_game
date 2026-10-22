class_name Player
extends CharacterBody2D

signal player_death
signal player_health_update(current_health: float, max_health: float)
signal crystal_collected
signal player_level_up

## Toughness can never reduce incoming damage below this percentage.
const MIN_DAMAGE_TAKEN_PERCENT: float = 10.0

@export var speed: float = 50.0
@export var speed_modifier: int = 0
@export var speed_scale: float = 1.5

@export var max_health: float = 30.0
@export var max_health_modifier: int = 0
@export var max_health_scale: float = 2.0

@export var health_collectible_modifier: float = 1.0

@export var weapon_damage: float = 10.1
@export var weapon_damage_modifier: int = 0
@export var weapon_scale: float = 1.5

# TODO: Player knockback is not implemented yet; is_knockback is never set to true.
@export var knockback_speed: float = 200.0
@export var knockback_speed_modifier: float = 1.0

@export var toughness: int = 0
@export var toughness_scale: float = 1.5

@export var exp_to_next_level: int = 100
@export var exp_increase_per_level: int = 10
@export var level_up_stats_gained: int = 2

var current_level: int = 0
var current_health: float = 0.0
var current_experience: int = 0
var is_alive: bool = true
var is_swinging: bool = false
var is_knockback: bool = false
var hit: bool = false
var knockback_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var hurtbox: Area2D = %Hurtbox
@onready var health_bar: ProgressBar = %health_bar


func _ready() -> void:
	current_health = get_max_health()
	animation_tree.active = true
	_update_health_display()
	add_to_group("player", true)


func _physics_process(_delta: float) -> void:
	_update_velocity()
	move_and_slide()


func _process(_delta: float) -> void:
	_update_animation()


func get_current_health() -> float:
	return current_health


func get_max_health() -> float:
	return max_health + max_health_modifier * max_health_scale


func set_max_health_modifier(value: int) -> void:
	max_health_modifier = value
	current_health = minf(current_health, get_max_health())
	_update_health_display()


func get_damage() -> float:
	return weapon_damage + weapon_damage_modifier * weapon_scale


func set_damage_modifier(value: int) -> void:
	weapon_damage_modifier = value


func get_speed() -> float:
	return speed + speed_modifier * speed_scale


func set_speed_modifier(value: int) -> void:
	speed_modifier = value


func set_toughness_modifier(value: int) -> void:
	toughness = value


func get_level() -> int:
	return current_level


func get_exp() -> int:
	return current_experience


func get_exp_to_next_level() -> int:
	return exp_to_next_level


func get_level_up_stat_points_gained() -> int:
	return level_up_stats_gained


func add_experience(xp: int) -> void:
	current_experience += xp
	while current_experience >= exp_to_next_level:
		current_experience -= exp_to_next_level
		level_up()


func level_up() -> void:
	current_level += 1
	exp_to_next_level += exp_increase_per_level
	player_level_up.emit()


func heal(amount: float) -> void:
	current_health = minf(current_health + amount, get_max_health())
	_update_health_display()


func take_player_damage(amount: float) -> void:
	# The player can only take damage once per hit window. KnockbackTimer is set
	# to the length of the hit animation plus a little fuzz.
	if hit or not is_alive:
		return
	hit = true
	animation_tree["parameters/conditions/hit"] = true
	knockback_timer.start()

	var damage_taken_percent: float = maxf(
			100.0 - toughness * toughness_scale, MIN_DAMAGE_TAKEN_PERCENT)
	current_health = maxf(current_health - amount * damage_taken_percent / 100.0, 0.0)
	_update_health_display()
	if current_health <= 0.0:
		is_alive = false
		player_death.emit()


func _update_velocity() -> void:
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	if is_knockback:
		velocity = knockback_direction * knockback_speed * knockback_speed_modifier
	elif is_alive:
		velocity = direction * get_speed()
	else:
		velocity = Vector2.ZERO


func _update_health_display() -> void:
	health_bar.max_value = get_max_health()
	health_bar.value = current_health
	player_health_update.emit(current_health, get_max_health())


func _update_animation() -> void:
	if not is_alive:
		animation_tree["parameters/conditions/is_dead"] = true
		return

	if Input.is_action_just_pressed("use"):
		animation_tree["parameters/conditions/swing"] = true
		is_swinging = true
	else:
		animation_tree["parameters/conditions/swing"] = false

	# Don't change the swing direction mid-animation. Direction updates resume
	# once the swing animation finishes.
	if is_swinging:
		return
	if velocity == Vector2.ZERO:
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


func _damage_from(body: Node2D) -> void:
	var amount: float = 1.0
	if body.has_method("get_damage"):
		amount = body.get_damage()
	take_player_damage(amount)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	_damage_from(body)


func _on_collectible_box_entered(area: Area2D) -> void:
	var collectible: Node = area.get_parent()
	if collectible is Heart:
		heal(collectible.get_health_increase() * health_collectible_modifier)
	elif collectible is Crystal:
		crystal_collected.emit()
	if collectible is Collectible:
		collectible.collect()


func _on_knockback_timer_timeout() -> void:
	is_knockback = false
	hit = false
	animation_tree["parameters/conditions/hit"] = false
	# body_entered only fires once, so keep hurting the player while a mob stays in contact.
	var bodies: Array[Node2D] = hurtbox.get_overlapping_bodies()
	if not bodies.is_empty():
		_damage_from(bodies[0])


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "swing_left" or anim_name == "swing_right":
		is_swinging = false
