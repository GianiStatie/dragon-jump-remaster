@tool
extends TileMapLayer

@onready var visual_layer: TileMapLayer = $VisualLayer

const hidden_area_atlas_coors = Vector2i(1, 0)
const autotileMap: Array = [
	[Vector2i(0, 0)], 
	[Vector2i(0, 2)], 
	[Vector2i(0, 1)], 
	[Vector2i(2, 0)],
	[Vector2i(1, 0)], 
	[Vector2i(4, 2)], 
	[Vector2i(4, 1)], 
	[Vector2i(2, 2)],
	[Vector2i(3, 2)], 
	[Vector2i(1, 2)], 
	[Vector2i(4, 0)], 
	[Vector2i(2, 1)],
	[Vector2i(3, 1)], 
	[Vector2i(3, 0)], 
	[Vector2i(1, 1), Vector2i(0, 3), Vector2i(1, 3)]
]


func update_visual_tiles(cell_coords: Vector2i) -> void:
	var cell_atlas_coords = self.get_cell_atlas_coords(cell_coords)
	var source_id = cell_atlas_coords.x
	
	var directions = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
	for direction in directions:
		var visual_cell_coords = cell_coords + direction
		var neighbour_count = _get_neighbour_count(visual_cell_coords, self, true)
		if neighbour_count == 0:
			continue
		
		var visual_cell_choices = autotileMap[neighbour_count - 1]
		var visual_cell_probabilities = [1.0]
		if len(visual_cell_choices) > 1:
			visual_cell_probabilities = _get_cell_probabilites(visual_cell_choices, visual_layer, 0)
		var atlas_coords = get_weighted_array_item(visual_cell_choices, visual_cell_probabilities)
		visual_layer.set_cell(visual_cell_coords, source_id, atlas_coords)


func clear_visual_tiles() -> void:
	visual_layer.clear()


func get_visual_cell_atlas_coords(cell_coords: Vector2i) -> Vector2i:
	return visual_layer.get_cell_atlas_coords(cell_coords)


func set_tile_hidden_area(cell_coords: Vector2i) -> void:
	self.set_cell(cell_coords, 0, hidden_area_atlas_coors)
	self.update_visual_tiles(cell_coords)


func _get_neighbour_count(cell_coords: Vector2i, tilemap_layer: TileMapLayer, as_binary: bool = false) -> int:
	# TODO: add same type check
	var neighbours = []
	var directions = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
	for i in range(len(directions)):
		var direction = directions[i]
		var neighbour = tilemap_layer.get_cell_tile_data(cell_coords + direction - Vector2i(1, 1))
		neighbours.insert(0, neighbour != null)
	
	var neighbour_count = 0
	for i in range(len(neighbours)):
		if not neighbours[i]:
			continue
		if as_binary:
			neighbour_count += 2 ** i
		else:
			neighbour_count += 1
	return neighbour_count


func _get_cell_probabilites(atlas_coords: Array, layer: TileMapLayer, source_id: int) -> Array:
	var source = layer.tile_set.get_source(source_id)
	
	var probabilities = []
	for coords in atlas_coords:
		var p = snapped(source.get_tile_data(coords, 0).probability, 0.0001)
		probabilities.append(p)
	return probabilities


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
