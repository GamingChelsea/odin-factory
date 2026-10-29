package main

ConveyorBelt :: struct {
	start:       [2]i32,
	length:      i32,
	orientation: Orientation,
	items:       [dynamic]Item,
}

new_conveyor :: proc(start: [2]i32, orientation: Orientation, length: i32) -> ConveyorBelt {
	belt_items := make([dynamic]Item, length)
	return ConveyorBelt {
		start = start,
		length = length,
		orientation = orientation,
		items = belt_items,
	}
}
