extends Node2D

export(int) var w_range = 32

onready var start_pos = global_position
onready var target_pos = global_position
onready var timer = $Timer


func _ready():
	update_target_position()


func update_target_position():
	target_pos = start_pos + Vector2(rand_range(-w_range, w_range), rand_range(-w_range, w_range))


func get_time_left():
	return timer.time_left


func start_wander_timer(duration):
	timer.start(duration)


func _on_Timer_timeout():
	update_target_position()
