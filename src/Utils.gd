extends Node

func instance_scene_on_main(scene: Resource, position: Vector2) -> Object:
	var main: Node = get_parent()
	var instance: Object = scene.instance()

	main.call_deferred("add_child", instance)
	instance.global_position = position

	return instance
