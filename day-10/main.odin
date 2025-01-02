package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:time"

Island :: struct {
	buff:   string,
	width:  int,
	height: int,
}

init_island :: proc(input: string) -> Island {
	width  := strings.index_rune(input, '\n') + 1
	height := len(input) / width

	return Island{input, width, height}
}

coord_to_index :: proc(island: Island, coord: [2]int) -> int {
	return coord.y * island.width + coord.x
}

coord_in_bounds :: proc(island: Island, coord: [2]int) -> bool {
	return coord.x >= 0 && coord.x < island.width - 1 &&
	       coord.y >= 0 && coord.y < island.height
}

get_height :: proc(island: Island, coord: [2]int) -> int {
	index  := coord_to_index(island, coord)
	height := int(island.buff[index] - '0')

	return height
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
	island   := init_island(input)
	stack    := make([dynamic][2]int)
	goal_set := make(map[[2]int]struct{})

	defer {
		delete(stack)
		delete(goal_set)
	}

	score_sum := 0

	for y in 0..<island.height {
		for x in 0..<island.width - 1 {
			trailhead    := [2]int{x, y}
			start_height := get_height(island, trailhead)

			if start_height != 0 {
				continue
			}

			// flood fill to find the score of the trailhead
			append(&stack, trailhead)

			for len(stack) > 0 {
				@(static, rodata)
				dirs := [4][2]int{
					{0, -1},
					{0, +1},
					{-1, 0},
					{+1, 0},
				}

				coord  := pop(&stack)
				height := get_height(island, coord)

				for dir in dirs {
					next_coord := coord + dir

					if !coord_in_bounds(island, next_coord) {
						continue
					}

					next_height := get_height(island, next_coord)

					if next_height != height + 1 {
						continue
					}

					if next_height == 9 {
						goal_set[next_coord] = {}
						continue
					}

					append(&stack, next_coord)
				}
			}

			score_sum += len(goal_set)
			clear(&goal_set)
		}
	}

	return score_sum
}

part_2 :: proc(input: string) -> int {
	island := init_island(input)
	stack  := make([dynamic][2]int)

	defer delete(stack)

	rating_sum := 0

	for y in 0..<island.height {
		for x in 0..<island.width - 1 {
			trailhead    := [2]int{x, y}
			start_height := get_height(island, trailhead)

			if start_height != 0 {
				continue
			}

			// flood fill to find the rating of the trailhead
			append(&stack, trailhead)
			rating := 0

			for len(stack) > 0 {
				@(static, rodata)
				dirs := [4][2]int{
					{0, -1},
					{0, +1},
					{-1, 0},
					{+1, 0},
				}

				coord  := pop(&stack)
				height := get_height(island, coord)

				for dir in dirs {
					next_coord := coord + dir

					if !coord_in_bounds(island, next_coord) {
						continue
					}

					next_height := get_height(island, next_coord)

					if next_height != height + 1 {
						continue
					}

					if next_height == 9 {
						rating += 1
						continue
					}

					append(&stack, next_coord)
				}
			}

			rating_sum += rating
		}
	}

	return rating_sum
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
