package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

App :: struct {
	textures:      map[string]rl.Texture,
	conveyor_anim: AnimatedTexture,
	world:         World,
	player:        Player,
}

init_app :: proc(app: ^App) {
	app.textures = make(map[string]rl.Texture)
	app.conveyor_anim = load_animated_texture("assets/conveyor.gif", 0.2)
	app.textures[strings.clone("conveyor")] = app.conveyor_anim.texture

	app.world = init_world()
	app.player = init_player(app)
}

cleanup_app :: proc(app: ^App) {
	unload_animated_texture(&app.conveyor_anim)
	for k, t in app.textures {
		if k != "conveyor" {
			rl.UnloadTexture(t)
		}
		delete(k)
	}
	delete(app.textures)
	rl.UnloadTexture(app.player.texture)
	free(app)
}

load_texture :: proc(name: string, app: ^App) -> rl.Texture {
	if t, t_ok := app.textures[name]; t_ok {
		return t
	}

	file_path := fmt.ctprintf("assets/%s.png", name)
	t := rl.LoadTexture(file_path)

	if t.id != 0 {
		cached_name := strings.clone(name)
		app.textures[cached_name] = t
	}

	return t
}

AnimatedTexture :: struct {
	image:         rl.Image,
	texture:       rl.Texture2D,
	frames:        i32,
	current_frame: i32,
	timer:         f32,
	frame_delay:   f32,
}

load_animated_texture :: proc(file_path: cstring, frame_delay: f32) -> AnimatedTexture {
	anim: AnimatedTexture
	anim.frame_delay = frame_delay
	anim.image = rl.LoadImageAnim(file_path, &anim.frames)
	anim.texture = rl.LoadTextureFromImage(anim.image)
	return anim
}

update_animated_texture :: proc(anim: ^AnimatedTexture, dt: f32) {
	if anim.frames <= 1 do return

	anim.timer += dt
	if anim.timer >= anim.frame_delay {
		anim.timer -= anim.frame_delay
		anim.current_frame = (anim.current_frame + 1) % anim.frames

		offset := uintptr(anim.image.width * anim.image.height * 4 * anim.current_frame)
		frame_data := rawptr(uintptr(anim.image.data) + offset)

		rl.UpdateTexture(anim.texture, frame_data)
	}
}

unload_animated_texture :: proc(anim: ^AnimatedTexture) {
	rl.UnloadImage(anim.image)
	rl.UnloadTexture(anim.texture)
}
