extends Node

var is_loading: bool = false
var custom_data: Dictionary = {
	missiles_unlocked = false,
	boss_defeated = false
}

func save_game() -> void:
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)

	save_game.store_line(to_json(custom_data))

	var persistingNodes: Array = get_tree().get_nodes_in_group("Persists")
	for node in persistingNodes:
		var node_data = node.save()
		save_game.store_line(to_json(node_data))

	save_game.close()

func load_game() -> void:
	var save_game = File.new()

	if !save_game.file_exists("user://savegame.save"):
		return

	var persistingNodes: Array = get_tree().get_nodes_in_group("Persists")
	for node in persistingNodes:
		node.queue_free()

	save_game.open("user://savegame.save", File.READ)

	if !save_game.eof_reached():
		custom_data = parse_json(save_game.get_line())

	while !save_game.eof_reached():
		var json_data = save_game.get_line()

		if !json_data:
			continue
		var current_line = parse_json(json_data)

		if current_line:
			var newNode = load(current_line["filename"]).instance()
			get_node(current_line["parent"]).add_child(newNode, true)
			newNode.position = Vector2(current_line["position_x"], current_line["position_y"])

			for property in current_line.keys():
				if (property == "filename" ||
					property == "parent" ||
					property == "position_x" ||
					property == "position_y"):
						continue

				newNode.set(property, current_line[property])
	save_game.close()
