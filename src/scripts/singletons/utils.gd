extends Node


func get_weighted_array_item(array: Array, weights=[]) -> Vector2i:
	if array.is_empty():
		return Vector2i(-1, -1)

	if array.size() == 1:
		return array[0]

	var sum_of_weight = 0.0
	for i in weights:
		sum_of_weight += i
	
	var rnd = randf() * sum_of_weight
	for i in range(array.size()):
		if rnd < weights[i]:
			return array[i]
		rnd -= weights[i]

	# Fallback (shouldn’t happen)
	return array[0]


func instance_scene_on_main(scene, position, rotation=0.0, scale=Vector2.ONE):
	var level_scenes = get_tree().get_nodes_in_group("Level")
	if level_scenes.size() == 0:
		print("can't instance scene, level scene missing")
		return
	
	var level = level_scenes[0]
	var instance = scene.instantiate()
	level.add_child.call_deferred(instance)
	instance.rotation = rotation
	instance.scale = scale
	instance.global_position = position
	return instance


func format_time(time_sec: float) -> String:
	var minutes = int(time_sec / 60)
	var seconds = int(time_sec) % 60
	var ms = int((time_sec - int(time_sec)) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, ms]
