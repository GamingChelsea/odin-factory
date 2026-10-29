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
	Dirt,
	Conveyor,
}

Layers :: enum {
	Ground,
	Objects,
}

Item :: enum {
	None,
	Dirt,
}

Orientation :: enum {
	North,
	East,
	South,
	West,
}

World :: struct {
	grid:         [GRID_WIDTH][GRID_HEIGHT][Layers]Tile,
	grid_center:  rl.Vector2,
	conveyor_ids: [GRID_WIDTH][GRID_HEIGHT]int,
	conveyors:    [dynamic]ConveyorBelt,
	items:        [GRID_WIDTH][GRID_HEIGHT]Item,
}

init_world :: proc() -> World {
	grid: [GRID_WIDTH][GRID_HEIGHT][Layers]Tile
	for w in 0 ..< GRID_WIDTH {
		for h in 0 ..< GRID_HEIGHT {
			grid[w][h][.Ground] = .Grass
		}
	}
	grid_center: [2]f32 = {f32(GRID_WIDTH * GRID_SIZE) / 2.0, f32(GRID_HEIGHT * GRID_SIZE) / 2.0}
	conveyor_ids: [GRID_WIDTH][GRID_HEIGHT]int
	for w in 0 ..< GRID_WIDTH {
		for h in 0 ..< GRID_HEIGHT {
			conveyor_ids[w][h] = -1
		}
	}
	conveyors := make([dynamic]ConveyorBelt)
	items: [GRID_WIDTH][GRID_HEIGHT]Item
	return World {
		grid = grid,
		grid_center = grid_center,
		conveyor_ids = conveyor_ids,
		conveyors = conveyors,
		items = items,
	}
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
	if tile != .Conveyor {
		layer := Layers.Ground
		switch tile {
		case .Air:
			layer = .Objects
			world.conveyor_ids[pos.x][pos.y] = -1
		case .Grass:
			layer = .Ground
		case .Dirt:
			layer = .Ground
		case .Conveyor:
			layer = .Objects
		}
		world.grid[pos.x][pos.y][layer] = tile
	} else {
		place_conveyor_at(pos, .North, world)
	}
}

get_grid_texture :: proc(pos: [2]i32, layer: Layers, app: ^App) -> rl.Texture2D {
	switch app.world.grid[pos.x][pos.y][layer] {
	case .Air:
		return load_texture("air", app)
	case .Grass:
		return load_texture("grass", app)
	case .Dirt:
		return load_texture("dirt", app)
	case .Conveyor:
		return load_texture("conveyor", app)
	}
	return {}
}

get_item_texture :: proc(pos: [2]i32, app: ^App) -> rl.Texture2D {
	switch app.world.items[pos.x][pos.y] {
	case .None:
		return load_texture("air", app)
	case .Dirt:
		return load_texture("dirt", app)
	}
	return {}
}

place_item :: proc(item: Item, pos: [2]i32, world: ^World) {
	if !is_valid_grid_pos(pos) do return
	world.items[pos.x][pos.y] = item
}

place_conveyor_at :: proc(pos: [2]i32, orientation: Orientation, world: ^World) {
	if !is_valid_grid_pos(pos) do return
	if world.conveyor_ids[pos.x][pos.y] != -1 do return

	flow_dir := get_orientation_dir(orientation)

	// Place in front of a existing conveyor
	behind_pos := pos - flow_dir
	if is_valid_grid_pos(behind_pos) {
		id := world.conveyor_ids[behind_pos.x][behind_pos.y]
		if id != -1 {
			belt := &world.conveyors[id]
			belt_head := belt.start + (flow_dir * (belt.length - 1))

			if belt.orientation == orientation && behind_pos == belt_head {
				belt.length += 1
				append(&belt.items, Item.None)

				world.conveyor_ids[pos.x][pos.y] = id
				world.grid[pos.x][pos.y][.Objects] = .Conveyor
				return
			}
		}
	}

	// Place in behind of a existing conveyor
	in_front_pos := pos + flow_dir
	if is_valid_grid_pos(in_front_pos) {
		id := world.conveyor_ids[in_front_pos.x][in_front_pos.y]
		if id != -1 {
			belt := &world.conveyors[id]

			if belt.orientation == orientation && in_front_pos == belt.start {
				belt.start = pos
				belt.length += 1
				inject_at(&belt.items, 0, Item.None)

				world.conveyor_ids[pos.x][pos.y] = id
				world.grid[pos.x][pos.y][.Objects] = .Conveyor
				return
			}
		}
	}

	// No conveyor found -> Creating a new one
	new_belt := new_conveyor(pos, orientation, 1)
	append(&world.conveyors, new_belt)

	new_id := len(world.conveyors) - 1
	world.conveyor_ids[pos.x][pos.y] = new_id
	world.grid[pos.x][pos.y][.Objects] = .Conveyor
}

get_orientation_dir :: proc(orientation: Orientation) -> [2]i32 {
	switch orientation {
	case .North:
		return {0, -1}
	case .East:
		return {1, 0}
	case .South:
		return {0, 1}
	case .West:
		return {-1, 0}
	}
	return {0, 0}
}
get_opposite_orientation :: proc(orientation: Orientation) -> Orientation {
	switch orientation {
	case .North:
		return .South
	case .East:
		return .West
	case .South:
		return .North
	case .West:
		return .East
	}
	return .North
}
