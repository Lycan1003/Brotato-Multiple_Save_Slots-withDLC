extends Node

var dir = ""
func _init(dirs):
	name = "betterSaver_main_monitor"
	dir = dirs

var save_board = null
func _input(event):
	var trig = false
	if event is InputEventJoypadButton && event.pressed && event.button_index == 10 :
		trig = true
	if event is InputEventKey && event.pressed && event.scancode == KEY_F5:
		trig = true
	if trig:
		if save_board == null || not is_instance_valid(save_board):
			var _error = init_save_board()
			if _error != null:
				save_board.show_focus()
			else:
				print("save_board is null")
			return
		if save_board.visible:
			save_board.show_focus(true)
		else:
			save_board.show_focus()
func _ready():
	var _error = get_tree().connect("node_added",self,"_node_added")

func init_save_board():
	if save_board == null || not is_instance_valid(save_board):
		var now_sceen = get_tree().current_scene
		if now_sceen is Shop || now_sceen is TitleScreen || now_sceen is BaseEndRun:
			save_board = load(dir + "extra/betterSaver.tscn").instance()
			now_sceen.add_child(save_board)
			save_board.init(now_sceen)
			save_board.connect("loading",self,"onLoading")
			return save_board
	return null
var isLoading = false
func onLoading():
	isLoading = true
func _node_added(node):
	if node is Shop:
		yield(node,"ready")
		var _error = init_save_board()
		checkOS(node)
		if _error != null:
			save_board.hide()
			if isLoading:
				isLoading = false
			else:
				save_board.save_game()
	elif node is TitleScreen || node is BaseEndRun:
		yield(node,"ready")
		checkOS(node)
var system_id = "Windows"
func checkOS(node):
	system_id = OS.get_name()
	if system_id  == "Android" || system_id == "iOS":
		var button = load("res://mods-unpacked/Lasonbrah-betterSaver/extra/touchButton.tscn").instance()
		var _main_ui = null
		if node is TitleScreen:
			_main_ui = node.get_node("MarginContainer/Menus")
		else:
			_main_ui = node
		_main_ui.add_child(button)
