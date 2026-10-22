class_name Mob
extends CharacterBody2D

signal enemy_health_update
signal enemy_death(death_position: Vector2, kill_exp: int)

const SMOKE_SCENE: PackedScene = preload("res://src/actors/smoke_explosion.tscn")
const HIT_STUN_TIME: float = 0.1

@export var speed: float = 10.0
@export var speed_increase: float = 1.0
@export var knockback_speed: float = 250.0
@export var health: float = 25.0
@export var health_increase: float = 5.0
@export var damage: float = 5.0
@export var damage_increase: float = 5.0
@export var mob_level: int = 0
@export var kill_exp: int = 5

## The node this mob chases. Set by whoever spawns the mob.
var target: Node2D
var is_knockback: bool = false
var is_dead: bool = false
var knockback_direction: Vector2 = Vector2.ZERO

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var hit_timer: Timer = %Timer


func _ready() -> void:
	animation_tree.active = true
	add_to_group("mob")
	add_to_group(get_mob_name())


func _physics_process(delta: float) -> void:
	if is_knockback:
		velocity = knockback_direction * knockback_speed
	elif target:
		velocity = global_position.direction_to(target.global_position) * speed
	else:
		velocity = Vector2.ZERO
	move_and_collide(velocity * delta)


func _process(_delta: float) -> void:
	_update_animation()


func get_mob_name() -> String:
	return "mob"


func set_level(new_level: int) -> void:
	mob_level = new_level
	damage += mob_level * damage_increase
	speed += mob_level * speed_increase
	health += mob_level * health_increase


func get_damage() -> float:
	return damage


func take_damage(direction: Vector2, amount: float) -> void:
	if is_dead:
		return
	knockback_direction = direction
	animation_tree["parameters/conditions/hit"] = true
	health -= amount
	enemy_health_update.emit()
	is_knockback = true
	hit_timer.start(HIT_STUN_TIME)

	if health <= 0.0:
		is_dead = true
		# Stop the corpse from being hit again or hurting the player while it plays out.
		set_deferred("collision_layer", 0)
		await hit_timer.timeout
		_die()


func _die() -> void:
	var smoke: Node2D = SMOKE_SCENE.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	enemy_death.emit(global_position, kill_exp)
	queue_free()


func _update_animation() -> void:
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
		return
	animation_tree["parameters/conditions/is_idle"] = false
	animation_tree["parameters/conditions/is_moving"] = true
	if not target:
		return
	var facing: float = target.global_position.x - global_position.x
	animation_tree["parameters/Idle/blend_position"] = facing
	animation_tree["parameters/Run/blend_position"] = facing
	animation_tree["parameters/Hit/blend_position"] = facing


func _on_timer_timeout() -> void:
	is_knockback = false
	animation_tree["parameters/conditions/hit"] = false
