extends Node3D

@export var items_to_put_in: Array[Node3D]
var items_spawn_points: Array[Node3D]

func _ready() -> void:
	items_spawn_points = get_spawn_points()
	spawn_items_at_random_points()
	
func spawn_items_at_random_points():
	if items_to_put_in.is_empty() or items_spawn_points.is_empty():
		return

	var available_points: Array[Node3D] = items_spawn_points.duplicate()
	available_points.shuffle()

	var count: int = min(items_to_put_in.size(), available_points.size())
	for i in count:
		var item: Node3D = items_to_put_in[i]
		var point: Node3D = available_points[i]

		# zapamiętaj globalny transform punktu
		var target_transform: Transform3D = point.global_transform

		# przepnij item jako child spawn pointa
		if item.get_parent():
			item.get_parent().remove_child(item)
		point.add_child(item)

		# ustaw globalnie → Godot przeliczy na lokalny względem parenta
		item.global_transform = target_transform
		
func get_spawn_points() -> Array[Node3D]:
	var points: Array[Node3D] = []
	for child in get_children():
		for child2 in child.get_children():
			if child2 is Marker3D:
				points.append(child2)
	return points
