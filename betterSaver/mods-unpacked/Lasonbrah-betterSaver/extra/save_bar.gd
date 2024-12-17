extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_save_data:Dictionary = {}
var has_data = false
var num:String = "1"
signal pressed(name)
onready var title = $title
onready var savetime = $saveTime
onready var charactor = $charactor
onready var wave = $wave
onready var gold = $gold
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func init(data):
	if data != null && not data.empty():
		has_data = true
		current_save_data = data
		if num == "4":
			title.text = "手动存档 Active Save Data"
		else:
			title.text = "存档%s Save Data %s"%[num,num]
		savetime.text = data["save_time"]
		var cha_name = data["current_character"]
		for c_data in ItemService.characters:
			if c_data.my_id == cha_name:
				cha_name = c_data.name
				break
		charactor.text = "角色Char：%s"%[tr(cha_name)]
		wave.text = "当前波次Wave：%d"%[data["current_wave"]+1]
		gold.text = "当前金币Glod：%d"%[data["gold"]]
	else:
		has_data = false
		title.text = "无存档 No Save Data"
		savetime.text = "01/01 00:00"
		charactor.text = "角色Char：无"
		wave.text = "当前波次Wave：0"
		gold.text = "当前金币Gold：0"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if has_data:
		emit_signal("pressed",num) # Replace with function body.


func _on_TouchScreenButton_pressed():
	_on_Button_pressed()
