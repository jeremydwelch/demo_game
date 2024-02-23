extends CanvasLayer

var timer: Timer

func update_score(score):
  $NinePatchRect/Score.text = "Score: " + str(score)
  
func update_health(health, max):
  $NinePatchRect/Health.max_value = max
  $NinePatchRect/Health.value = health

func update_experience(value):
  $NinePatchRect/Experience.value = value

func update_level(level):
  $NinePatchRect/Level.text = "Level: " + str(level)

func set_timer_node(t: Timer) -> void:
  timer = t

func format_time_remaining() -> void:
    if timer != null:
      var seconds : int = int(timer.time_left) % 60
      var minutes : int = int(timer.time_left) / 60
      
      var format = "%02d:%02d"
      var actual = format % [ minutes, seconds]
      $NinePatchRect/Time.text = actual
  
func _process(_delta):
  format_time_remaining()
