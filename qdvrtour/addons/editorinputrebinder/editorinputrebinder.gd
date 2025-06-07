@tool
extends EditorPlugin

func _input(event):
	if event is InputEventKey and event.keycode == KEY_BACK:
		# Get the current global mouse position (in screen coordinates)
		var mouse_pos = get_viewport().get_mouse_position()
		
		# Simulate a right mouse click (button index 2)
		var right_click_event := InputEventMouseButton.new()
		right_click_event.position = mouse_pos
		right_click_event.global_position = mouse_pos
		right_click_event.button_index = MOUSE_BUTTON_RIGHT
		right_click_event.pressed = event.pressed
		right_click_event.double_click = false
		right_click_event.button_mask = MOUSE_BUTTON_MASK_RIGHT
		
		# Emit the synthetic event
		get_viewport().push_input(right_click_event)
