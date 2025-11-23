extends "res://addons/godot_tours/tour.gd"

const Gobot := preload("res://addons/godot_tours/bubble/gobot/gobot.gd")

const TEXTURE_BUBBLE_BACKGROUND := preload("res://assets/bubble-background.png")
const TEXTURE_GDQUEST_LOGO := preload("res://assets/gdquest-logo.svg")

const CREDITS_FOOTER_GDQUEST := "[center]Godot Interactive Tours · Made by [url=https://www.gdquest.com/][b]GDQuest[/b][/url] · [url=https://github.com/GDQuest][b]Github page[/b][/url][/center]"

const LEVEL_RECT := Rect2(Vector2.ZERO, Vector2(1920, 1080))
const LEVEL_CENTER_AT := Vector2(960, 540)

# TODO: rather than being constant, these should probably scale with editor scale, and probably.
# be calculated relative to the position of some docks etc. in Godot. So that regardless of their
# resolution, people get the windows roughly in the same place.
# We should write a function for that.
#
# Position we set to popup windows relative to the editor's top-left. This helps to keep the popup
# windows outside of the bubble's area.
const POPUP_WINDOW_POSITION := Vector2i(150, 150)
# We limit the size of popup windows
const POPUP_WINDOW_MAX_SIZE := Vector2i(860, 720)

const ICONS_MAP = {
	node_position_unselected = "res://assets/icon_editor_position_unselected.svg",
	node_position_selected = "res://assets/icon_editor_position_selected.svg",
	script_signal_connected = "res://assets/icon_script_signal_connected.svg",
	script = "res://assets/icon_script.svg",
	script_indent = "res://assets/icon_script_indent.svg",
	zoom_in = "res://assets/icon_zoom_in.svg",
	zoom_out = "res://assets/icon_zoom_out.svg",
	play_button = "res://assets/icon_play_scene.svg",
	add_script_button = "res://assets/icon_add_script.svg",
	open_in_editor = "res://assets/icon_open_in_editor.svg",
	node_signal_connected = "res://assets/icon_signal_scene_dock.svg",
	instantiate_child_scene = "res://assets/Instance.svg"
}

var scene_main := "res://main.tscn"

func _build() -> void:
	# Set editor state according to the tour's needs.
	queue_command(func reset_editor_state_for_tour():
		interface.canvas_item_editor_toolbar_grid_button.button_pressed = false
		interface.canvas_item_editor_toolbar_smart_snap_button.button_pressed = false
		interface.bottom_output_button.button_pressed = false
	)

	steps_intro()
	steps_add_child()
	steps_edit_subscene()
	steps_script()
	steps_conclusion()


func steps_intro() -> void:

	# 0010: introduction
	context_set_3d()
	scene_open(scene_main)
	bubble_move_and_anchor(interface.base_control, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_background(TEXTURE_BUBBLE_BACKGROUND)
	bubble_add_texture(TEXTURE_GDQUEST_LOGO)
	bubble_set_title("")
	bubble_add_text([bbcode_wrap_font_size(gtr("[center][b]Welcome to Godot![/b][/center]"), 32)])
	bubble_add_text(
		[gtr("[center]In this tutorial, you will discover the [b]Godot editor[/b] and its main features.[/center]"),
		gtr("[center]You will modify an existing project to learn how it works.[/center]"),
		gtr("[center][b]Let's get started![/b][/center]"),]
	)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	complete_step()

	# 0020: First look at game you'll make
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Try the game"))
	bubble_add_text(
		[gtr("Click the Run button %s at the top right of the editor to launch the project.") % bbcode_generate_icon_image_string(ICONS_MAP.play_button),
		gtr("To stop the game:"),
		gtr("-On Windows: Press [b]%s[/b] or close the game window.") % shortcuts.stop,
	  	gtr("-On Headset: Press the Meta button and close the game window.")]

	)
	complete_step()

func steps_add_child() -> void:
	# 0030: Start of editor tour
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Let's add a marble"))
	bubble_add_text(
		[gtr("In this tutorial, you will modify a project containing a marble track. Here's what we'll do:"),
		gtr("1. Add a marble to the scene"),
		gtr("2. Add collision physics to the marble"),
		gtr("3. Learn GDScript basics by changing the marble's color based on its speed")]
	)
	complete_step()

	# 0040: central viewport
	highlight_controls([interface.spatial_editor])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Understanding the viewport"))
	bubble_add_text(
		[gtr("The center of the editor shows the viewport. This is where you can see and edit the current [b]scene[/b]."),]
	)
	complete_step()

	# 0041: Adding a child to scene, folders
	highlight_controls([interface.scene_dock])
	#print(interface.scene_dock)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Understanding the scene tree"))
	bubble_add_text(
		[gtr("On the left side of the editor, you'll find the Scene panel. It displays all objects in the current scene."),
		gtr("Objects are organized in a tree structure. Each node (object) has a specific role and responsibility.")]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_instantiate_scene_button])
	highlight_scene_nodes_by_name(["Circuit"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_instantiate_scene("res://GameObjects/Bille.tscn", "Bille", "Circuit")
	bubble_set_title(gtr("Adding the marble to the scene"))
	bubble_add_text(
		[gtr("The marble object [i]Bille.tscn[/i] already exists. Let's add it to our main scene [i]main.tscn[/i]."),
		 gtr("Follow these steps:\n1. Click on the [b]Circuit[/b] node in the scene tree\n2. Click the [b]Instantiate Child Scene[/b] button %s\n3. Select the marble scene in the file browser")% bbcode_generate_icon_image_string(ICONS_MAP.instantiate_child_scene)]
	)
	mouse_move_by_position(interface.scene_dock_instantiate_scene_button.global_position + 2 * interface.scene_dock_instantiate_scene_button.size, interface.scene_dock_instantiate_scene_button.global_position + 2 * interface.scene_dock_instantiate_scene_button.size)
	mouse_click(1)
	mouse_move_by_position(interface.scene_dock_instantiate_scene_button.global_position + 2 * interface.scene_dock_instantiate_scene_button.size, interface.scene_dock_instantiate_scene_button.global_position + 0.5* interface.scene_dock_instantiate_scene_button.size)
	mouse_click(1)
	complete_step()
	
	highlight_controls([interface.scene_dock,interface.spatial_editor])
	highlight_scene_nodes_by_name(["Bille"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Positioning the marble"))
	bubble_add_text(
		[gtr("Now that the marble is in the scene tree, you can manipulate it in the viewport. Simply click on it to select it."),]
	)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit/Bille")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit/Bille")),
	)
	mouse_click(1)
	complete_step()

	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Using the inspector for precise positioning"))
	bubble_add_text(
		[gtr("For more precise control, you can enter position values manually in the Inspector panel."),
		gtr("Navigate to: [b]Node3D[/b] > [b]Transform[/b] > [b]Position[/b]"),
		gtr("To place the marble at the top of the track, use this position:"),
		gtr("[center][b](0.9; 1.3; 0.5)[/b][/center]")]
	)
	complete_step()

	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Why you can't see the marble in-game (yet)"))
	bubble_add_text(
		[gtr("If you run the game now, you won't see the marble. Why? It falls through the ground during loading because it has no collision shape!"),]
	)
	bubble_add_text([gtr("[b]Important: Without a collision shape, the marble will pass through the ground and disappear.[/b]")])

	complete_step()

func steps_edit_subscene() :
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding collision physics"))
	bubble_add_text(
		[gtr("To make the marble interact with the ground and other objects, we need to add a collision shape."),]
	)
	complete_step()
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Circuit/Bille"])
	bubble_set_title(gtr("Understanding scene instances"))
	bubble_add_text([
		gtr("Look at the scene tree. Some nodes like [b]Bille[/b] and [b]Parcours[/b] have an [b]Open in Editor[/b] icon %s next to them.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
		gtr("This icon means the node is an instanced scene. You can create complex scenes by combining multiple child scenes."),
		gtr("Click the [b]Open in Editor[/b] icon %s next to the [b]Bille[/b] node to open and edit the marble scene.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
	])
	bubble_add_task(
		(gtr("Open the [b]Bille[/b] scene.")),
		1,
		func task_open_start_scene(task: Task) -> int:
			var scene_root: Node = EditorInterface.get_edited_scene_root()
			if scene_root == null:
				return 0
			return 1 if scene_root.name == "Bille" else 0
	)
	complete_step()

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_controls([interface.inspector_dock])
	highlight_scene_nodes_by_path(["Bille/CollisionShape3D"])
	bubble_set_title(gtr("Adding the collision shape"))
	bubble_add_text([
		gtr("Follow these steps:\n1. Click on the [b]CollisionShape3D[/b] node\n2. Look at the [b]Shape[/b] property in the Inspector\n3. Click on [b]<empty>[/b] to select a shape\n4. Choose [b]SphereShape3D[/b]")
	])
	bubble_add_task(
		(gtr("Add a [b]SphereShape3D[/b].")),
		1,
		func task_open_start_scene(task: Task) -> int:
			var scene_root: Node = EditorInterface.get_edited_scene_root()
			var collisionShape = scene_root.get_child(0)
			if not collisionShape is CollisionShape3D:
				return 0
			if (collisionShape.shape is SphereShape3D) : 
				return 1
			if (collisionShape.shape is CapsuleShape3D):
				return 1
			return 0 
	)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille/CollisionShape3D")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille/CollisionShape3D"))
	)
	mouse_click(1)
	complete_step()
	
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Testing the marble"))
	bubble_add_text(
		[gtr("Run the game again. The marble now stays on the track and doesn't fall through anymore! However, you won't be able to grab it yet - we'll add that feature next."),]
	)
	complete_step()

func steps_script():
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Adding color changes with code"))
	bubble_add_text(
		[gtr("A script has been written to change the marble's color based on its speed, but we forgot to attach it! Let's fix that."),]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_attach_script_button, interface.script_editor_code_panel])
	highlight_scene_nodes_by_name(["Bille"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Attaching a script"))
	bubble_add_text(
		[gtr("Follow these steps:\n1. Click on the [b]Bille[/b] node\n2. Click the [b]Attach Script[/b] button %s\n3. In the dialog, browse to find [b]ColorChange.gd[/b]\n4. The file path should be: [b]res://GameObjects/ColorChange.gd[/b]\n5. Confirm your selection") % bbcode_generate_icon_image_string(ICONS_MAP.add_script_button)]
	)
	bubble_add_task(
		(gtr("Attach the ColorChange script.")),
		1,
		func task_open_start_scene(task: Task) -> int:
			if interface.script_editor.get_current_script() == preload("res://GameObjects/ColorChange.gd"):
				return 1
			else:
				return 0
	)

	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille"))
	)
	mouse_click(1)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille")),
		get_control_global_center.bind(interface.scene_dock_attach_script_button)
	)
	mouse_click(1)
	complete_step()

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Circuit/Bille"])
	bubble_set_title(gtr("Opening the script"))
	bubble_add_text([
		gtr("Notice that [b]Bille[/b] now has an [b]Open Script[/b] icon %s next to its name. This indicates the node has an attached script.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
		gtr("This icon shows the node has an attached script."),
		gtr("Click the [b]Open Script[/b] icon %s next to the [b]Bille[/b] node to view and edit the script we just attached.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
	])
	complete_step()
	
	context_set_script()
	highlight_code(4, 5)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Understanding the ColorChange class"))
	bubble_add_text([
		gtr("This class defines [b]ColorChange[/b], which extends [b]XRToolsPickable[/b]. This allows us to grab the marble in VR."),
		gtr("The code is written in [b]GDScript[/b], an interpreted language with Python-like syntax."),
	])
	complete_step()
	
	context_set_script()
	highlight_code(7, 14)
	highlight_code(22, 23)
	highlight_code(8, 8)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Declaring color variables"))
	bubble_add_text([
		gtr("Look at line 22. The color change is hardcoded. Let's improve this by using variables."),
		gtr("Here's an example of how to declare a [b]Color[/b] variable:"),
	])
	bubble_add_code(["var variable_name : Color = Color(1,1,1)"])
	bubble_add_text([
		gtr("[b]Task 1: Declare two color variables at the beginning of the script.[/b]"),
		gtr("[b]Task 2: Replace the hardcoded color values with your variables on line 22.[/b]"),
		gtr("Remember to save your changes: [b]File[/b] > [b]Save[/b]")
	])
	complete_step()
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Making colors editable in the Inspector"))
	bubble_add_text([
		gtr("Select the marble and look at the Inspector. The [b]Max Speed[/b] variable is visible, but your color variables are not. Let's fix this!"),
		gtr("Let's quickly fix that."),
	])
	complete_step()
	
	context_set_script()
	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.BOTTOM_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Using the @export annotation"))
	bubble_add_text([
		gtr("Look at the [b]Max Speed[/b] variable declaration. Notice it has [b]@export[/b] in front of it. This makes the variable editable in the Inspector."),
		gtr("[b]Task: Add @export in front of your color variables.[/b]"),
		gtr("Remember to save your changes: [b]File[/b] > [b]Save[/b]")
	])
	complete_step()
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Refreshing the editor"))
	bubble_add_text([
		gtr("To see your changes in the editor, you need to refresh the node."),
		gtr("Simply click on another node, then click back on the node you want to refresh."),
	])
	highlight_scene_nodes_by_name(["Bille","CollisionShape3D"])
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille/CollisionShape3D")),
	)
	mouse_click(1)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille/CollisionShape3D")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Bille")),
	)
	mouse_click(1)
	complete_step()
	
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Making colors editable in the Inspector"))
	bubble_add_text([
		gtr("You can now edit the colors directly from the Inspector!"),
	])
	complete_step()
	
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Testing your work"))
	bubble_add_text(
		[gtr("Launch the game one last time. You should be able to grab the marble and see it change to the colors you defined!"),
		gtr("Troubleshooting: If your colors don't appear, return to the [b]main[/b] scene and check the variable values of the [b]Bille[/b] instance in the Inspector.")]
	)
	complete_step()


func steps_conclusion() -> void:
	context_set_2d()
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("What you've learned"))
	bubble_add_text(
		[
			gtr("You've learned how to navigate and identify key parts of the Godot interface."),
			gtr("You now understand what scenes, nodes, and scripts are and how they work together."),
			gtr("You've successfully instanced a child scene, attached a script, and modified its code!")
		]
	)
	complete_step()

	bubble_move_and_anchor(interface.main_screen)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	queue_command(func set_avatar_happy() -> void:
		bubble.avatar.set_expression(Gobot.Expressions.HAPPY)
	)
	bubble_set_background(TEXTURE_BUBBLE_BACKGROUND)
	bubble_add_texture(TEXTURE_GDQUEST_LOGO)
	bubble_set_title("")
	bubble_add_text([bbcode_wrap_font_size(gtr("[center][b]Congratulations![/b][/center]"), 32)])
	bubble_add_text([
		gtr("[center]What did you think of this tutorial?[/center]"),
		gtr("[center]Feel free to continue experimenting on your own![/center]"),
	])
	bubble_set_footer((CREDITS_FOOTER_GDQUEST))
	complete_step()
