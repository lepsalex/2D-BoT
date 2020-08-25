extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func play_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_HurtBox_area_entered(_area):
	play_grass_effect()
	queue_free()
