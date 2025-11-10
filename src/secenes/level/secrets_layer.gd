@tool
extends TileMapLayer

@export var terrain_tilemap: TileMapLayer
@onready var visual_layer: TileMapLayer = $VisualLayer


func _init_secrets() -> void:
	var islands = _get_islands()
	for i in range(len(islands)):
		var island = islands[i]
		_generate_area_for_island(island, i)
		_hide_secret_cells(island)


func _hide_secret_cells(cell_array: Array) -> void:
	for cell_coords in cell_array:
		var source_id = terrain_tilemap.get_cell_source_id(cell_coords)
		if source_id == -1:
			continue
		
		var directions = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1)]
		for direction in directions:
			var visual_cell_coords = cell_coords + direction
			var atlas_coords = terrain_tilemap.get_visual_cell_atlas_coords(visual_cell_coords)
			visual_layer.set_cell(visual_cell_coords, 0, atlas_coords)
	
		terrain_tilemap.set_tile_hidden_area(cell_coords)
	
	for cell_coords in cell_array:
		self.erase_cell(cell_coords)


func _get_islands() -> Array:
	var used = self.get_used_cells()
	var visited := {}
	var islands := []

	for cell in used:
		if cell in visited:
			continue
		
		var island := []
		var stack := [cell]
		
		while stack:
			var current = stack.pop_back()
			if current in visited:
				continue
			visited[current] = true
			island.append(current)

			# Check 4-way or 8-way neighbors depending on your definition
			for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
				var neighbor = current + dir
				if neighbor in used and not neighbor in visited:
					stack.append(neighbor)
		
		islands.append(island)
	
	return islands


func _generate_area_for_island(island: Array, island_index: int) -> void: 
	# Create Area2D for this island
	var area := Area2D.new()
	self.add_child(area)
	area.name = "Island_%d" % island_index
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(5, true)
	area.area_entered.connect(_on_secret_area_entered)
	area.area_exited.connect(_on_secret_area_exited)
	
	# Add CollisionPolygon2D for the whole island
	var polygon := CollisionPolygon2D.new()
	area.add_child(polygon)

	# Convert cell coords → local positions
	var points := []
	var cell_size = self.tile_set.tile_size
	for cell in island:
		var pos = self.map_to_local(cell)
		# You can approximate shape as tile-sized boxes
		points.append_array([
			pos + Vector2(-cell_size.x/2, -cell_size.y/2),
			pos + Vector2(cell_size.x/2, -cell_size.y/2),
			pos + Vector2(cell_size.x/2, cell_size.y/2),
			pos + Vector2(-cell_size.x/2, cell_size.y/2),
		])
	
	# Convex hull: creates a simple outer contour from all tile corners
	points = Geometry2D.convex_hull(points)
	polygon.polygon = points


func _on_secret_area_entered(_area: Area2D):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.1, 0.2) # fade out over 0.5s


func _on_secret_area_exited(_area: Area2D):
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
