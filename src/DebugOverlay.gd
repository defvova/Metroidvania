extends CanvasLayer

var stats: Array
onready var label := $Label as Label

func add_stats(name: String, object: Object, ref: String, is_method: bool) -> void:
	stats.append([name, object, ref, is_method])
	
func _process(_delta: float) -> void:
	var label_text: String
	
	label_text += get_fps()
	label_text += get_memory()
	
	for s in stats:
		var value
		var name: String = s[0]
		var obj: Object = s[1]
		var method_name: String = s[2]
		var is_method: bool = s[3]
		
		if obj && weakref(obj).get_ref():
			if is_method:
				value = obj.call(method_name)
			else:
				value = obj.get(method_name)
				
		label_text += str(name, ": ", value, "\n")
		
		label.text = label_text

func get_fps() -> String:
	var fps: float = Engine.get_frames_per_second()
	return str("FPS: ", fps, "\n")
	
func get_memory() -> String:
	var mem: int = OS.get_static_memory_usage()
	return str("Static Memory: ", String.humanize_size(mem), "\n")
