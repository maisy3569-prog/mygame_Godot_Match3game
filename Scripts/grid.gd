extends Node2D

# Grid Variables
@export var width:int
@export var height:int
@export var x_start:int
@export var y_start:int
@export var offset:int
@export var y_offset:int

#The piece array
var possible_pieces = [
preload("res://Scenes/yellow_piece.tscn"),
preload("res://Scenes/blue_piece.tscn"),
preload("res://Scenes/pink_piece.tscn"),
preload("res://Scenes/orange_piece.tscn"),
preload("res://Scenes/green_piece.tscn"),
preload("res://Scenes/light_green_piece.tscn")
];

#The current pieces in the scene
var all_pieces = [];

#Touch Variable
var first_touch = Vector2(0, 0)
var final_touch = Vector2(0, 0)
var controlling = false

func _ready() -> void:
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces()
	#print(all_pieces);

func make_2d_array():
	var array = [];
	for i in width:
		array.append([]);
		for j in height:
			array[i].append(null);
	return array;

func spawn_pieces():
	for i in width:
		for j in height:
			#choose a random number and store it
			var rand = randi_range(0, possible_pieces.size()-1) #return a random int 0 to 6-1 <--possible_pieces
			var piece = possible_pieces[rand].instantiate()
			#if there is a match, rand generate again
			var loops = 0
			while(match_at(i, j, piece.color) && loops < 100):
				rand = randi_range(0, possible_pieces.size()-1)
				loops += 1
				piece = possible_pieces[rand].instantiate()
			#Instance that piece from the array
			add_child(piece)
			piece.set_position(grid_to_pixel(i, j))
			all_pieces[i][j] = piece

#check if any match ,when rand generate
func match_at(column, row, color):
	if column > 1:
		if all_pieces[column-1][row] != null && all_pieces[column-2][row] != null:
			if all_pieces[column-1][row].color == color && all_pieces[column-2][row].color == color:
				return true
	if row > 1:
		if all_pieces[column][row-1] != null && all_pieces[column][row-2] != null:
			if all_pieces[column][row-1].color == color && all_pieces[column][row-2].color == color:
				return true
	return false

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
		else:
			print('not ok')
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		all_pieces[column][row] = other_piece
		all_pieces[column + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(column, row))
		find_matches()

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1,0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1,0))
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))


func _process(_delta) -> void:
	touch_input()

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i-1][j] != null && all_pieces[i+1][j] != null:
						if all_pieces[i-1][j].color == current_color && all_pieces[i+1][j].color == current_color:
							all_pieces[i-1][j].matched = true
							all_pieces[i-1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i+1][j].matched = true
							all_pieces[i+1][j].dim()
				if j > 0 && j < height - 1:
					if all_pieces[i][j-1] != null && all_pieces[i][j+1] != null:
						if all_pieces[i][j-1].color == current_color && all_pieces[i][j+1].color == current_color:
							all_pieces[i][j-1].matched = true
							all_pieces[i][j-1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j+1].matched = true
							all_pieces[i][j+1].dim()
	get_parent().get_node('destory_timer').start()

func destory_matched():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	get_parent().get_node('collapse_timer').start()

func collapse_colummns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j+1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node('refill_timer').start()


func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				#choose a random number and store it
				var rand = randi_range(0, possible_pieces.size()-1) #return a random int 0 to 6-1 <--possible_pieces
				var piece = possible_pieces[rand].instantiate()
				#if there is a match, rand generate again
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					rand = randi_range(0, possible_pieces.size()-1)
					loops += 1
					piece = possible_pieces[rand].instantiate()
				#Instance that piece from the array
				add_child(piece)
				piece.set_position(grid_to_pixel(i, j-y_offset))
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece

func _on_destory_timer_timeout() -> void:
	destory_matched()

func _on_collapse_timer_timeout() -> void:
	collapse_colummns()

func _on_refill_timer_timeout() -> void:
	refill_columns()
