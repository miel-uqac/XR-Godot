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
		[gtr("Dans l'éditeur, une fenêtre permet d'afficher les différents objets présents dans la scène actuelle."),
		gtr("Ces objets sont organisés sous forme d'arbre avec des noeuds aux responsabilités bien définies.")]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_instanciate_scene_button])
	highlight_scene_nodes_by_name(["Circuit"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_add_task_instantiate_scene("res://GameObjects/Bille.tscn", "Bille", "Circuit")
	bubble_set_title(gtr("Instancier une scène enfant"))
	bubble_add_text(
		[gtr("Comme nous avons déjà créé l'objet [i]Bille.tscn[/i], qui est donc une scène lui aussi, nous pouvons l'ajouter à notre scène principale [i]main.tscn[/i]."),
		 gtr("Pour cela, deux options s'offrent à vous. Soit, vous glissez la scène depuis la fenêtre du système de fichiers sur le noeud du circuit sachant qu'elle se trouve dans le dossier GameObjects."),
		 gtr("Soit vous cliquez sur le noeud Circuit de la scène puis sur \"Instancier une scène enfant\" pour accéder à une fenêtre de sélection.")]
	)
	mouse_move_by_position(interface.spatial_editor.global_position, interface.scene_dock_instanciate_scene_button.global_position + 2 * interface.scene_dock_instanciate_scene_button.size)
	mouse_click(1)
	mouse_move_by_position(interface.scene_dock_instanciate_scene_button.global_position + 2 * interface.scene_dock_instanciate_scene_button.size, interface.scene_dock_instanciate_scene_button.global_position + 0.5* interface.scene_dock_instanciate_scene_button.size)
	mouse_click(1)
	complete_step()
	
	highlight_controls([interface.scene_dock])
	highlight_scene_nodes_by_name(["Bille"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Déplacer la bille dans la scène"))
	bubble_add_text(
		[gtr("Maintenant que nous avons ajouté la bille à l'arborescence, il suffit de clicker dessus pour pouvoir la manipuler dans le viewport."),]
	)
	mouse_move_by_callable(
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit")),
		get_tree_item_center_by_path.bind(interface.scene_tree, ("Circuit/Bille")),
	)
	mouse_click(1)
	complete_step()

	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Autre alternative"))
	bubble_add_text(
		[gtr("Pour avoir un accès plus fin aux valeurs de position, on peut les rentrer numériquement dans l'inspecteur de la bille."),
		gtr("Dans Node3D>Transform>Position.")]
	)
	complete_step()

	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Présence en jeu"))
	bubble_add_text(
		[gtr("Si on relance le jeu, on peut voir que la bille apparaît brièvement avant de traverser le sol."),]
	)
	complete_step()

func steps_edit_subscene() :
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Ajouter une collision"))
	bubble_add_text(
		[gtr("Pour éviter que la bille traverse le sol et les autres objets de la scène, nous allons lui ajouter une boîte de collision."),]
	)
	complete_step()
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Circuit/Bille"])
	bubble_set_title(gtr("Instance de scène"))
	bubble_add_text([
		gtr("On peut voir que certains noeuds de l'arbre, comme [b]Bille[/b] ou encore [b]Parcours[/b], ont un icon [b]Ouvrir dans l'éditeur[/b] %s sur leur ligne.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
		gtr("Cet icon indique que ce noeud est une scène enfant. On peut instancier de multiples scènes enfant pour composer des scènes plus complexes."),
		gtr("En appuyant sur l'icon [b]Ouvrir dans l'éditeur[/b] %s à côté du noeud [b]Bille[/b] nous allons pouvoir accéder et modifier la scène Bille.") % bbcode_generate_icon_image_string(ICONS_MAP.open_in_editor),
	])
	bubble_add_task(
		(gtr("Ouvrir la scène Bille.")),
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
	bubble_set_title(gtr("Ajoutons la collision"))
	bubble_add_text([
		gtr("Si on clique sur CollisionShape3D, on peut voir l'attribut Shape dans l'éditeur."),
		gtr("Nous allons ajouter une SphereShape3D même si dans l'absolu une CapsuleShape3D conviendrait aussi.")
	])
	bubble_add_task(
		(gtr("Ajouter une SphereShape3D.")),
		1,
		func task_open_start_scene(task: Task) -> int:
			var scene_root: Node = EditorInterface.get_edited_scene_root()
			var collisionShape : CollisionShape3D = scene_root.get_child(0)
			print(collisionShape)
			if collisionShape == null:
				return 0
			if (collisionShape.shape is SphereShape3D) : 
				return 1
			if (collisionShape.shape is CapsuleShape3D):
				return 1
			return 0 
	)
	complete_step()
	
	highlight_controls([interface.run_bar_play_button], true)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_add_task_press_button(interface.run_bar_play_button)
	bubble_set_title(gtr("Vérification en jeu"))
	bubble_add_text(
		[gtr("Si vous placez la bille sur la piste, vous devriez la voir suivre le parcours."),]
	)
	complete_step()

func steps_script() :
	
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	bubble_set_title(gtr("Ajoutons un peu de couleur"))
	bubble_add_text(
		[gtr("Nous avons écrit un script permettant à la bille de changer de couleur en fonction de sa vitesse mais nous avons oublié de l'ajouter à la bille."),]
	)
	complete_step()
	
	highlight_controls([interface.scene_dock_attach_script_button,interface.script_editor_code_panel])
	highlight_scene_nodes_by_name(["Bille"])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.CENTER)
	
	bubble_set_title(gtr("Attacher un script à un noeud"))
	bubble_add_text(
		[gtr("Comme pour l'instanciation d'une scène enfant, nous pouvons attacher le script par drag & drop ou en passant par le bouton."),
		 gtr("Pour la première solution, le script [b]ColorChange.gd[/b] se trouve dans le dossier GameObjects. Il vous suffit de le glisser sur le noeud [b]Bille[/b]"),
		 gtr("Pour la seconde, vous cliquez sur le noeud [b]Bille[/b] puis sur \"Attacher un script\" pour accèder au menu dédié. Dans celui-ci, on parcourt les fichiers pour trouver celui portant le nom [b]ColorChange.gd[/b] (le chemin devrait être : [b]res://GameObjects/ColorChange.gd[/b])")]
	)
	bubble_add_task(
		(gtr("Ajouter le script ColorChange.")),
		1,
		func task_open_start_scene(task: Task) -> int:
			if interface.script_editor.get_current_script() == preload("res://GameObjects/ColorChange.gd") :
				return 1
			else :
				return 0
	)
	complete_step()

	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_LEFT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	highlight_scene_nodes_by_path(["Circuit/Bille"])
	bubble_set_title(gtr("Ouverture de script"))
	bubble_add_text([
		gtr("On peut voir que [b]Bille[/b] a un icon [b]Ouvrir le script[/b] %s sur sa ligne.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
		gtr("Cet icon indique que ce noeud a un script d'attaché."),
		gtr("En appuyant sur l'icon [b]Ouvrir le script[/b] %s à côté du noeud [b]Bille[/b] nous allons pouvoir accéder et modifier le script qu'on vient d'attacher.") % bbcode_generate_icon_image_string(ICONS_MAP.script),
	])
	complete_step()
	
	highlight_code(4, 5)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.BOTTOM_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("La classe ColorChange"))
	bubble_add_text([
		gtr("On peut voir que cette classe défini la classe ColorChange qui hérite de XRToolsPickable ce qui va nous permettre d'attraper la balle en VR."),
		gtr("On peut noter que dans Godot, contrairement à d'autres moteurs de jeu, on ne peut ajouter qu'un script par objet, la balle est donc maintenant de type ColorChanger qui est une sous-classe de RigidBody3D."),
	])
	complete_step()
	highlight_code(8, 9)
	highlight_code(22,22)
	bubble_move_and_anchor(interface.inspector_dock, Bubble.At.TOP_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Déclarer des variables"))
	bubble_add_text([
		gtr("On peut voir que le changement de couleur a été hardcodé, on aimerait plutôt déclarer les deux couleurs dans des variables en début de script."),
		gtr("Voici un exemple de déclaration de variable de type Color."),
	])
	bubble_add_code(["var variable_name : Color = Color(1,1,1)"])
	complete_step()
	
	context_set_3d()
	highlight_controls([interface.inspector_dock])
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.TOP_CENTER)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Accessibilité dans l'inspecteur"))
	bubble_add_text([
		gtr("Dans l'inspecteur, quand notre bille est selectionnée, on voit que sa variable Max Speed est accessible dans l'éditeur mais pas les couleurs que nous venons de mettre."),
		gtr("Corrigeons rapidement cela.")])
	complete_step()
	
	context_set_script()
	highlight_code(8, 9)
	highlight_code(14,14)
	bubble_move_and_anchor(interface.canvas_item_editor, Bubble.At.CENTER_RIGHT)
	bubble_set_avatar_at(Bubble.AvatarAt.LEFT)
	bubble_set_title(gtr("Ajouter les derniers morceaux de codes"))
	bubble_add_text([
		gtr("Comme on peut le voir sur la ligne déclarant Max Speed, il suffit de rajouter un [b]@export[/b] pour rendre la variable accessible dans l'éditeur.")])
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
