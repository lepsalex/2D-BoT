extends Node2D

func play_grass_effect():
	var grassEffect = load("res://Effects/GrassEffect.tscn").instance()
	get_tree().current_scene.add_child(grassEffect)
	grassEffect.global_position = global_position

func _on_HurtBox_area_entered(area):
	play_grass_effect()
	queue_free()
