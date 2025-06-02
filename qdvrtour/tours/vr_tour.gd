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
	open_in_editor = "res://assets/icon_open_in_editor.svg",
	node_signal_connected = "res://assets/icon_signal_scene_dock.svg",
}

var scene_main := "res://main.tscn"

func _build() -> void:
	# Set editor state according to the tour's needs.
	queue_command(func reset_editor_state_for_tour():
		interface.canvas_item_editor_toolbar_grid_button.button_pressed = false
		interface.canvas_item_editor_toolbar_smart_snap_button.button_pressed = false
		interface.bottom_button_output.button_pressed = false
	)

	steps_intro()
	steps_add_child()
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
	bubble_add_text([bbcode_wrap_font_size(gtr("[center][b]Bienvenue dans Godot[/b][/center]"), 32)])
	bubble_add_text(
		[gtr("[center]Dans ce tutoriel, vous serez amené à découvrir [b]l'éditeur Godot[/b].[/center]"),
		gtr("[center]Vous allez modifier un projet existant afin de découvrir les fonctionalités.[/center]"),
		gtr("[center][b]C'est parti![/b][/center]"),]
	)
	bubble_set_footer(CREDITS_FOOTER_GDQUEST)
	queue_command(func avatar_wink(): bubble.avatar.do_wink())
	complete_step()

	# 0020: First look at game you'll make
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Essayer le jeu"))
	bubble_add_text(
		[gtr("Appuyez sur le bouton de lancement en haut à droite de l'éditeur afin de lancer le projet."),
		gtr("Ensuite, appuyez  sur [b]%s[/b] ou fermer la fenêtre du jeu pour l'arrêter.") % shortcuts.stop]
	)
	complete_step()

func steps_add_child() -> void:
	# 0030: Start of editor tour
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Ajoutons une bille"))
	bubble_add_text(
		[gtr("Nous allons maintenant ajouter une bille au jeu."),]
	)
	complete_step()


	# 0040: central viewport
	highlight_controls([interface.spatial_editor])
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Visualisation de la scène actuelle"))
	bubble_add_text(
		[gtr("Au centre de l'éditeur se trouve le viewport qui montre la [b]scène[/b] actuelle."),]
	)
	complete_step()

	# 0041: Adding a child to scene, folders
	highlight_controls([interface.scene_dock])
	print(interface.scene_dock)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Représentation de la scène"))
	bubble_add_text(
		[gtr("Dans l'éditeur, une fenêtre permet d'afficher les différents objets présent dans la scène actuelle."),
		gtr("Ces objets sont organisés sous forme d'arbre avec des noeuds aux responsabilités bien définies.")]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_instanciate_scene_button])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_instantiate_scene("res://GameObjects/Bille.tscn", "Bille", "Circuit")
	bubble_set_title(gtr("Instancier une scène enfant"))
	bubble_add_text(
		[gtr("Comme nous avons déjà créer l'objet [i]Bille.tscn[/i], qui est donc une scène lui aussi, nous pouvons l'ajouter à notre scène principal [i]main.tscn[/i]."),
		 gtr("Pour cela, deux options s'offrent à vous. Soit vous glissez la scène depuis la fenètre du système de fichiers sur le noeud du circuit sachant qu'elle se trouve dans le dossier GameObjects."),
		 gtr("Soit vous cliquez sur le noeud Circuit de la scène puis sur \"Instancier une scène enfant\" pour accèder à une fenêtre de sélection.")]
	)
	mouse_move_by_position(interface.spatial_editor.global_position, interface.scene_dock_instanciate_scene_button.global_position + 2 * interface.scene_dock_instanciate_scene_button.size)
	mouse_click(1)
	mouse_move_by_position(interface.scene_dock_instanciate_scene_button.global_position + 2 * interface.scene_dock_instanciate_scene_button.size, interface.scene_dock_instanciate_scene_button.global_position + 0.5* interface.scene_dock_instanciate_scene_button.size)
	mouse_click(1)
	complete_step()
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Déplacer la bille dans la scène"))
	bubble_add_text(
		[gtr("Maintenant que nous avons ajouté la bille à l'arborescence il suffit de clicker dessus pour pouvoir la manipuler dans la fenêtre centrale."),]
	)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit/Bille")),
	)
	mouse_click(1)
	complete_step()

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Autre alternative"))
	bubble_add_text(
		[gtr(" Pour avoir un accès plus fin aux valeurs de position on peut les rentrer numériquement dans l'inspecteur de la bille"),]
	)

func step_modify_bille():
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr(""))
	bubble_add_text(
		[gtr("Nous allons maintenant ajouter une bille au jeu."),]
	)
	complete_step()

func steps_conclusion() -> void:
	context_set_2d()
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Travail réalisé"))
	bubble_add_text(
		[
			gtr("Listing des tâches réalisées"),
			gtr("[b]Tâche 1 :[/b] description."),
			gtr("...")			
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
	bubble_add_text([bbcode_wrap_font_size(gtr("[center][b]Félicitations![/b][/center]"), 32)])
	bubble_add_text([
		gtr("[center]Qu'avez vous pensé de l'expérience ?[/center]"),
		gtr("[center]N'hésitez pas à expérimenter chez vous ![/center]"),]
	)
	bubble_set_footer((CREDITS_FOOTER_GDQUEST))
	complete_step()
