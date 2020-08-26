enum TileColor{WHITE, BLACK, BLUE, RED, PINK, GREY, GREEN}

static func flat(arr):
	var flat_list = []
	for sublist in arr:
		if sublist:
			for item in sublist:
				flat_list.append(item)
	return flat_list

static func shuffle(arr):
	var shuffled = arr.duplicate()
	shuffled.shuffle()
	var sampled = []
	for i in range(arr.size()):
		sampled.append( shuffled.pop_front() )
	return sampled

static func fixScale(imageSize, viewportSize):
	var scaleFactor = 1
	if viewportSize.aspect() > imageSize.aspect():
		scaleFactor = viewportSize.y/imageSize.y
	else:
		scaleFactor = viewportSize.x/imageSize.x
	return Vector2(scaleFactor,scaleFactor)
