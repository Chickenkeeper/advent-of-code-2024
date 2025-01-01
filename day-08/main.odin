package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"
import "core:time"

Antenna :: struct {
	coord: [2]int,
	freq:  rune,
}

Roof :: struct {
	buff:   string,
	width:  int,
	height: int,
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

init_roof :: proc(input: string) -> Roof {
	width  := strings.index_rune(input, '\n') + 1
	height := len(input) / width

	return Roof{input, width, height}
}

coord_to_index :: proc(roof: Roof, coord: [2]int) -> int {
	return coord.y * roof.width + coord.x
}

coord_in_bounds :: proc(roof: Roof, coord: [2]int) -> bool {
	return coord.x >= 0 &&
	       coord.y >= 0 &&
	       coord.x < roof.width - 1 &&
	       coord.y < roof.height
}

get_tile :: proc(roof: Roof, coord: [2]int) -> rune {
	index := coord_to_index(roof, coord)
	tile  := rune(roof.buff[index])

	return tile
}

find_antennas :: proc(roof: Roof) -> [dynamic]Antenna {
	antennas := make([dynamic]Antenna, 0, 8)

	for y in 0..<roof.height {
		for x in 0..<roof.width - 1 {
			coord := [2]int{x, y}
			tile  := get_tile(roof, coord)

			if tile != '.' {
				append(&antennas, Antenna{coord, tile})
			}
		}
	}

	return antennas
}

get_num_antinodes :: proc(input: string, resonant_harmonics: bool) -> int {
	roof      := init_roof(input)
	antennas  := find_antennas(roof)
	antinodes := make([]bool, len(input))

	defer {
		delete(antennas)
		delete(antinodes)
	}

	// loop over every pair of antennas and record the positions of their antinodes
	for antenna_1, i in antennas {
		for antenna_2 in antennas[i + 1:] {
			if antenna_1.freq != antenna_2.freq {
				continue
			}

			offset := antenna_2.coord - antenna_1.coord
			antinode_1 := antenna_1.coord
			antinode_2 := antenna_2.coord

			if resonant_harmonics {
				for coord_in_bounds(roof, antinode_1) {
					antinodes[coord_to_index(roof, antinode_1)] = true
					antinode_1 -= offset
				}

				for coord_in_bounds(roof, antinode_2) {
					antinodes[coord_to_index(roof, antinode_2)] = true
					antinode_2 += offset
				}
			} else {
				antinode_1 -= offset
				antinode_2 += offset

				if coord_in_bounds(roof, antinode_1) {
					antinodes[coord_to_index(roof, antinode_1)] = true
				}

				if coord_in_bounds(roof, antinode_2) {
					antinodes[coord_to_index(roof, antinode_2)] = true
				}
			}
		}
	}

	num_antinode_locs := slice.count(antinodes, true)

	return num_antinode_locs
}

part_1 :: proc(input: string) -> int {
	return get_num_antinodes(input, false)
}

part_2 :: proc(input: string) -> int {
	return get_num_antinodes(input, true)

}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
