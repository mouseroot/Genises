extends Area3D

@export var itemTypes: Array[ItemData] = []

@export var nearbyItems: Array[InteractableItem]

func pickupNearest():
	var lastDist: float = INF
	var nearestItem: Node3D = null
	for item in nearbyItems:
		if item.global_position.distance_to(global_position) < lastDist:
			lastDist = item.global_position.distance_to(global_position)
			nearestItem = item
	if nearestItem != null:
		nearestItem.queue_free()
		nearbyItems.remove_at(nearbyItems.find(nearestItem))
		var filePrefab = nearestItem.scene_file_path
		for iType in itemTypes:
			if itemTypes[iType].itemPrefab != null and itemTypes[iType].itemPrefab.resource_path == filePrefab:
				print("Item Id: %d -> %s" % [iType, itemTypes[iType].itemName])
				return
		printerr("Did not find an item")
			

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		pickupNearest()

func onEnter(body: Node3D):
	if body is InteractableItem:
		body.Focus()
		nearbyItems.append(body)
		
func onExit(body: Node3D):
	if body in nearbyItems and body is InteractableItem:
		body.UnFocus()
		nearbyItems.remove_at(nearbyItems.find(body))
