package main

import "core:fmt"
import "core:os"
import "core:strings"

load_input :: proc(path: string) -> string {
	input_bytes, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("couldn't read input file")
		os.exit(int(os.ERROR_FILE_NOT_FOUND))
	}

	return string(input_bytes)
}

part_1 :: proc(input: string) -> int {
	columns := strings.index_rune(input, '\n') + 1
	rows    := len(input) / columns
	result  := 0

	// horizontal
	for y in 0..<rows {
		for x in 0..<columns - 4 { // we can ignore the last column since it's the newline character
			index := y * columns + x

			xmas := [4]u8{
				input[index + 0],
				input[index + 1],
				input[index + 2],
				input[index + 3],
			}

			if xmas == "XMAS" || xmas == "SAMX" {
				result += 1
			}
		}
	}

	// vertical
	for y in 0..<rows - 3 {
		for x in 0..<columns - 1 {
			index := y * columns + x

			xmas := [4]u8{
				input[index + columns * 0],
				input[index + columns * 1],
				input[index + columns * 2],
				input[index + columns * 3],
			}

			if xmas == "XMAS" || xmas == "SAMX" {
				result += 1
			}
		}
	}

	// left diagonal
	for y in 0..<rows - 3 {
		for x in 0..<columns - 4 {
			index := y * columns + x

			xmas := [4]u8{
				input[index + 0 + columns * 0],
				input[index + 1 + columns * 1],
				input[index + 2 + columns * 2],
				input[index + 3 + columns * 3],
			}

			if xmas == "XMAS" || xmas == "SAMX" {
				result += 1
			}
		}
	}

	// right diagonal
	for y in 3..<rows {
		for x in 0..<columns - 4 {
			index := y * columns + x

			xmas := [4]u8{
				input[index + 0 - columns * 0],
				input[index + 1 - columns * 1],
				input[index + 2 - columns * 2],
				input[index + 3 - columns * 3],
			}

			if xmas == "XMAS" || xmas == "SAMX" {
				result += 1
			}
		}
	}

	return result
}

part_2 :: proc(input: string) -> int {
	columns := strings.index_rune(input, '\n') + 1
	rows    := len(input) / columns
	result  := 0

	for y in 1..<rows - 1 {
		for x in 1..<columns - 2 {
			index := y * columns + x

			// left diagonal
			mas_1 := [3]u8{
				input[index - 1 - columns],
				input[index],
				input[index + 1 + columns],
			}

			// right diagonal
			mas_2 := [3]u8{
				input[index + 1 - columns],
				input[index],
				input[index - 1 + columns],
			}

			if (mas_1 == "MAS" || mas_1 == "SAM") &&
			   (mas_2 == "MAS" || mas_2 == "SAM") {
				result += 1
			}
		}
	}

	return result
}

main :: proc() {
	input := load_input("input.txt")

	fmt.printfln("part 1: %v", part_1(input))
	fmt.printfln("part 2: %v", part_2(input))
}
