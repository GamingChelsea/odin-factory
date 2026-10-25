package main

import "core:fmt"
import rl "vendor:raylib"

draw_gui :: proc(app: ^App) {
	bounds := get_hotbar_bounds()
	btn_size: f32 = bounds.height
	btn_space: f32 = 12


	for i in 0 ..< 5 {
		x := bounds.x + f32(i) * (btn_size + btn_space)
		y := bounds.y

		texture: rl.Texture
		tile: Tile
		switch i {
		case 0:
			{
				texture = load_texture("grass", app)
				tile = .Grass
			}
		case 1:
			{
				texture = load_texture("dirt", app)
				tile = .Dirt
			}
		case 2:
			{
				texture = load_texture("conveyor", app)
				tile = .Conveyor
			}
		}

		if slot_button(texture, x, y, btn_size, btn_size) {
			app.player.current_selected = tile
			fmt.printfln("Button %d clicked", i)
		}
	}
}

get_hotbar_bounds :: proc() -> rl.Rectangle {
	screen_w := f32(rl.GetScreenWidth())
	screen_h := f32(rl.GetScreenHeight())

	btn_count: f32 = 5
	btn_size: f32 = 65
	btn_space: f32 = 12

	total_width := btn_count * btn_size + (btn_count - 1) * btn_space
	start_x := (screen_w - total_width) / 2
	start_y := screen_h - btn_size - 15

	return rl.Rectangle{start_x, start_y, total_width, btn_size}
}

is_mouse_over_gui :: proc() -> bool {
	mouse_pos := rl.GetMousePosition()
	return rl.CheckCollisionPointRec(mouse_pos, get_hotbar_bounds())
}

slot_button :: proc(texture: rl.Texture2D, x, y, w, h: f32) -> bool {
	rec := rl.Rectangle{x, y, w, h}
	mouse_pos := rl.GetMousePosition()
	is_hovered := rl.CheckCollisionPointRec(rl.GetMousePosition(), rec)
	is_pressed := is_hovered && rl.IsMouseButtonDown(.LEFT)

	// Bg
	bg_color := rl.Color{40, 40, 48, 220}
	if is_pressed {
		bg_color = rl.Color{25, 25, 30, 255}
	} else if is_hovered {
		bg_color = rl.Color{65, 65, 78, 240}
	}
	rl.DrawRectangleRec(rec, bg_color)

	// Border
	border_color := is_hovered ? rl.WHITE : rl.Color{90, 90, 100, 255}
	rl.DrawRectangleLinesEx(rec, 2, border_color)

	if texture.id != 0 {
		pad: f32 = 8
		inner := rl.Rectangle{x + pad, y + pad, w - pad * 2, h - pad * 2}
		outer := rl.Rectangle{0, 0, f32(texture.width), f32(texture.height)}
		tint := is_pressed ? rl.LIGHTGRAY : rl.WHITE
		rl.DrawTexturePro(texture, outer, inner, {0, 0}, 0, tint)
	}

	return is_hovered && rl.IsMouseButtonReleased(.LEFT)
}
