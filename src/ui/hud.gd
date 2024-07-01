extends CanvasLayer

var timer: Timer
var have_level_time: bool

func update_score(score):
  $NinePatchRect/Score.text = "Score: " + str(score)
  
func update_health(health, max):
  $NinePatchRect/Health.max_value = max
  $NinePatchRect/Health.value = health

func update_experience(value):
  $NinePatchRect/Experience.value = value

func update_level(level):
  $NinePatchRect/Level.text = "Level: " + str(level)
  
func update_world(world):
  $NinePatchRect/World.text = "World: " + str(world)
