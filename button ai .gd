extends Control

@onready var input_box = $PlayerInput
@export var npc : Node3D



#send message 

func _on_send_button_pressed():

	var text = input_box.text
	
	npc.receive_message(text)
	

	input_box.clear()
