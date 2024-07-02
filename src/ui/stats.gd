extends CanvasLayer
class_name Stats

signal toggle_pause
signal new_stats(health, damage, speed, toughness)

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

func _ready() -> void:
  refresh()

func refresh() -> void:
  update_max_health()
  update_damage()
  update_speed()
  update_toughness()
  update_buttons()
  
func set_stat_points_to_spend(value) -> void:
  points_to_spend = value
  
func _process(delta: float) -> void:
  if Input.is_action_just_released("pause"):
    if paused:
      unpause()
    else:
      pause()
  if points_spent > 0 and points_to_spend == 0:
    $NinePatchRect/Confirm.show()
    $NinePatchRect/Close.hide()
  else: 
    $NinePatchRect/Confirm.hide()
    $NinePatchRect/Close.show()
  refresh()

func set_health(h) -> void:
  health = h

func set_damage(d) -> void:
  damage = d
  
func set_speed(s) -> void:
  speed = s

func set_toughness(t) -> void:
  toughness = t
  
func update_max_health():
  var h = health
  if temp_health > health:
    h = temp_health
  $NinePatchRect/HP.text = "Max Health: " + str(h)
  
func update_damage():
  var d = damage
  if temp_damage > damage:
    d = temp_damage
  $NinePatchRect/Damage.text = "Damage: " + str(d)

func update_speed():
  var s = speed
  if temp_speed > speed:
    s = temp_speed
  $NinePatchRect/Speed.text = "Speed: " + str(s)

func update_toughness():
  var t = toughness
  if temp_toughness > toughness:
    t = temp_toughness
  $NinePatchRect/Toughness.text = "Toughness: " + str(t)

func update_buttons():
  if points_to_spend == 0:
    $"NinePatchRect/hp-up".disabled = true  
    $"NinePatchRect/damage-up".disabled = true  
    $"NinePatchRect/speed-up".disabled = true  
    $"NinePatchRect/toughness-up".disabled = true
  if points_spent == 0:
    $"NinePatchRect/hp-down".disabled = true  
    $"NinePatchRect/damage-down".disabled = true  
    $"NinePatchRect/speed-down".disabled = true  
    $"NinePatchRect/toughness-down".disabled = true
  if points_to_spend > 0:
    $"NinePatchRect/hp-up".disabled = false  
    $"NinePatchRect/damage-up".disabled = false  
    $"NinePatchRect/speed-up".disabled = false  
    $"NinePatchRect/toughness-up".disabled = false
  
  if temp_health == health:
    $"NinePatchRect/hp-down".disabled = true
  else:
    $"NinePatchRect/hp-down".disabled = false
  if temp_damage == damage:
    $"NinePatchRect/damage-down".disabled = true
  else:
    $"NinePatchRect/damage-down".disabled = false
  if temp_speed == speed:
    $"NinePatchRect/speed-down".disabled = true
  else:
    $"NinePatchRect/speed-down".disabled = false
  if temp_toughness == toughness:
    $"NinePatchRect/toughness-down".disabled = true
  else:
    $"NinePatchRect/toughness-down".disabled = false
  
    

func _button_pressed():
  print("stats button pressed")
  unpause()

func _confirm_pressed():
  print("confirmed button pressed")
  if points_spent > 0 and points_to_spend == 0:
    health = temp_health
    damage = temp_damage
    speed = temp_speed
    toughness = temp_toughness
    var format_string = "New Stats: HP: %d, Damage: %d, Speed: %d, Toughness: %d"
    var actual_string = format_string % [health, damage, speed, toughness]
    print(actual_string)
    points_to_spend = 0
    points_spent = 0
    unpause()

func pause() -> void:
  paused = true
  get_tree().paused = true
  show()

func unpause() -> void:
  paused = false
  get_tree().paused = false
  hide()
  new_stats.emit(health, damage, speed, toughness)
  toggle_pause.emit()
  
func spend_point() -> void:
  points_to_spend -= 1
  points_spent += 1
  
func refund_point() -> void:
  points_to_spend += 1
  points_spent -= 1

func _hp_up() -> void:
  print("hp up button pressed")
  temp_health += 1
  spend_point()
  update_max_health()
  
func _hp_down() -> void:
  print("hp down button pressed")
  temp_health -= 1
  refund_point()
  update_max_health()
  
func _damage_up() -> void:
  print("damage up button pressed")
  temp_damage += 1
  spend_point()
  update_damage()
  
func _damage_down() -> void:
  print("damage down button pressed")
  temp_damage -= 1
  refund_point()
  update_damage()
  
func _speed_up() -> void:
  print("speed up button pressed")
  temp_speed += 1
  spend_point()
  update_speed()

func _speed_down() -> void:
  print("speed down button pressed")
  temp_speed -= 1
  refund_point()
  update_speed()

func _toughness_up() -> void:
  print("toughness up button pressed")
  temp_toughness += 1
  spend_point()
  update_toughness()

func _toughness_down() -> void:
  print("toughness down button pressed")
  temp_toughness -= 1
  refund_point()
  update_toughness()
