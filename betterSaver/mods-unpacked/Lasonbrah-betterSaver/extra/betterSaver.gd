extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var box = $main/VBoxContainer
var save_path:String
var my_save_path:String
var now_scene = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func show_focus(exit = false):
	if exit:
		hide()
		now_scene = get_tree().current_scene
		if now_scene is Shop:
			now_scene._go_button.grab_focus()
		elif now_scene is BaseEndRun:
			now_scene._new_run_button.grab_focus()
		elif now_scene is TitleScreen:
			now_scene._main_menu.start_button.grab_focus()
	else:
		show()
		var btn = box.get_children().front().get_node("Button")
		btn.grab_focus()

func init(node):
	now_scene = node
	save_path = ProgressData.SAVE_PATH
	my_save_path = ProgressData.SAVE_PATH.replace("save.json","")
	#my_save_path = "user://" + ProgressData.get_user_id() +"/"
	init_save_bar()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init_save_bar(first = true):
	for i in box.get_children():
		var bar_num = Array(i.name.split(" ")).back()
		i.num = bar_num
		var bar_data = get_save(bar_num)
		i.init(bar_data)
		if first:
			i.connect("pressed",self,"_pressed")
func init_act_save_bar():
	var i = box.get_node("Save Data 4")
	var bar_data = get_save("4")
	i.init(bar_data)

func change_save_que():
	var dir = Directory.new()
	var file = File.new()
	if file.file_exists(my_save_path+save_file_name+"2"+save_file_end):
		dir.copy(my_save_path+save_file_name+"2"+save_file_end, my_save_path+save_file_name+"3"+save_file_end)
	if file.file_exists(my_save_path+save_file_name+"1"+save_file_end):
		dir.copy(my_save_path+save_file_name+"1"+save_file_end, my_save_path+save_file_name+"2"+save_file_end)
	file.close()
var save_file_name = "tempsave"
var save_file_end = ".json"
func save_game(actSave = false):
	var num = 1
	if actSave:
		num = 4
#		ProgressData.save_run_state(now_scene._shop_items, now_scene._reroll_price, now_scene._last_reroll_price, now_scene._initial_free_rerolls, now_scene._free_rerolls)
		ProgressData.save_run_state(now_scene.shop_items, now_scene.reroll_count, now_scene.paid_reroll_count, now_scene.initial_free_rerolls, now_scene.free_rerolls, now_scene.item_steals)
#	var current_stats = ProgressDataLoaderV2.serialize_run_state()
	var current_stats = serialize_run_state(ProgressData.get_run_state())
#	var current_stats = serialize_run_state()
	var data_time = OS.get_datetime()
	current_stats["save_time"] = "%s/%s %s:%s"%[data_time["month"],data_time["day"],data_time["hour"],data_time["minute"]]
	if current_stats != null && not current_stats.empty():
		change_save_que()
	var save_file = File.new()
	var _error = save_file.open(my_save_path + save_file_name + str(num) + save_file_end, File.WRITE)
	save_file.store_line(to_json(current_stats))
	save_file.close()
	if actSave:
		init_act_save_bar()
	else:
		init_save_bar(false)
signal loading()
func load_game(wave_data:Dictionary):
	emit_signal("loading")
#	var ddwd = ProgressData.deserialize_run_state(wave_data)
#	loaderV2 = ProgressDataLoaderV2.new()
	var ddwd = deserialize_run_state(wave_data)
	ProgressData.save_run_state(ddwd["shop_items"], ddwd["reroll_count"], ddwd["paid_reroll_count"], ddwd["initial_free_rerolls"], ddwd["free_rerolls"], ddwd["item_steals"])
	RunData.resume_from_state(ddwd)
	var _error = get_tree().change_scene(MenuData.shop_scene)

func get_save(num)->Dictionary:
	var save_file = File.new()
	var error = save_file.file_exists(my_save_path + save_file_name + str(num) + save_file_end)
	if not error:
		print("file not exist!")
		return {}
	save_file.open(my_save_path + save_file_name + str(num) + save_file_end, File.READ)
	var dic = parse_json(save_file.get_line())
	if dic == null:
		print("Error: Invalid JSON format in save file")
		return {}
	save_file.close()
	return dic

func _pressed(d_num):
	var save_bar = box.get_node("Save Data %s"%d_num)
	if save_bar.current_save_data != null && not save_bar.current_save_data.empty():
		load_game(get_save(d_num))
func _on_EXIT_pressed():
	show_focus(true)

func _on_TouchScreenButton_pressed():
	_on_EXIT_pressed()

func _on_TouchScreenButton2_pressed():
	_on_SAVE_pressed()

func _on_SAVE_pressed():
	if now_scene != null && is_instance_valid(now_scene) && now_scene is Shop:
		save_game(true)

func serialize_run_state(state: Dictionary)->Dictionary:
	var result = state.duplicate()

	if not state.has_run_state:
		return result

	if not "current_background" in state:
		result.has_run_state = false
		return result

	result.players_data = []
	for player_data in state.players_data:
		result.players_data.push_back(player_data.serialize())

	if state.current_background != null and state.current_background is BackgroundData:
		result.current_background = state.current_background.name.to_lower()

	result.challenges_completed_this_run = []
	for challenge in state.challenges_completed_this_run:
		result.challenges_completed_this_run.push_back(challenge.my_id)

	result.locked_shop_items = [[], [], [], []]
	for player_index in state.locked_shop_items.size():
		var player_locked_items = state.locked_shop_items[player_index]
		for locked_item in player_locked_items:
			result.locked_shop_items[player_index].push_back([locked_item[0].serialize(), locked_item[1]])

	result.shop_items = [[], [], [], []]
	for player_index in state.shop_items.size():
		var player_shop_items = state.shop_items[player_index]
		for shop_item in player_shop_items:
			result.shop_items[player_index].push_back([shop_item[0].serialize(), shop_item[1]])

	return result

func deserialize_run_state(state: Dictionary)->Dictionary:
	var result = state.duplicate()

	if not state.has_run_state:
		return result

	result.players_data = []
	for serialized_player_data in state.players_data:
		if serialized_player_data is String:
			result.has_run_state = false
			return result
		result.players_data.push_back(PlayerRunData.new().deserialize(serialized_player_data))

	for bg in ItemService.backgrounds:
		if bg.name.to_lower() == state.current_background:
			result.current_background = bg
			break

	result.challenges_completed_this_run = []
	for challenge_id in state.challenges_completed_this_run:
		for chal_data in ChallengeService.challenges:
			if chal_data.my_id == challenge_id:
				result.challenges_completed_this_run.push_back(chal_data)
				break

	result.locked_shop_items = [[], [], [], []]
	for player_index in state.locked_shop_items.size():
		for locked_item in state.locked_shop_items[player_index]:
			var item_data = ItemService.get_element(ItemService.items, locked_item[0].my_id)
			var weapon_data = ItemService.get_element(ItemService.weapons, locked_item[0].my_id)

			if item_data != null:
				item_data = item_data.duplicate()
				item_data.deserialize_and_merge(locked_item[0])
				result.locked_shop_items[player_index].push_back([item_data, locked_item[1]])

			if weapon_data != null:
				weapon_data = weapon_data.duplicate()
				weapon_data.deserialize_and_merge(locked_item[0])
				result.locked_shop_items[player_index].push_back([weapon_data, locked_item[1]])

	result.shop_items = [[], [], [], []]
	for player_index in state.shop_items.size():
		for shop_item in state.shop_items[player_index]:

			if shop_item[0] is String:
				continue

			var item_data = ItemService.get_element(ItemService.items, shop_item[0].my_id)
			var weapon_data = ItemService.get_element(ItemService.weapons, shop_item[0].my_id)

			if item_data != null:
				item_data = item_data.duplicate()
				item_data.deserialize_and_merge(shop_item[0])
				result.shop_items[player_index].push_back([item_data, shop_item[1]])

			if weapon_data != null:
				weapon_data = weapon_data.duplicate()
				weapon_data.deserialize_and_merge(shop_item[0])
				result.shop_items[player_index].push_back([weapon_data, shop_item[1]])

	return result