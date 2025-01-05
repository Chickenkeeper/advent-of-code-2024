package main

import "core:fmt"
import "core:math/linalg"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

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

parse_machine :: proc(machine: string) -> (a, b, prize: [2]int) {
	machine := machine

	i := 0
	for line in strings.split_lines_iterator(&machine) {
		x_start := strings.index_rune(line, 'X') + 2
		y_start := strings.index_rune(line, 'Y') + 2

		x, _ := strconv.parse_int(line[x_start:y_start - 4])
		y, _ := strconv.parse_int(line[y_start:])

		switch i {
			case 0: a = {x, y}
			case 1: b = {x, y}
			case: prize = {x, y}
		}

		i += 1
	}

	return a, b, prize
}

get_machine_tokens :: proc(a, b, prize: [2]int) -> int {
	// Cramer's rule
	determinant := linalg.cross(a, b)
	a_presses   := linalg.cross(prize, b)

	if a_presses % determinant != 0 {
		return 0
	}

	b_presses := linalg.cross(a, prize)

	if b_presses % determinant != 0 {
		return 0
	}

	return (a_presses * 3 + b_presses) / determinant
}

get_all_tokens :: proc(input: string, correct_units: bool) -> int {
	input  := input
	tokens := 0

	for machine in strings.split_iterator(&input, "\n\n") {
		a, b, prize := parse_machine(machine)

		if correct_units {
			prize += 10_000_000_000_000
		}

		tokens += get_machine_tokens(a, b, prize)
	}

	return tokens
}

part_1 :: proc(input: string) -> int {
	return get_all_tokens(input, false)
}

part_2 :: proc(input: string) -> int {
	return get_all_tokens(input, true)
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
