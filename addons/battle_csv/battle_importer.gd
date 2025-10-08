@tool
extends EditorImportPlugin

func _get_importer_name():
	return "battle.importer"

func _get_visible_name():
	return "Battle Data Importer"

func _get_recognized_extensions():
	return ["bd"]

func _get_save_extension():
	return "tres"

func _get_resource_type():
	return "BattleData"

func _get_import_options(path, preset_index):
	match preset_index:
		_:
			return []

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var headers = file.get_line().split(",") # first row is headers

	if headers.size() != 8:
		return ERR_PARSE_ERROR

	var data := BattleData.new()

	# one enemy per line
	while file.get_position() < file.get_length():
		var line = file.get_line()
		var split = line.split(",")

		var enemy := EnemyData.new()

		enemy.kind       = int(split[0])
		enemy.spawn_time = int(split[1])
		enemy.health     = float(split[2])
		enemy.origin.x   = float(split[3])
		enemy.origin.y   = float(split[4])
		enemy.path       = int(split[5])
		enemy.path_dir   = int(split[6])
		enemy.speed      = float(split[7])

		data.enemies.push_back(enemy)

	return ResourceSaver.save(data, "%s.%s" % [save_path, _get_save_extension()])
