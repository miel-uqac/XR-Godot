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
		[gtr("[center]In this tutorial, you will be introduced to the [b]Godot editor[/b].[/center]"),
		gtr("[center]You’ll modify an existing project to explore its features.[/center]"),
		gtr("[center][b]Let’s get started ![/b][/center]"),]
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
		gtr("Then, press [b]%s[/b] or close the game window to stop it.") % shortcuts.stop]
	)
	complete_step()

func steps_add_child() -> void:
	# 0030: Start of editor tour
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Let's add a marble"))
	bubble_add_text(
		[gtr("In this tutorial we will make change in a project containing a marble track."),
		gtr("First we will add a marble."),
		gtr("Then we will add collisions on this marble."),
		gtr("Finally we will have an introduction to GDScript, this will allow us to change the color of this marble depending on its speed.")]
	)
	complete_step()

	# 0040: central viewport
	highlight_controls([interface.spatial_editor])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("View of the current scene"))
	bubble_add_text(
		[gtr("At the center of the editor is the viewport showing the current [b]scene[/b]."),]
	)
	complete_step()

	# 0041: Adding a child to scene, folders
	highlight_controls([interface.scene_dock])
	#print(interface.scene_dock)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Scene representation"))
	bubble_add_text(
		[gtr("In the editor, a tab displays the various objects present in the current scene."),
		gtr("These objects are organized in a tree structure with nodes that have well-defined responsibilities.")]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_instantiate_scene_button])
	highlight_scene_nodes_by_name(["Circuit"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_instantiate_scene("res://GameObjects/Bille.tscn", "Bille", "Circuit")
	bubble_set_title(gtr("Instantiate a child scene"))
	bubble_add_text(
		[gtr("Since the object [i]Bille.tscn[/i] is already created, it can be added to our main scene [i]main.tscn[/i]."),
		 gtr("Click the [b]Circuit[/b] node in the scene and then [b]Instantiate Child Scene[/b] %s to open the selection window.")% bbcode_generate_icon_image_string(ICONS_MAP.instantiate_child_scene)]
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
	bubble_set_title(gtr("Move the marble in the scene"))
	bubble_add_text(
		[gtr("Now that we’ve added the marble to the hierarchy, just click on it to manipulate it in the viewport."),]
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
	bubble_set_title(gtr("Alternative method"))
	bubble_add_text(
		[gtr("To get more precise control over the position values, you can enter them manually in the marble's inspector."),
		gtr("Go to [b]Node3D[/b] > [b]Transform[/b] > [b]Position[/b]."),
		gtr("To place it at the top of the circuit, use position:"),
		gtr("[center][b](1.2; 1.2; 0)[/b][/center]")]
	)
	complete_step()

	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("In-game presence"))
	bubble_add_text(
		[gtr("If you run the game again, you will not see the marble, the reason is simple it fell through the ground. during the game loading."),]
	)
	complete_step()

func steps_edit_subscene() :
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Add a collision"))
	bubble_add_text(
		[gtr("To prevent the marble from passing through the ground and other objects in the scene, we’ll add a collision box."),]
	)
	complete_step()
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Circuit/Bille"])
	bubble_set_title(gtr("Scene instance"))
	bubble_add_text([
		gtr("You can see that some nodes in the tree, like [b]Bille[/b] and [b]Parcours[/b], have an [b]Open in Editor[/b] icon %s next to them.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
		gtr("This icon indicates that the node is an instanced scene. You can instance multiple child scenes to build more complex ones."),
		gtr("By clicking the [b]Open in Editor[/b] icon %s next to the [b]Bille[/b] node, you’ll be able to open and edit the [b]Bille[/b] scene.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
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
	bubble_set_title(gtr("Let’s add the collision"))
	bubble_add_text([
		gtr("If you click on [b]CollisionShape3D[/b], you can see the [b]Shape[/b] property in the inspector."),
		gtr("We’ll add a [b]SphereShape3D[/b]. To select a new shape you have to click on [b]<empty>[/b].")
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
	bubble_set_title(gtr("In-game check"))
	bubble_add_text(
		[gtr("If you placed the marble accurately on the track, you should see it follow the path."),]
	)
	complete_step()

func steps_script():
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Let’s add some color"))
	bubble_add_text(
		[gtr("A script was written in order to change the marble’s color based on its speed, but we forgot to attach it to the marble."),]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_attach_script_button, interface.script_editor_code_panel])
	highlight_scene_nodes_by_name(["Bille"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Attach a script to a node"))
	bubble_add_text(
		[gtr("Click on the [b]Bille[/b] node, then on [b]Attach script[/b] %s to access the dedicated menu. From there, browse to the file named [b]ColorChange.gd[/b] (the path should be: [b]res://GameObjects/ColorChange.gd[/b])") % bbcode_generate_icon_image_string(ICONS_MAP.add_script_button)]
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
	bubble_set_title(gtr("Open the script"))
	bubble_add_text([
		gtr("You can see that [b]Bille[/b] has an [b]Open Script[/b] icon %s next to its name.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
		gtr("This icon shows the node has an attached script."),
		gtr("Clicking the [b]Open Script[/b] icon %s next to the [b]Bille[/b] node lets you access and edit the script we just attached.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
	])
	complete_step()
	
	context_set_script()
	highlight_code(4, 5)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("The ColorChange class"))
	bubble_add_text([
		gtr("You can see this class defines [b]ColorChange[/b] which inherits from [b]XRToolsPickable[/b], allowing us to grab the marble in VR."),
		gtr("The code is written in [b]GDScript[/b] which is an interpreted language that looks like python."),
	])
	complete_step()
	
	context_set_script()
	highlight_code(7, 14)
	highlight_code(22, 22) #TODO : find a way to scroll back left
	highlight_code(8, 8)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Declare variables"))
	bubble_add_text([
		gtr("We can see the color change is hardcoded on line 22."),
		gtr("Here is an example of declaring a variable of type [b]Color[/b]."),
	])
	bubble_add_code(["var variable_name : Color = Color(1,1,1)"])
	bubble_add_text([
		gtr("[b]Declare the two colors as variables at the start of the script.[/b]"),
		gtr("[b]Replace the hardcoded values with the variables[/b]"),
		gtr("Don't forget, you have to save with [b]File[/b] > [b]Save[/b]")
	])
	complete_step()
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Inspector accessibility"))
	bubble_add_text([
		gtr("In the inspector, when the marble is selected, we can see the [b]Max Speed[/b] variable is visible in the editor, but not the color variables we just added."),
		gtr("Let’s quickly fix that."),
	])
	complete_step()
	
	context_set_script()
	highlight_controls([interface.script_editor_code_panel])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.BOTTOM_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Add the last code bits"))
	bubble_add_text([
		gtr("As seen on the [b]Max Speed[/b] line, just add an [b]@export[/b] to make the variable editable in the inspector."),
		gtr("[b]Add @export in front of your color variables.[/b]"),
		gtr("Don't forget, you have to save with [b]File[/b] > [b]Save[/b]")
	])
	complete_step()
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Inspector accessibility"))
	bubble_add_text([
		gtr("You can now edit the colors freely from the inspector."),
	])
	complete_step()
	
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Final game version"))
	bubble_add_text(
		[gtr("If you launch the game one last time, you should be able to grab the marble and see it take on the colors you defined."),
		gtr("If the color you set does not appear, try to go back to the [b]main[/b] scene and check the variable values of this [b]Bille[/b] instance.")]
	)
	complete_step()


func steps_conclusion() -> void:
	context_set_2d()
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("What you’ve built"))
	bubble_add_text(
		[
			gtr("You’ve learned how to identify key parts of the interface."),
			gtr("You’ve also learned what scenes, nodes, and scripts are."),
			gtr("You even instanced a child scene, attached a script, and edited its code.")
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
		gtr("[center]What did you think of the experience?[/center]"),
		gtr("[center]Feel free to experiment on your own![/center]"),
	])
	bubble_set_footer((CREDITS_FOOTER_GDQUEST))
	complete_step()
