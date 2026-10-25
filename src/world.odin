package main

import "core:fmt"
import "core:math"
import "core:strings"
import rl "vendor:raylib"

GRID_WIDTH :: 20
GRID_HEIGHT :: 20
GRID_SIZE :: 32

Tile :: enum {
	Air,
	Grass,
}

World :: struct {
	textures:    map[string]rl.Texture,
	grid:        [GRID_WIDTH][GRID_HEIGHT]Tile,
	grid_center: rl.Vector2,
}

init_world :: proc() -> World {
	textures: map[string]rl.Texture = make(map[string]rl.Texture2D)
	grid: [GRID_WIDTH][GRID_HEIGHT]Tile
	for w in 0 ..< GRID_WIDTH {
		for h in 0 ..< GRID_HEIGHT {
			grid[w][h] = .Grass
		}
	}
	grid_center: [2]f32 = {f32(GRID_WIDTH * GRID_SIZE) / 2.0, f32(GRID_HEIGHT * GRID_SIZE) / 2.0}

	return World{textures, grid, grid_center}
}

load_texture :: proc(name: string, world: ^World) -> rl.Texture {
	if t, t_ok := world.textures[name]; t_ok {
		return t
	}

	file_path := fmt.ctprintf("assets/%s.png", name)
	t := rl.LoadTexture(file_path)

	if t.id != 0 {
		cached_name := strings.clone(name)
		world.textures[cached_name] = t
	}

	return t
}

click_to_grid :: proc(camera: rl.Camera2D) -> [2]i32 {
	pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), camera)
	return {i32(math.floor(pos.x / f32(GRID_SIZE))), i32(math.floor(pos.y / f32(GRID_SIZE)))}
}

is_valid_grid_pos :: proc(pos: [2]i32) -> bool {
	return pos.x >= 0 && pos.x < GRID_WIDTH && pos.y >= 0 && pos.y < GRID_HEIGHT
}

set_grid_tile :: proc(pos: [2]i32, tile: Tile, world: ^World) {
	if !is_valid_grid_pos(pos) do return
	world.grid[pos.x][pos.y] = tile
}

get_grid_texture :: proc(pos: [2]i32, world: ^World) -> rl.Texture2D {
	switch world.grid[pos.x][pos.y] {
	case .Air:
		return load_texture("air", world)
	case .Grass:
		return load_texture("grass", world)
	}
	return {}
}
