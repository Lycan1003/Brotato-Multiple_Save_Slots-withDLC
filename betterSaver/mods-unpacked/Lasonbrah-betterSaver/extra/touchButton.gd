extends MyMenuButton

func _ready()->void :
	var _error_focus = connect("focus_entered", self, "on_focus_entered")
	var _error_press = connect("pressed", self, "on_pressed")
	var _error_mouse = connect("mouse_entered", self, "on_mouse_entered")

func _on_TouchScreenButton_pressed():
	var a = InputEventKey.new()
	a.scancode = KEY_F5
	a.pressed = true
	Input.parse_input_event(a)


func _on_Button_pressed():
	_on_TouchScreenButton_pressed() # Replace with function body.
