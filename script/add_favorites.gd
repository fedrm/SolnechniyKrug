extends Button

var like_btn_texture = load("res://textures/like-btn.png")
var like_btn_active_texture = load("res://textures/like-btn-active.png")
const FILE_NAME = "user://saved_bookmarks.tres"

func _pressed():
	if self.text == "1":
		# добавить в избранное
		self.text = "2"
		self.icon = like_btn_active_texture
		add_bookmark()
	else:
		# убрать из избранного
		self.text = "1"
		self.icon = like_btn_texture
		remove_bookmark()

func add_bookmark():
	var saved_bookmarks:SavedGame = SavedGame.new()
	saved_bookmarks.node_list = get_tree().root.get_child(0).memory_bookmarks
	
	var list_key
	if saved_bookmarks.node_list.size() > 0:
		list_key = str("node_%s" % saved_bookmarks.node_list.size())
	else:
		list_key = "node_0"
	var save_node_path = self.get_parent().get_parent().get_path()
	saved_bookmarks.node_list[list_key] = save_node_path
	
	ResourceSaver.save(FILE_NAME, saved_bookmarks)
	#ResourceSaver.save(FILE_NAME, SavedGame.new())
	get_tree().root.get_child(0).memory_bookmarks = saved_bookmarks.node_list

func remove_bookmark():
	var remove_node_path = self.get_parent().get_parent().get_path()
	var saved_bookmarks:SavedGame = SavedGame.new()
	var memory_bookmarks = get_tree().root.get_child(0).memory_bookmarks
	for i in memory_bookmarks:
		if memory_bookmarks[i] == remove_node_path:
			memory_bookmarks.erase(i)
			break
	
	saved_bookmarks.node_list = memory_bookmarks
	ResourceSaver.save(FILE_NAME, saved_bookmarks)
	get_tree().root.get_child(0).memory_bookmarks = saved_bookmarks.node_list
