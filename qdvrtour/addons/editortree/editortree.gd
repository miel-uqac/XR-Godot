@tool
extends EditorPlugin

var tree_dock: VBoxContainer
var tree_view: Tree

var eye_icon_visible : Texture2D
var eye_icon_hidden : Texture2D

var highlight_rect := ColorRect.new()

var icons : Dictionary = {}

func _enter_tree():
	call_deferred("on_editor_ready")
	
func on_editor_ready():
	icons["Node"] = EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
	highlight_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	highlight_rect.color = Color(1, 0, 1, 0.25) # Pink, semi-transparent
	highlight_rect.visible = false
	add_child(highlight_rect)
	
	eye_icon_visible = EditorInterface.get_editor_theme().get_icon("GuiVisibilityVisible", "EditorIcons")
	eye_icon_hidden = EditorInterface.get_editor_theme().get_icon("GuiVisibilityHidden", "EditorIcons")
	# Create bottom dock tab
	tree_dock = VBoxContainer.new()
	tree_dock.name = "Editor Tree Container"

	# Add tree view
	tree_view = Tree.new()
	tree_view.name = "Editor Tree"
	tree_view.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tree_view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tree_view.set_hide_root(true)
	tree_view.item_selected.connect(_on_item_selected)
	tree_view.button_clicked.connect(_on_tree_button_clicked)
	tree_view.gui_input.connect(_on_tree_gui_input)
	
	tree_dock.add_child(tree_view)
	add_control_to_bottom_panel(tree_dock, "Editor Tree")
	# Build initial tree
	make_editor_tree()

func _exit_tree():
	remove_control_from_bottom_panel(tree_dock)

func make_editor_tree():
	tree_view.clear()
	var root = get_tree().get_root()
	var editor_root = root.get_child(0)  # usually the editor UI root
	var root_item = tree_view.create_item()
	add_tree_items(editor_root, root_item)

func _on_node_added(node : Node):
	print("Node added : ", node.name)

func _on_any_signal(_class_name: String, signal_name: String, varargs = []) -> void:
	print("Signal emitted -> Class: %s, Signal: %s, Args: %s" % [_class_name, signal_name, varargs])

func add_tree_items(node: Node, parent_item: TreeItem):
	var can_toggle := (node is CanvasItem or node is Node3D or node is Window)
	#if not can_toggle and node.get_children().size() == 0:
	#	return
	
	var item = tree_view.create_item(parent_item)
	item.collapsed = true
	item.set_text(0, node.name + " (" + node.get_class() + ")")
	item.set_metadata(0, node)
	
	var _class_name := node.get_class()
	
	if not (_class_name in icons) :
		if _class_name in EditorInterface.get_editor_theme().get_icon_list("EditorIcons") :
			icons[_class_name] = EditorInterface.get_editor_theme().get_icon(_class_name, "EditorIcons")
		else :
			icons[_class_name] = icons["Node"]
	item.set_icon(0, icons[_class_name])
	
	if can_toggle :
		item.add_button(0, eye_icon_visible)
		item.set_button(0, 0, eye_icon_visible if node.visible else eye_icon_hidden)
		item.set_button_color(0, 0, Color.WHITE if node.visible else Color(1,1,1,0.4))
	
	item.set_selectable(0, true)
	
	for child in node.get_children():
		if child is Node:
			add_tree_items(child, item)

func _on_tree_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index : int):
	var node: Node = item.get_metadata(0)
	if node and (node is CanvasItem or node is Node3D or node is Window):
		node.visible = not node.visible
		item.set_button(column, id, eye_icon_visible if node.visible else eye_icon_hidden)
		item.set_button_color(column, id, Color.WHITE if node.visible else Color(1,1,1,0.4))

var last_hovered_item : TreeItem = null

func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pos = event.position
		var hovered_item = tree_view.get_item_at_position(pos)
		
		if hovered_item and hovered_item != last_hovered_item:
			last_hovered_item = hovered_item

			var node = hovered_item.get_metadata(0) # Assuming metadata holds editor node
			if node is Control:
				show_highlight(node)
			else :
				hide_highlight()
		elif !hovered_item:
			last_hovered_item = null
			hide_highlight()

func _on_item_selected():
	var selected = tree_view.get_selected()
	if selected:
		var node: Node = selected.get_metadata(0)
		EditorInterface.get_inspector().edit(node)

func show_highlight(node: Control):
	var global_rect = node.get_global_rect()
	var editor_root = get_editor_interface().get_base_control()
	var local_position = editor_root.get_global_transform().affine_inverse().basis_xform(global_rect.position)
	
	highlight_rect.set_position(local_position)
	highlight_rect.set_size(global_rect.size)
	highlight_rect.visible = true

func hide_highlight():
	highlight_rect.visible = false

func update_tree(item: TreeItem, parent_visible : bool) -> void:
	var node : Node = item.get_metadata(0)
	if node == null:
		return
	
	var visible : bool = true
	
	if (node is CanvasItem or node is Node3D or node is Window):
		var new_icon := (eye_icon_visible if node.visible else eye_icon_hidden)
		if item.get_button(0, 0) != new_icon:
			item.set_button(0, 0, new_icon)
		var new_color := Color.WHITE if (node.visible and parent_visible) else Color(1,1,1,0.4)
		if item.get_button_color(0, 0) != new_color:
			item.set_button_color(0, 0, new_color)
		visible = node.visible
	
	if not (parent_visible and visible) :#item.collapsed :
		return
	
	var seen_node : Array[Node] = []
	var children_to_remove : Array[TreeItem] = []
	
	for child_item in item.get_children():
		if child_item.get_metadata(0):
			update_tree(child_item, parent_visible and visible)
			seen_node.append(child_item.get_metadata(0))
		else : 
			children_to_remove.append(child_item)
	
	for child in children_to_remove :
		item.remove_child(child)
	
	for child_node in node.get_children():
		if not(child_node in seen_node) :
			add_tree_items(child_node, item)

func _process(_delta: float) -> void:
	update_tree(tree_view.get_root().get_child(0), true)
	pass
