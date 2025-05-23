extends CanvasLayer

@onready var timer_label = $TimePanel/TimerLabel  # Updated path to match your scene
@onready var timer = $Timer
@export var total_time: float = 120.0  # 2 minutes in seconds
var time_left: float
var is_running: bool = true

func _ready():
	time_left = total_time
	update_timer_display()
	if timer:
		timer.wait_time = 1.0
		timer.start()
	else:
		push_error("Timer node not found! Add a Timer node as a child.")

func _process(delta):
	if is_running and time_left > 0:
		time_left -= delta
		update_timer_display()
		if time_left <= 0:
			game_over()

func update_timer_display():
	var minutes = floor(time_left / 60.0)
	var seconds = fmod(time_left, 60.0)
	timer_label.text = "%02d:%02d" % [minutes, seconds]  # Plain text, no BBCode
	if time_left < 30.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red when under 30 seconds
	else:
		timer_label.add_theme_color_override("font_color", Color(1, 1, 0))  # Yellow otherwise

func game_over():
	is_running = false
	get_tree().change_scene_to_file("res://gameEND.tscn")

func _on_end_reached():
	is_running = false
	#get_tree().change_scene_to_file("res://victory.tscn")
