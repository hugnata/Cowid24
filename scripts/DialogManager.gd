# Class for handling dialogs
# TODO: Comment
# TODO: Write dialog file reference
extends Node2D

@export_file("*.txt") var dialog_file

var texts: PackedStringArray = []
var labels: Dictionary = {}
@onready var text_edit: TextEdit = $TextEdit
@onready var curr_text: int = 0

var update_display: bool = false
var waiting_for_enter_key = false
var should_exit = false

func start_dialog(f: String):
	dialog_file = f
	texts = []
	labels = {}
	curr_text = 0
	update_display = false
	waiting_for_enter_key = false
	should_exit = false
	var file = FileAccess.open(dialog_file, FileAccess.READ)
	var content: String = file.get_as_text()
	texts = content.split("\n\n")
	text_edit.text = texts[curr_text]
	text_edit.visible = true
	# Populate label dictionnary, to know where to jump on conditionnals
	for i in texts.size():
		var text = texts[i]
		if text.begins_with("<label"):
			var label = process_label(text)
			if label in labels:
				print("[Error] In %s, two labels have the same name %s",
					dialog_file, label)
			labels[label] = i
			var label_end = text.find(">")
			texts[i] = texts[i].substr(label_end + 2)
	update_display = true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if dialog_file != null and dialog_file != "":
		start_dialog(dialog_file)
	
func process_label(text: String) -> String:
	var parser: XMLParser = XMLParser.new()
	parser.open_buffer(text.to_utf8_buffer())
	# If the string is not a valid xml, just display it
	if parser.read() == ERR_FILE_EOF:
		print("[ERROR] Got an invalid label line \"%s\"", text)
		return ""
	var attributes_dict = {}
	for idx in range(parser.get_attribute_count()):
		attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
	if "name" not in attributes_dict:
		print("[ERROR] label line \"%s\" does not have a name attribute", text)
		return ""
	return attributes_dict["name"]
	
func process_if(parser: XMLParser) -> void:
	var attributes_dict = {}
	for idx in range(parser.get_attribute_count()):
		attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
	var canvas_w = text_edit.size[0]
	var canvas_h = text_edit.size[1]
	
	var offset = 12
	if "true_label" in attributes_dict:
		if "true" not in attributes_dict:
			print("[Error] Dialog conditional without a true value")
		var true_button = Button.new()
		true_button.offset_left = offset
		true_button.offset_top = canvas_h - 2*true_button.size[1] - 10
		true_button.text = attributes_dict["true_label"]
		text_edit.add_child(true_button)
		offset += true_button.size[0] + 15
		true_button.pressed.connect(self._button_pressed.bind(attributes_dict["true"]))
		true_button.grab_focus()
		
	if "false_label" in attributes_dict:
		if "false" not in attributes_dict:
			print("[Error] Dialog conditional without a false value")
		var false_button = Button.new()
		false_button.offset_left =  offset
		false_button.offset_top = canvas_h - 2*false_button.size[1]  - 10
		false_button.text = attributes_dict["false_label"]
		text_edit.add_child(false_button)
		false_button.pressed.connect(self._button_pressed.bind(attributes_dict["false"]))
	
	waiting_for_enter_key = false

func process_goto(parser: XMLParser) -> void:
	print("Processing GOTO")
	var attributes_dict = {}
	for idx in range(parser.get_attribute_count()):
		attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
	if "label" not in attributes_dict:
		print("[Error] Dialogs: A goto is missing a label in ", dialog_file, " l")
	var label = attributes_dict["label"]
	if label not in labels:
		print("[Error] Dialogs: Unknown label ", label, " in ", dialog_file)
		return
	curr_text = labels[label]
	waiting_for_enter_key = true
	
func _button_pressed(label: String) -> void:
	if label not in labels:
		print("[Error] Dialogs: Unknown label ", label, " in ", dialog_file)
		return
	for child in text_edit.get_children():
		print(child.get_class())
		if child.is_class("Button"):
			child.queue_free()
	var text_id = labels[label]
	curr_text = text_id
	update_display = true
	

# Called when a caret < is encoutered in a dialog file, meaning we need to do 
# something
func process_action(text: String) -> void:
	var parser: XMLParser = XMLParser.new()
	parser.open_buffer(text.to_utf8_buffer())
	# If the string is not a valid xml, just display it
	if parser.read() == ERR_FILE_EOF:
		print("This is not a valid XML..")
		return
	if parser.get_node_type() == XMLParser.NODE_ELEMENT:
		var node_name = parser.get_node_name()
		match node_name:
			"if":
				process_if(parser)
			"goto":
				process_goto(parser)
			"exit":
				should_exit = true
				waiting_for_enter_key = true
				
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dialog_file == null:
		return
	if (Input.is_action_just_pressed("next_dialog") and waiting_for_enter_key) or update_display:
		if should_exit:
			text_edit.visible = false
			for child in text_edit.get_children():
				child.queue_free()
			dialog_file == null
		waiting_for_enter_key = false
		update_display = false
		var display_text = texts[curr_text]
		text_edit.text = texts[curr_text]
		curr_text += 1
		if curr_text >= texts.size():
			curr_text = texts.size() - 1
		if texts[curr_text].begins_with("<"):
			process_action(texts[curr_text ])
		else:
			waiting_for_enter_key = true
		
