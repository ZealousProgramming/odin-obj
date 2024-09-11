package odin_obj

import fmt "core:fmt"
import log "core:log"
import mem "core:mem"

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
	context.logger = log.create_console_logger(log.Level.Info)

	// Do stuff
	// load_obj_from_filepath("./assets/cube/cube-no-mat.obj")
	load_obj_from_filepath("./assets/cube/cube.obj")

	log.destroy_console_logger(context.logger)

	for _, leak in track.allocation_map {
		fmt.println("%v leaked %v bytes\n", leak.location, leak.size)
	}

	for bad_free in track.bad_free_array {
		fmt.printf(
			"%p allocation %p was freed incorrectly\n",
			bad_free.location,
			bad_free.memory,
		)
	}
}
