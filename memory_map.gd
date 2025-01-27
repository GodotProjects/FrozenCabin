extends TileMap

var board_size = 4
enum Layers{hidden,revealed}
var SOURCE_NUM = 1
const hidden_tile_coords = Vector2(0,1)
const hidden_tile_alt = 1
var revealed_spots = []
var tile_pos_to_atlas_pos = {}
var score = 0
var scene_reset = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if $EatScene.is_visible():
	setup_board()
	update_text() 
		#scene_reset = 1

func _process(delta):
	pass


func get_tiles_to_use():
	var chosen_tile_coords = []
	var options = range(10)
	options.shuffle()
	for i in range(board_size * int(board_size / 2)):
		var current = Vector2(options.pop_back(), 0)
		for j in range(2):
			chosen_tile_coords.append(current)
	chosen_tile_coords.shuffle()
	return chosen_tile_coords
	
func setup_board():
	var cards_to_use = get_tiles_to_use()
	for y in range(board_size):
		for x in range(board_size):
			var current_spot = Vector2(x,y)
			place_single_face_down_card(current_spot)
			var card_atlas_coords = cards_to_use.pop_back()
			tile_pos_to_atlas_pos[current_spot] = card_atlas_coords
			self.set_cell(Layers.revealed, current_spot, SOURCE_NUM, card_atlas_coords)
	
func place_single_face_down_card(coords: Vector2):
	self.set_cell(Layers.hidden, coords, SOURCE_NUM, hidden_tile_coords, hidden_tile_alt)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			var global_clicked = event.position
			var pos_clicked = Vector2(local_to_map(to_local(global_clicked)))
			print(pos_clicked)
			var current_tile_alt = get_cell_alternative_tile(Layers.hidden, pos_clicked)
			if current_tile_alt == 1 and revealed_spots.size() < 2:
				self.set_cell(Layers.hidden, pos_clicked, -1)
				revealed_spots.append(pos_clicked)
				if revealed_spots.size() == 2:
					when_two_cards_revealed()

func when_two_cards_revealed():
	if tile_pos_to_atlas_pos[revealed_spots[0]] == tile_pos_to_atlas_pos[revealed_spots[1]]:
		score += 1
		revealed_spots.clear()
	else:
		put_back_cards_with_delay()
	update_text()
	
func update_text():
	%Eaten.text = "Eaten: " + str(score)
	print(score)
		
func put_back_cards_with_delay():
	await self.get_tree().create_timer(0.75).timeout
	for spot in revealed_spots:
		place_single_face_down_card(spot)
	revealed_spots.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.

#func _on_eat_close_pressed():
#	scene_reset = 0
