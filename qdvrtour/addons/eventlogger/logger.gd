@tool
extends EditorPlugin

var log_dock : VBoxContainer
var tree : Tree

var root : Node = EditorInterface.get_base_control()

const CONFIG_PATH := "res://addons/eventlogger/config.json"
var signal_config : Dictionary = {}  # Dictionary to hold config in memory

var is_recording : bool = false
var recording_start_time : float = 0.0
var record_button : Button = Button.new()
var print_console_checkbox : CheckBox = CheckBox.new()


var log_folder_path : String = "res://addons/eventlogger/log/"
var log_count : int = 0

var print_to_console : bool = false

var has_started : bool = false

func get_file_count_in_folder(path: String) -> int:
	var dir := DirAccess.open(path)
	if not dir:
		push_error("Failed to open directory: " + path)
		return 0
	var count := 0
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			count += 1
		file_name = dir.get_next()
	dir.list_dir_end()

	return count

func _enter_tree():
	call_deferred("on_editor_ready")

func on_editor_ready():
	build_ui()
	_load_signal_config()
	add_control_to_bottom_panel(log_dock, "Editor Logger")
	get_tree().connect("node_added", _on_node_added)
	record_button.emit_signal("pressed")
	pass

func _exit_tree():
	log_dock.queue_free()
	tree.queue_free()
	get_tree().disconnect("node_added", _on_node_added)
	remove_control_from_bottom_panel(log_dock)

var editor_classes : Dictionary

func _on_record_button_toggled():
	is_recording = !is_recording
	if is_recording:
		recording_start_time = Time.get_ticks_msec() / 1000.0
		log_count = get_file_count_in_folder(log_folder_path)
		var file := FileAccess.open(log_folder_path + "log_" + str(log_count) + ".csv", FileAccess.WRITE)
		file.seek_end()
		file.store_line("Timestamp,ClassName,Signal,NodeName,NodeTag")
		file.close()
		record_button.text = "🔴 Recording"
	else:
		record_button.text = "▶️ Start Recording"
		log_count += 1

func _on_print_checkbox_pressed():
	print_to_console = !print_to_console

func _format_timestamp() -> String:
	var elapsed := Time.get_ticks_msec() / 1000.0 - recording_start_time
	var minutes := int(elapsed / 60)
	var seconds := int(elapsed) % 60
	var milliseconds := int((elapsed - int(elapsed)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func build_ui() -> void :
	log_dock = VBoxContainer.new()
	log_dock.name = "Editor Logger"
	
	record_button.text = "▶️ Start Recording"
	record_button.pressed.connect(_on_record_button_toggled)
	record_button.toggle_mode = true
	
	var button_container : HBoxContainer = HBoxContainer.new()
	
	print_console_checkbox.text = "Print to Console"
	print_console_checkbox.pressed.connect(_on_print_checkbox_pressed)
	
	record_button.text = "▶️ Start Recording"
	if not record_button.pressed.is_connected(_on_record_button_toggled) :
		record_button.pressed.connect(_on_record_button_toggled)
	record_button.toggle_mode = true
	
	button_container.add_child(print_console_checkbox)
	button_container.add_child(record_button)
	
	log_dock.add_child(button_container)  # Add at the top
	
	
	editor_classes.clear()
	get_all_editor_classes(root)
	editor_classes.sort()
	
	tree = Tree.new()
	tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree.hide_root = true
	tree.connect("item_edited", _on_signal_toggled)
	
	var root_item = tree.create_item()

	for _class_name in editor_classes:
		var signals : Array[Dictionary] = ClassDB.class_get_signal_list(_class_name, true)
		if signals.is_empty() :
			continue
		
		var class_item := tree.create_item(root_item)
		class_item.set_text(0, _class_name)
		
		if _class_name in EditorInterface.get_editor_theme().get_icon_list("EditorIcons") :
			class_item.set_icon(0, EditorInterface.get_editor_theme().get_icon(_class_name, "EditorIcons"))
		else :
			class_item.set_icon(0, EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons"))
		
		for _signal in signals:
			var signal_item := tree.create_item(class_item)
			signal_item.set_metadata(0, {"class_name" : _class_name, "signal_name" : _signal.name})
			signal_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			signal_item.set_text(0, _signal.name)
			signal_item.set_editable(0, true)
			signal_item.set_checked(0, false)
		
		class_item.collapsed = true
		
	log_dock.add_child(tree)

func get_all_parent_classes(_class_name: String) -> Array:
	var parents := []
	while ClassDB.class_exists(_class_name):
		_class_name = ClassDB.get_parent_class(_class_name)
		if _class_name == "":
			break
		parents.append(_class_name)
	return parents


func get_all_editor_classes(node : Node) -> void:
	var _class_name = node.get_class()
	if ClassDB.can_instantiate(_class_name) and ClassDB.is_parent_class(_class_name, "Control"):
		editor_classes[_class_name] = true
		
		for parent in get_all_parent_classes(_class_name):
			if ClassDB.is_parent_class(parent, "Control") :
				editor_classes[parent] = true
			
	for child in node.get_children():
		if child is Node:
			get_all_editor_classes(child)

func _save_signal_config():
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(signal_config, "\t"))  # Pretty JSON
		file.close()

func _apply_config_to_checkboxes():
	for class_item in tree.get_root().get_children() :
		var _class_name : String = class_item.get_text(0)
		if _class_name in signal_config.keys():
			for signal_item in class_item.get_children():
				var signal_name : String = signal_item.get_text(0)
				if signal_name in signal_config[_class_name] :
					if signal_config[_class_name][signal_name] == true :
						signal_item.set_checked(0, true)
						_connect_signal_to_class(_class_name, signal_name, root)

func _load_signal_config():
	if not FileAccess.file_exists(CONFIG_PATH):
		return
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		var parsed := JSON.parse_string(content)
		if typeof(parsed) == TYPE_DICTIONARY:
			signal_config = parsed
			_apply_config_to_checkboxes()
		file.close()

func _on_signal_toggled():
	var signal_item : TreeItem = tree.get_selected()
	var pressed = signal_item.is_checked(0)
	var _class_name = signal_item.get_metadata(0)["class_name"]
	var signal_name = signal_item.get_metadata(0)["signal_name"]
	
	if not signal_config.has(_class_name):
		signal_config[_class_name] = {}
	signal_config[_class_name][signal_name] = pressed
	_save_signal_config()
	
	if pressed:
		_connect_signal_to_class(_class_name, signal_name, root)
	else:
		_disconnect_signal_from_class(_class_name, signal_name, root)

func _connect_signal_to_class(_class_name: String, signal_name: String, node : Node):		
	if node.is_class(_class_name) and not node.is_connected(signal_name, _on_signal_logged.bind(_class_name, signal_name, node)):
		node.connect(signal_name, _on_signal_logged.bind(_class_name, signal_name, node))
	for child in node.get_children():
		_connect_signal_to_class(_class_name, signal_name, child)

func _disconnect_signal_from_class(_class_name: String, signal_name: String, node : Node):
	if node.is_class(_class_name) and node.is_connected(signal_name, _on_signal_logged.bind(_class_name, signal_name, node)):
		node.disconnect(signal_name, _on_signal_logged.bind(_class_name, signal_name, node))
	for child in node.get_children():
		_disconnect_signal_from_class(_class_name, signal_name, child)

func get_node_name(node : Control):
	
	if node.name.substr(0,1) != "@":
		return node.name
	
	if node.tooltip_text:
		if node.get_parent() and node.get_parent() is EditorProperty :
			var editor_property : EditorProperty = node.get_parent()
			return editor_property.get_edited_object().name + " " + editor_property.label + " " + node.tooltip_text.replace("\n", " ")
		
		return node.tooltip_text
	
	if node is BaseButton :
		var node_button : BaseButton = node
		if node_button.shortcut and node_button.shortcut.resource_name:
			return node_button.shortcut.resource_name
	
	if node.get_parent() is EditorProperty:
		var editor_property : EditorProperty = node.get_parent()
		var obj = editor_property.get_edited_object()
		var prop = editor_property.get_edited_property()
		return obj.name + " " + editor_property.label + " = " + (str(obj.get(prop)).pad_decimals(2) if str(obj.get(prop)).is_valid_float() else str(obj.get(prop)))
	
	if node is EditorSpinSlider:
		var spin_slider : EditorSpinSlider = node
		var tmp_node : Node = node
		while tmp_node.get_parent() and not tmp_node is EditorProperty:
			tmp_node = tmp_node.get_parent()
		var editor_property : EditorProperty = tmp_node
		return editor_property.get_edited_object().name + " " + editor_property.label + " " + spin_slider.label + " = " + str(spin_slider.value).pad_decimals(2)
	
	if node is TextEdit:
		var te := node as TextEdit
		var line := te.get_caret_line()
		return "line %d: %s" % [line, te.get_line(line)]

	return ""

func _on_signal_logged(arg1: Variant=null, arg2: Variant=null, arg3: Variant=null, arg4 :Variant=null, arg5 :Variant=null, arg6 :Variant=null):
	if not is_recording :
		return
	
	if typeof(arg1) != TYPE_STRING or not ClassDB.class_exists(arg1):
		arg1 = arg2
		arg2 = arg3
		arg3 = arg4
	
	if typeof(arg1) != TYPE_STRING or not ClassDB.class_exists(arg1):
		arg1 = arg2
		arg2 = arg3
		arg3 = arg4
	
	if typeof(arg1) != TYPE_STRING or not ClassDB.class_exists(arg1):
		arg1 = arg2
		arg2 = arg3
		arg3 = arg4

	var _class_name : String = arg1
	var signal_name : String = arg2
	var node : Node = arg3
	
	var timestamp = _format_timestamp()
	
	if node.name == "ButtonStartLearning" :
		has_started = true
		recording_start_time = Time.get_ticks_msec() / 1000.0
	
	if has_started :
		log_to_file(timestamp + ";" + _class_name + ";" + signal_name + ";" + node.name + ";" + get_node_name(node))
		if print_to_console :
			print("[" + timestamp + "]" + "[" + _class_name + "] " + signal_name + " : " + node.name + " : " + get_node_name(node))

func log_to_file(text: String):
	var file := FileAccess.open(log_folder_path + "log_" + str(log_count) + ".csv", FileAccess.READ_WRITE)
	file.seek_end()
	file.store_line(text)
	file.close()

func _on_node_added(node: Node):
	for _class_name in signal_config.keys():
		if node.is_class(_class_name):
			for signal_name in signal_config[_class_name].keys():
				if not node.is_connected(signal_name, _on_signal_logged.bind(_class_name, signal_name, node)):
					node.connect(signal_name, _on_signal_logged.bind(_class_name, signal_name, node))
