extends Node

func parse_command(text: String) -> Dictionary:
	text = text.to_lower()

	# Attack commands
	if "attack" in text or "kill" in text or "hurt" in text:
		return {
			"action": "attack_player"
		}

	# Follow commands
	if "follow" in text:
		return {
			"action": "follow_player"
		}

	# Fetch items
	if "get" in text or "grab" in text or "take" in text:
		return {
			"action": "fetch_item",
			"item": find_item(text),
			"container": find_container(text)
		}

	# Unknown
	return {
		"action": "none"
	}

#tells the ai what the items i saying are 
func find_item(text:String) -> String:
	var items = [
		"sword",
		"sock",
		"key",
		"gun"
	]

	for item in items:
		if item in text:
			return item

	return "unknown"


func find_container(text:String) -> String:
	var containers = [
		"chest",
		"box",
		"locker"
	]

	for container in containers:
		if container in text:
			return container

	return "unknown"
