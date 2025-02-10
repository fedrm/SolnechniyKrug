extends Node

var like_btn_texture = load("res://textures/like-btn.png")
var like_btn_active_texture = load("res://textures/like-btn-active.png")
const GAME_DATA_FILE = "user://saved_bookmarks.tres"
var memory_bookmarks = {} # инфа об избранных


func _ready():
	# делаем прозрачной полосу прокрутки у ScrollContainer
	setTransparentScroll()
	# установить ширину слайдов у слайдера
	setSliderChildWidth($Screen5_9/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3/VBoxContainer/ScrollContainer/HBoxContainer)
	# загружаем сохраненныё закладки
	var saved_bookmarks:SavedGame = load(GAME_DATA_FILE) as SavedGame
	if  saved_bookmarks != null:
		for i in saved_bookmarks.node_list:
			memory_bookmarks[i] = saved_bookmarks.node_list[i]


# делаем прозрачной полосу прокрутки у ScrollContainer
func setTransparentScroll():
	$Screen4/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	$Screen5/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	$Screen5_9/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	$Screen5_7/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	$Screen5_6/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)
	$Screen5_5/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3/VBoxContainer/ScrollContainer.get_h_scrollbar().modulate = Color(0, 0, 0, 0)

# установить ширину дочерник блоков у слайдера
func setSliderChildWidth(horizontal_slider):	
	var slider_elem_width = horizontal_slider.get_parent().get_size().x
	for el in horizontal_slider.get_children():
		el.rect_min_size = Vector2(slider_elem_width,819)

func nextSlide(slider_path):
	var tween = create_tween()
	var slider = get_node(slider_path)
	var slider_elem_width = slider.get_size().x
	var slide_width = 0
	if slider.scroll_horizontal == 0:
		slide_width = slider_elem_width
	else:
		slide_width = slider_elem_width + slider.scroll_horizontal
	
	var total_child = slider.get_child(0).get_child_count()
	if slide_width > (total_child-1) * slider_elem_width:
		slide_width = 0

	tween.tween_property(slider, "scroll_horizontal", slide_width, 0.5)

# открыть ИЗБРАННОЕ
func open_favorites(path_to_close, path_to_open):
	var favorites_container = get_node("/root/Control/Screen7/ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer/FavoritesContainer")
	for child_node in favorites_container.get_children():
		favorites_container.remove_child(child_node)
		child_node.queue_free()
	duplicate_favorites_nodes(favorites_container)
		
	var from_screen = get_node(path_to_close)
	var to_screen = get_node(path_to_open)
	from_screen.visible = false
	to_screen.visible = true
	
func duplicate_favorites_nodes(favorites_container):
	for i in memory_bookmarks:
		var parent_node_path = str(memory_bookmarks[i])
		var favorite_node = get_node(parent_node_path).duplicate()
		var like_btn = favorite_node.get_node("HBoxContainer/like")
		like_btn.icon = like_btn_active_texture
		like_btn.text = "3"
		like_btn.connect("pressed", self, "delete_izbran", [parent_node_path, like_btn])
		favorites_container.add_child(favorite_node)

# убрать из ИЗБРАННОЕ
func delete_izbran(delete_node_path, this_btn):
	this_btn.get_parent().get_parent().queue_free()
	var saved_bookmarks:SavedGame = SavedGame.new()
	for i in memory_bookmarks:
		if memory_bookmarks[i] == delete_node_path:
			memory_bookmarks.erase(i)
	
	saved_bookmarks.node_list = memory_bookmarks
	ResourceSaver.save(GAME_DATA_FILE, saved_bookmarks)

# переключение экранов
func go_screen_from_to(path_to_close, path_to_open):
	var from_screen = get_node(path_to_close)
	var to_screen = get_node(path_to_open)
	from_screen.visible = false
	to_screen.visible = true
	
# откр. экран Методичка
func go_metodichka(meta, path_to_close, path_to_open):
	var from_screen = get_node(path_to_close)
	var to_screen = get_node(path_to_open)
	from_screen.visible = false	
	to_screen.visible = true

func pokaz_ekrana_igr(path_to_close, path_to_open):
	var from_screen = get_node(path_to_close)
	var to_screen = get_node(path_to_open)
	var parent_node = to_screen.get_node("ScrollContainer/VBoxContainer/MarginContainer2/VBoxContainer3")

	if memory_bookmarks.empty() != true:
		for children_node in parent_node.get_children():
			var like_btn = children_node.get_node_or_null("HBoxContainer/like")
			if like_btn != null:
				var is_like_active = false
				for i in memory_bookmarks:
					if children_node.get_path() == memory_bookmarks[i]:
						# этот children находиться в закладках
						like_btn.icon = like_btn_active_texture
						like_btn.text = "2"
						is_like_active = true
				if is_like_active == false:
					like_btn.icon = like_btn_texture
					like_btn.text = "1"
	else:
		for children_node in parent_node.get_children():
			var like_btn = children_node.get_node_or_null("HBoxContainer/like")
			if like_btn != null:
				like_btn.icon = like_btn_texture
				like_btn.text = "1"
				
	from_screen.visible = false
	to_screen.visible = true
	
# запуск видео в Инструкции
func play_video(file_name):
	var video_panel = get_node("VideoPanel")
	var video_player = get_node("VideoPanel/AspectRatioContainer/VBoxContainer/VideoPlayer")
	var clip_path = str("res://video/%s" % file_name)
	video_player.stream = load(clip_path)
	video_panel.visible = true
	video_player.play()
	
# остановка видео в Инструкции
func close_video():
	var video_panel = get_node("VideoPanel")
	var video_player = get_node("VideoPanel/AspectRatioContainer/VBoxContainer/VideoPlayer")
	video_player.stop()
	video_panel.visible = false

# переходы по ссылкам из текста
func go_url(meta):
	OS.shell_open(meta)

	
func play_pause():
	var play_btn = get_node("VideoPanel/AspectRatioContainer/VBoxContainer/MarginContainer/HBoxContainer/PlayVideo")	
	var video_player = get_node("VideoPanel/AspectRatioContainer/VBoxContainer/VideoPlayer")
	if video_player.paused == true:
		video_player.paused = false
		play_btn.icon = ResourceLoader.load("res://textures/Pause-Btn.png")
	else:
		video_player.paused = true
		play_btn.icon = ResourceLoader.load("res://textures/Play-Btn.png")

func seek_video(val):
	var video_player = get_node("VideoPanel/AspectRatioContainer/VBoxContainer/VideoPlayer")
	video_player.set_stream_position(val)
	
func openWin1_6(val):
	$Screen5_7.visible = false
	$Screen4_6.visible = true
