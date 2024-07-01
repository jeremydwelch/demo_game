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
  
#func add_time(time: float):
  #if !have_level_time:
    #return
  #var time_left = timer.get_time_left()
  #timer.stop()
  #timer.start(time_left + time)
  #print("added time: " + str(timer.get_time_left()))
 #
#func set_timer_node(t: Timer) -> void:
  #timer = t
#
#func format_time_remaining() -> void:
  #if !have_level_time:
    #return
  #if timer != null:
    #var seconds : int = int(timer.time_left) % 60
    #var minutes : int = int(timer.time_left) / 60
    #
    #var format = "%02d:%02d"
    #var actual = format % [ minutes, seconds]
    #$NinePatchRect/Time.text = actual
  
