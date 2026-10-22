class_name Stats
extends CanvasLayer

signal new_stats(health: int, damage: int, speed: int, toughness: int)

var health: int = 0
var damage: int = 0
var speed: int = 0
var toughness: int = 0

var temp_health: int = 0
var temp_damage: int = 0
var temp_speed: int = 0
var temp_toughness: int = 0

var paused: bool = false
var points_to_spend: int = 0
var points_spent: int = 0

@onready var close_button: Button = $NinePatchRect/Close
@onready var confirm_button: Button = $NinePatchRect/Confirm
@onready var hp_up_button: Button = $"NinePatchRect/hp-up"
@onready var hp_down_button: Button = $"NinePatchRect/hp-down"
@onready var damage_up_button: Button = $"NinePatchRect/damage-up"
@onready var damage_down_button: Button = $"NinePatchRect/damage-down"
@onready var speed_up_button: Button = $"NinePatchRect/speed-up"
@onready var speed_down_button: Button = $"NinePatchRect/speed-down"
@onready var toughness_up_button: Button = $"NinePatchRect/toughness-up"
@onready var toughness_down_button: Button = $"NinePatchRect/toughness-down"


func _ready() -> void:
	refresh()


func _process(_delta: float) -> void:
	if Input.is_action_just_released("pause"):
		if paused:
			unpause()
		else:
			pause()
	var can_confirm: bool = points_spent > 0 and points_to_spend == 0
	confirm_button.visible = can_confirm
	close_button.visible = not can_confirm
	refresh()


func refresh() -> void:
	_update_max_health()
	_update_damage()
	_update_speed()
	_update_toughness()
	_update_buttons()


func add_stat_points(value: int) -> void:
	points_to_spend += value


func confirm_stats() -> void:
	if points_spent > 0 and points_to_spend == 0:
		health = temp_health
		damage = temp_damage
		speed = temp_speed
		toughness = temp_toughness
		points_spent = 0


func pause() -> void:
	paused = true
	get_tree().paused = true
	show()


func unpause() -> void:
	if points_to_spend > 0:
		return
	confirm_stats()
	paused = false
	get_tree().paused = false
	hide()
	new_stats.emit(health, damage, speed, toughness)


func _spend_point() -> void:
	points_to_spend -= 1
	points_spent += 1


func _refund_point() -> void:
	points_to_spend += 1
	points_spent -= 1


func _update_max_health() -> void:
	$NinePatchRect/HP.text = "Max Health: " + str(maxi(health, temp_health))


func _update_damage() -> void:
	$NinePatchRect/Damage.text = "Damage: " + str(maxi(damage, temp_damage))


func _update_speed() -> void:
	$NinePatchRect/Speed.text = "Speeeeeeeeeeeeeeeeeeeeeeed: " + str(maxi(speed, temp_speed))


func _update_toughness() -> void:
	$NinePatchRect/Toughness.text = "Toughness: " + str(maxi(toughness, temp_toughness))


func _update_buttons() -> void:
	var can_spend: bool = points_to_spend > 0
	hp_up_button.disabled = not can_spend
	damage_up_button.disabled = not can_spend
	speed_up_button.disabled = not can_spend
	toughness_up_button.disabled = not can_spend

	hp_down_button.disabled = temp_health == health
	damage_down_button.disabled = temp_damage == damage
	speed_down_button.disabled = temp_speed == speed
	toughness_down_button.disabled = temp_toughness == toughness


func _button_pressed() -> void:
	unpause()


func _confirm_pressed() -> void:
	if points_spent > 0 and points_to_spend == 0:
		unpause()


func _hp_up() -> void:
	temp_health += 1
	_spend_point()
	_update_max_health()


func _hp_down() -> void:
	temp_health -= 1
	_refund_point()
	_update_max_health()


func _damage_up() -> void:
	temp_damage += 1
	_spend_point()
	_update_damage()


func _damage_down() -> void:
	temp_damage -= 1
	_refund_point()
	_update_damage()


func _speed_up() -> void:
	temp_speed += 1
	_spend_point()
	_update_speed()


func _speed_down() -> void:
	temp_speed -= 1
	_refund_point()
	_update_speed()


func _toughness_up() -> void:
	temp_toughness += 1
	_spend_point()
	_update_toughness()


func _toughness_down() -> void:
	temp_toughness -= 1
	_refund_point()
	_update_toughness()
