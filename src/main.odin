package main

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

main :: proc() {
	screenWidth :: 1280
	screenHeight :: 720


	rl.InitWindow(screenWidth, screenHeight, "Odin Factory Game")
	defer rl.CloseWindow()

	rl.SetTargetFPS(120)

	camera := rl.Camera2D {
		offset   = {screenWidth / 2.0, screenHeight / 2.0},
		target   = {0, 0},
		rotation = 0.0,
		zoom     = 1.0,
	}

	world := init_world()

	camera.target = world.grid_center

	player := Player {
		pos     = world.grid_center,
		texture = rl.LoadTexture("assets/penguin.png"),
	}


	for !rl.WindowShouldClose() {

		if rl.IsMouseButtonDown(.LEFT) {
			mouse_pos := rl.GetMousePosition()
			click_pos := click_to_grid(camera)
			set_grid_tile(click_pos, Tile.Grass, &world)
		} else if rl.IsMouseButtonDown(.RIGHT) {
			mouse_pos := rl.GetMousePosition()
			click_pos := click_to_grid(camera)
			set_grid_tile(click_pos, Tile.Air, &world)
		}

		if rl.IsKeyPressed(.RIGHT_BRACKET) do camera.zoom += 0.2
		if rl.IsKeyPressed(.SLASH) do camera.zoom -= 0.2

		move: rl.Vector2
		if rl.IsKeyDown(.D) do move.x += 1
		if rl.IsKeyDown(.A) do move.x -= 1
		if rl.IsKeyDown(.W) do move.y -= 1
		if rl.IsKeyDown(.S) do move.y += 1

		if linalg.length(move) > 0 {
			move = linalg.normalize(move)
		}

		speed: f32 = 120.0 * rl.GetFrameTime()
		player.pos.x += move.x * speed
		player.pos.y += move.y * speed

		camera.target = {player.pos.x, player.pos.y}


		rl.BeginDrawing()
		rl.ClearBackground({160, 200, 255, 255})
		rl.BeginMode2D(camera)

		// Draw Grid
		for w in 0 ..< GRID_WIDTH {
			for h in 0 ..< GRID_HEIGHT {
				x := i32(w * GRID_SIZE)
				y := i32(h * GRID_SIZE)
				texture := get_grid_texture({i32(w), i32(h)}, &world)

				rl.DrawTextureV(texture, {f32(x), f32(y)}, rl.WHITE)
			}
		}


		// Draw Player
		rl.DrawTextureV(
			player.texture,
			player.pos - {f32(player.texture.width), f32(player.texture.height)} / 2,
			rl.WHITE,
		)

		rl.EndMode2D()
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
}
