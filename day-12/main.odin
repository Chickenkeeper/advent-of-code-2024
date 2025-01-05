package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:time"

Orientation :: enum {
	Horizontal,
	Vertical,
}

Garden :: struct {
	plots:  []int,
	width:  int,
	height: int,
}

coord_to_index :: proc(coord: [2]int, width: int) -> int {
	return coord.y * width + coord.x
}

coord_in_bounds :: proc(coord: [2]int, width, height: int) -> bool {
	return coord.x >= 0 && coord.x < width &&
	       coord.y >= 0 && coord.y < height
}

get_plot :: proc(garden: Garden, coord: [2]int) -> int {
	index := coord_to_index(coord, garden.width)
	return garden.plots[index]
}

// Returns a map of plots much like the puzzle input, but where each region of plants has a unique ID.
init_garden :: proc(input: string) -> (garden: Garden, num_regions: int) {
	garden_width  := strings.index_rune(input, '\n')
	input_width   := garden_width + 1 // includes newline column
	garden_height := len(input) / input_width

	plots := make([]int, garden_width * garden_height)
	stack := make([dynamic][2]int)

	defer delete(stack)

	slice.fill(plots, -1)
	num_regions = 0

	// iterate over each plot in the garden
	for y in 0..<garden_height {
		for x in 0..<garden_width {
			coord := [2]int{x, y}

			// skip if it's already been visited
			if plots[coord_to_index(coord, garden_width)] != -1 {
				continue
			}

			// flood fill to find the region
			append(&stack, coord)
			plant := input[coord_to_index(coord, input_width)]

			for len(stack) > 0 {
				@(static, rodata)
				directions := [4][2]int{
					{-1, 0},
					{+1, 0},
					{0, -1},
					{0, +1},
				}

				curr := pop(&stack)
				input_index := coord_to_index(curr, input_width)
				plots_index := coord_to_index(curr, garden_width)

				// skip if it's been visited or isn't part of the same region
				if plots[plots_index] != -1 || input[input_index] != plant {
					continue
				}

				plots[plots_index] = num_regions

				for dir in directions {
					neighbour := curr + dir

					if coord_in_bounds(neighbour, garden_width, garden_height) {
						append(&stack, neighbour)
					}
				}
			}

			num_regions += 1
		}
	}

	return Garden{plots, garden_width, garden_height}, num_regions
}

delete_garden :: proc(garden: ^Garden) {
	delete(garden.plots)
}

get_areas :: proc(garden: Garden, areas: []int) {
	for region in garden.plots {
		areas[region] += 1
	}
}

get_price :: proc(areas, multipliers: []int) -> int {
	price := 0

	for i in 0..<len(areas) {
		price += areas[i] * multipliers[i]
	}

	return price
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
	garden, num_regions := init_garden(input)

	areas  := make([]int, num_regions)
	perims := make([]int, num_regions)

	defer {
		delete_garden(&garden)
		delete(areas)
		delete(perims)
	}

	get_areas(garden, areas)

	// loop over every pair of adjacent plots and compare them to see
	// if either is part of a perimeter fence (first the horizontal
	// sides, then the vertical sides, including the edges of the garden)
	for orient in Orientation {
		axis_1 := orient == .Horizontal ? garden.height : garden.width
		axis_2 := orient == .Horizontal ? garden.width  : garden.height

		for i in 0..=axis_1 {
			for j in 0..<axis_2 {
				coord_1: [2]int = orient == .Horizontal ? {j, i - 1} : {i - 1, j}
				coord_2: [2]int = orient == .Horizontal ? {j, i    } : {i,     j}

				plot_1 := coord_in_bounds(coord_1, garden.width, garden.height) ? get_plot(garden, coord_1) : -1
				plot_2 := coord_in_bounds(coord_2, garden.width, garden.height) ? get_plot(garden, coord_2) : -1

				// if adjacent plots don't have the same region ID there must be a
				// pair of fences between them, unless a plot is outside the garden
				if plot_1 != plot_2 {
					if plot_1 != -1 do perims[plot_1] += 1
					if plot_2 != -1 do perims[plot_2] += 1
				}
			}
		}
	}

	return get_price(areas, perims)
}

part_2 :: proc(input: string) -> int {
	garden, num_regions := init_garden(input)

	areas := make([]int, num_regions)
	sides := make([]int, num_regions)

	defer {
		delete_garden(&garden)
		delete(areas)
		delete(sides)
	}

	get_areas(garden, areas)

	// loop over every pair of adjacent plots and compare them to find
	// and track the sides of regions (first the horizontal sides, then
	// the vertical sides, including the edges of the garden)
	for orient in Orientation {
		axis_1 := orient == .Horizontal ? garden.height : garden.width
		axis_2 := orient == .Horizontal ? garden.width  : garden.height

		for i in 0..=axis_1 {
			prev_1 := -1
			prev_2 := -1

			for j in 0..<axis_2 {
				coord_1: [2]int = orient == .Horizontal ? {j, i - 1} : {i - 1, j}
				coord_2: [2]int = orient == .Horizontal ? {j, i    } : {i,     j}

				curr_1 := coord_in_bounds(coord_1, garden.width, garden.height) ? get_plot(garden, coord_1) : -1
				curr_2 := coord_in_bounds(coord_2, garden.width, garden.height) ? get_plot(garden, coord_2) : -1

				// if adjacent plots don't have the same region ID, new sides may have been found
				if curr_1 != curr_2 {
					if (prev_1 == prev_2 || curr_1 != prev_1) && curr_1 != -1 do sides[curr_1] += 1
					if (prev_1 == prev_2 || curr_2 != prev_2) && curr_2 != -1 do sides[curr_2] += 1
				}

				prev_1 = curr_1
				prev_2 = curr_2
			}
		}
	}

	return get_price(areas, sides)
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
