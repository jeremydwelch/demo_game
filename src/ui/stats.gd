extends CanvasLayer

signal toggle_pause
signal new_stats(health, damage, speed, toughness)

var health: int = 0
var damage: int = 0
var speed: int = 0
var toughness: int = 0

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
  if points_to_spend > 0:
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
  $NinePatchRect/HP.text = "Max Health: " + str(health)
  
func update_damage():
  $NinePatchRect/Damage.text = "Damage: " + str(damage)

func update_speed():
  $NinePatchRect/Speed.text = "Speed: " + str(speed)

func update_toughness():
  $NinePatchRect/Toughness.text = "Toughness: " + str(toughness)

func update_buttons():
  if points_to_spend > 0:
    $"NinePatchRect/hp-up".show()
    $"NinePatchRect/damage-up".show()
    $"NinePatchRect/speed-up".show()
    $"NinePatchRect/toughness-up".show()
  else:
    $"NinePatchRect/hp-up".hide()
    $"NinePatchRect/damage-up".hide()
    $"NinePatchRect/speed-up".hide()
    $"NinePatchRect/toughness-up".hide()
    

func _button_pressed():
  print("stats button pressed")
  unpause()

func _confirm_pressed():
  print("confirmed button pressed")
  if points_spent > 0:
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

func _hp_up() -> void:
  print("hp up button pressed")
  if (points_to_spend - points_spent) > 0:
    points_spent += 1
    $"NinePatchRect/hp-up".text = "-"
    health += 1
    $"NinePatchRect/damage-up".disabled = true
    $"NinePatchRect/speed-up".disabled = true
    $"NinePatchRect/toughness-up".disabled = true
  else:
    points_spent -= 1
    $"NinePatchRect/hp-up".text = "+"
    health -= 1
    $"NinePatchRect/damage-up".disabled = false
    $"NinePatchRect/speed-up".disabled = false
    $"NinePatchRect/toughness-up".disabled = false
  update_max_health()

func _damage_up() -> void:
  print("damage up button pressed")
  if (points_to_spend - points_spent) > 0:
    points_spent += 1
    $"NinePatchRect/damage-up".text = "-"
    damage += 1
    $"NinePatchRect/speed-up".disabled = true
    $"NinePatchRect/hp-up".disabled = true
    $"NinePatchRect/toughness-up".disabled = true
  else: 
    points_spent -= 1
    $"NinePatchRect/damage-up".text = "+"
    damage -= 1 
    $"NinePatchRect/speed-up".disabled = false
    $"NinePatchRect/hp-up".disabled = false
    $"NinePatchRect/toughness-up".disabled = false
  update_damage()

func _speed_up() -> void:
  print("speed up button pressed")
  if (points_to_spend - points_spent) > 0:
    points_spent += 1
    $"NinePatchRect/speed-up".text = "-"
    speed += 1
    $"NinePatchRect/damage-up".disabled = true
    $"NinePatchRect/hp-up".disabled = true
    $"NinePatchRect/toughness-up".disabled = true
  else:
    points_spent -= 1
    $"NinePatchRect/speed-up".text = "+"
    speed -= 1
    $"NinePatchRect/damage-up".disabled = false
    $"NinePatchRect/hp-up".disabled = false
    $"NinePatchRect/toughness-up".disabled = false
  update_speed()

func _toughness_up() -> void:
  print("toughness button pressed")
  if (points_to_spend - points_spent) > 0:
    points_spent += 1
    $"NinePatchRect/toughness-up".text = "-"
    toughness += 1
    
    $"NinePatchRect/damage-up".disabled = true
    $"NinePatchRect/speed-up".disabled = true
    $"NinePatchRect/hp-up".disabled = true
  else:
    points_spent -= 1
    $"NinePatchRect/toughness-up".text = "+"
    toughness -= 1
    
    $"NinePatchRect/damage-up".disabled = false
    $"NinePatchRect/speed-up".disabled = false
    $"NinePatchRect/hp-up".disabled = false
  update_toughness()
