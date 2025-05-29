@tool
extends EditorPlugin


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	print("Right click activated")
	InputMap.load_from_project_settings()
	pass

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("right_click"):
		var click = InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_RIGHT
		click.pressed = true
		click.position = get_window().get_mouse_position()
		Input.parse_input_event(click)
	pass

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
