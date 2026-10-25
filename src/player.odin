package main

import rl "vendor:raylib"

Player :: struct {
	pos:              [2]f32,
	texture:          rl.Texture2D,
	current_selected: Tile,
}

init_player :: proc(app: ^App) -> Player {
	return Player {
		pos = app.world.grid_center,
		texture = rl.LoadTexture("assets/penguin.png"),
		current_selected = .Grass,
	}
}
