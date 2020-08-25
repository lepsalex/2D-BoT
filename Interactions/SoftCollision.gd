extends Area2D


func is_colliding():
	return get_overlapping_areas().size() > 0


func get_push_vector():
	var areas = get_overlapping_areas()
	if is_colliding():
		var area = areas[0]
		return area.global_position.direction_to(global_position).normalized()
