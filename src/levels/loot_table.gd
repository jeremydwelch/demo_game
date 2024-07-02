extends Node
class_name LootTable

@onready var loot_table = RandomNumberGenerator.new()
var loot_table_max : float = 1000.0
var heart_drop_rate : float = 100.0
var crystal_drop_rate : float = 300.0

var HEART_SCENE: PackedScene
var CRYSTAL_SCENE: PackedScene

func _ready() -> void:
  HEART_SCENE = load(Globals.heart_scene_path)
  CRYSTAL_SCENE = load(Globals.crystal_scene_path)

func randomize() -> void:
  loot_table = RandomNumberGenerator.new()
  
func generate_loot(position : Vector2) -> void:
  var rand : float = loot_table.randf_range(0.0,loot_table_max)
  print("rand: " + str(rand))
  if rand < heart_drop_rate:
    print("Dropped heart")
    var heart = HEART_SCENE.instantiate()
    add_child(heart)
    heart.global_position = position
  elif rand < (crystal_drop_rate + heart_drop_rate):
    print("Dropped crystal")
    var crystal = CRYSTAL_SCENE.instantiate()
    add_child(crystal)
    crystal.global_position = position
