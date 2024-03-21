extends Collectible

@export var health_increase: float = 1.0

func _ready() -> void:
  super._ready()
  add_to_group("heart", true)

func get_health_increase() -> float:
  return health_increase
