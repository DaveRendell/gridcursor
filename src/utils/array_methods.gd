class_name ArrayMethods

# Zips up a dictionary of array into an array of dictionaries, making it
# easy to iterate over a bunch of similarly indexed arrays.
static func zip(arrays: Dictionary) -> Array[Dictionary]:
	var out = [] as Array[Dictionary]
	for i in arrays.values()[0].size():
		var entry = { "index": i }
		for key in arrays.keys():
			entry[key] = arrays[key][i]
		out.append(entry)
	return out
