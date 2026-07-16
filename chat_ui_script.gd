extends Control

@onready var chat_history = $ChatHistory
@onready var input_box = $InputBox


func _ready():
	hide()
	add_to_group("ChatUI")



func _input(event):
	if event is InputEventMouseButton and event.pressed:
		input_box.release_focus()
		
	if event.is_action_pressed("chat"):
		open_chat()
	 	
	if event.is_action_pressed("pause"):
		close_chat()
		




func open_chat():

	show()

	input_box.show()

	await get_tree().create_timer(0.1).timeout

	input_box.grab_focus()



func close_chat():

	input_box.release_focus()
	input_box.clear()

	hide()

	# give control back to the game
	get_viewport().set_input_as_handled()
	

func add_message(name:String, text:String):

	chat_history.append_text(
		"\n[b]" + name + ":[/b] " + text + "\n"
	)



func _on_input_box_text_submitted(new_text:String):

	if new_text.strip_edges() == "":
		return

	add_message("PLAYER", new_text)

	var npc = get_tree().get_first_node_in_group("level3 npc")

	if npc:
		npc.receive_message(new_text)
#clear the chat box  or not cus it dosnt work for some reason 
	close_chat()
	await get_tree().create_timer(0.1).timeout
	open_chat()
