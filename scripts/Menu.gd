extends CanvasLayer

var inventory = {}

func _ready():
	# temporary
	$Crafting.modulate.a = 1
	add({ iron = 100, aluminium = 100 })
	
	for component in ['Engine', 'Drill', 'Wheel']:
		var icon = $Crafting.get_node(component).get_node('Icon')
		
		icon.connect('button_down', self, '_on_Icon_button_down', [component])
		icon.connect('mouse_entered', self, '_on_Icon_mouse_entered', [component])
		icon.connect('mouse_exited', self, '_on_Icon_mouse_exited', [component])

func _on_Icon_button_down(component):
	for child in $Crafting.get_node(component).get_node('HBoxContainer').get_children():
		if child is Label and int(child.text) > inventory.get(child.name, 0):
			return
	
	$'../Vehicle'.add_placeholder($Crafting.get_node(component))

func _on_Icon_mouse_entered(component):
	$Crafting.get_node(component).get_node('HBoxContainer').visible = true

func _on_Icon_mouse_exited(component):
	$Crafting.get_node(component).get_node('HBoxContainer').visible = false

func craft(component):
	var items = {}
	
	for child in $Crafting.get_node(component).get_node('HBoxContainer').get_children():
		if child is Label:
			if int(child.text) > inventory.get(child.name, 0):
				return false
			else:
				items[child.name] = int(child.text)
	
	remove(items)
	
	return true

func add(items):
	for item in items:
		if not inventory.has(item):
			var h_box_container = HBoxContainer.new()
			var label = Label.new()
			var texture_rect = TextureRect.new()
			
			texture_rect.texture = preload('res://icon.png') # change to include item
			
			h_box_container.name = item
			h_box_container.set('custom_constants/separation', 16)
			h_box_container.add_child(label, true)
			h_box_container.add_child(texture_rect)
			
			$Inventory.add_child(h_box_container)
			
			inventory[item] = items[item]
			
			label.text = str(inventory[item])
		else:
			inventory[item] += items[item]
			
			$Inventory.get_node(item).get_node('Label').text = str(inventory[item])
	
	tween(false, 1)

func remove(items):
	for item in items:
		inventory[item] -= items[item]
		
		if inventory[item] == 0:
			inventory.erase(item)
			
			$Inventory.get_node(item).queue_free()
		else:
			$Inventory.get_node(item).get_node('Label').text = str(inventory[item])
	
	tween(false, 1)

func tween(crafting_too, target):
	if crafting_too:
		$Crafting.visible = true
		$Tween.interpolate_property($Crafting, 'modulate:a', null, target, abs(target - $Crafting.modulate.a), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	elif target == 1:
		$Timer.start()
	
	$Inventory.visible = true
	$Tween.interpolate_property($Inventory, 'modulate:a', null, target, abs(target - $Inventory.modulate.a), Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Tween_tween_completed(object, key):
	object.visible = object.modulate.a

func _on_Timer_timeout():
	tween(false, 0)
