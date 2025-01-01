package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:time"

Direction :: enum {
	North,
	South,
	East,
	West,
}

Guard :: struct {
	pos: [2]int,
	dir: Direction,
}

Lab :: struct {
	buff:   string,
	width:  int,
	height: int,
}

init_lab :: proc(input: string) -> Lab {
	width  := strings.index_rune(input, '\n') + 1
	height := len(input) / width

	return Lab{input, width, height}
}

pos_to_index :: proc(lab: Lab, pos: [2]int) -> int {
	return pos.y * lab.width + pos.x
}

pos_in_bounds :: proc(lab: Lab, pos: [2]int) -> bool {
	return pos.x >= 0 &&
	       pos.y >= 0 &&
	       pos.x < lab.width - 1 &&
	       pos.y < lab.height
}

get_tile :: proc(lab: Lab, pos: [2]int) -> rune {
	index := pos_to_index(lab, pos)
	tile  := rune(lab.buff[index])

	return tile
}

find_guard :: proc(lab: Lab) -> Guard {
	for y in 0..<lab.height {
		for x in 0..<lab.width - 1 { // ignore newline column
			pos  := [2]int{x, y}
			tile := get_tile(lab, pos)

			switch tile {
				case '^': return Guard{pos, .North}
				case 'v': return Guard{pos, .South}
				case '>': return Guard{pos, .East}
				case '<': return Guard{pos, .West}
				case:
			}
		}
	}

	return Guard{-1, .North}
}

move_guard :: proc(curr: Guard, lab: Lab, extra_obstacle := [2]int{-1, -1}) -> (next: Guard, ok: bool) {
	next_pos := curr.pos

	// figure out which position is in front of the guard
	switch curr.dir {
		case .North: next_pos.y -= 1
		case .South: next_pos.y += 1
		case .East:  next_pos.x += 1
		case .West:  next_pos.x -= 1
	}

	if !pos_in_bounds(lab, next_pos) {
		return Guard{-1, .North}, false
	}

	tile := get_tile(lab, next_pos)

	// if there's an obstacle in front of the guard, turn them right by 90 degrees
	if tile == '#' || next_pos == extra_obstacle {
		next_dir: Direction

		switch curr.dir {
			case .North: next_dir = .East
			case .South: next_dir = .West
			case .East:  next_dir = .South
			case .West:  next_dir = .North
		}

		return Guard{curr.pos, next_dir}, true
	} else { // otherwise move the guard forwards
		return Guard{next_pos, curr.dir}, true
	}

	return
}

get_visited_tiles :: proc(guard: Guard, lab: Lab) -> []bool {
	walk    := true
	guard   := guard
	visited := make([]bool, lab.width * lab.height)

	for walk {
		index := pos_to_index(lab, guard.pos)

		visited[index] = true
		guard, walk = move_guard(guard, lab)
	}

	return visited
}

load_input :: proc(path: string) -> string {
	input_bytes, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("couldn't read input file")
		os.exit(int(os.ERROR_FILE_NOT_FOUND))
	}

	return string(input_bytes)
}

print_solution :: proc(name, input: string, solution_proc: proc(string) -> int) {
	start_tk := time.tick_now()
	solution := solution_proc(input)
	duration := time.tick_since(start_tk)
	millis   := time.duration_milliseconds(duration)

	fmt.printfln("%v: %v, time: %.4fms", name, solution, millis)
}

part_1 :: proc(input: string) -> int {
	lab       := init_lab(input)
	guard     := find_guard(lab)
	visited   := get_visited_tiles(guard, lab)
	positions := slice.count(visited, true)

	delete(visited)
	return positions
}

part_2 :: proc(input: string) -> int {
	lab       := init_lab(input)
	guard     := find_guard(lab)
	positions := 0

	original_visits   := get_visited_tiles(guard, lab)
	obstructed_visits := make([][Direction]bool, lab.width * lab.height)

	defer {
		delete(original_visits)
		delete(obstructed_visits)
	}

	// for each visited tile (except for the guard's starting position) place
	// an extra obstacle there and see if it causes the guard's path to loop
	for y in 0..<lab.height {
		for x in 0..<lab.width - 1 {
			extra_obstacle := [2]int{x, y}
			if extra_obstacle == guard.pos {
				continue
			}

			obstacle_index := pos_to_index(lab, extra_obstacle)
			if !original_visits[obstacle_index] {
				continue
			}

			slice.fill(obstructed_visits, [Direction]bool{})

			new_guard := guard
			walk := true

			for walk {
				index := pos_to_index(lab, new_guard.pos)

				if obstructed_visits[index][new_guard.dir] { // loop found
					positions += 1
					break
				} else {
					obstructed_visits[index][new_guard.dir] = true
				}

				new_guard, walk = move_guard(new_guard, lab, extra_obstacle)
			}
		}
	}

	return positions
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
