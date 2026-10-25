package main

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

App :: struct {
	textures: map[string]rl.Texture,
	world:    World,
	player:   Player,
}

init_app :: proc(app: ^App) {
	app.textures = make(map[string]rl.Texture)
	app.world = init_world()
	app.player = init_player(app)
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
