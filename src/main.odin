package main

import "core:fmt"
import "core:math/linalg"
import rl "vendor:raylib"

main :: proc() {
	windowWidth :: 1280
	windowHeight :: 720

	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(windowWidth, windowHeight, "Odin Factory Game")
	defer rl.CloseWindow()
	rl.SetTargetFPS(120)


	camera := rl.Camera2D {
		offset   = {windowWidth / 2.0, windowHeight / 2.0},
		target   = {0, 0},
		rotation = 0.0,
		zoom     = 1.0,
	}

	app := new(App)
	init_app(app)
	defer cleanup_app(app)

	camera.target = app.world.grid_center

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()
		update_animated_texture(&app.conveyor_anim, dt)

		if rl.IsWindowResized() {
			camera.offset = {f32(rl.GetScreenWidth()) / 2, f32(rl.GetScreenHeight()) / 2}
		}

		if rl.IsMouseButtonDown(.LEFT) {
			mouse_pos := rl.GetMousePosition()
			click_pos := click_to_grid(camera)
			set_grid_tile(click_pos, app.player.current_selected, &app.world)
		} else if rl.IsMouseButtonDown(.RIGHT) {
			mouse_pos := rl.GetMousePosition()
			click_pos := click_to_grid(camera)
			set_grid_tile(click_pos, Tile.Air, &app.world)
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
		app.player.pos.x += move.x * speed
		app.player.pos.y += move.y * speed

		camera.target = {app.player.pos.x, app.player.pos.y}


		rl.BeginDrawing()
		rl.ClearBackground({123, 179, 85, 255})
		rl.BeginMode2D(camera)

		// Draw Grid
		for w in 0 ..< GRID_WIDTH {
			for h in 0 ..< GRID_HEIGHT {
				x := i32(w * GRID_SIZE)
				y := i32(h * GRID_SIZE)
				texture := get_grid_texture({i32(w), i32(h)}, app)

				rl.DrawTextureV(texture, {f32(x), f32(y)}, rl.WHITE)
			}
		}

		// Draw Player
		rl.DrawTextureV(
			app.player.texture,
			app.player.pos - {f32(app.player.texture.width), f32(app.player.texture.height)} / 2,
			rl.WHITE,
		)

		rl.EndMode2D()

		// GUI
		draw_gui(app)

		rl.EndDrawing()
		free_all(context.temp_allocator)
	}
}
