package main

import "core:fmt"
import "core:os"
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

is_digit :: proc(r: rune) -> bool {
	return r >= '0' && r <= '9';
}

read_int :: proc(str: ^string) -> (val: int, ok: bool) {
	val = 0
	ok  = false

	for len(str) > 0 && is_digit(rune(str[0])) {
		val  = val * 10 + int(str[0] - '0')
		ok   = true
		str^ = str[1:]
	}

	return val, ok
}

read_mul :: proc(str: ^string) -> (val: int, found: bool) {
	if !strings.starts_with(str^, "mul(") {
		return 0, false
	}

	str^ = str[4:]
	num_1, ok_1 := read_int(str)
	if !ok_1 {
		return 0, false
	}

	if len(str) == 0 || str[0] != ',' {
		return 0, false
	}

	str^ = str[1:]
	num_2, ok_2 := read_int(str)
	if !ok_2 {
		return 0, false
	}

	if len(str) == 0 || str[0] != ')' {
		return 0, false
	}

	str^ = str[1:]

	return num_1 * num_2, true
}

part_1 :: proc(input: string) -> int {
	input := input
	sum   := 0

	for len(input) > 0 {
		val, found := read_mul(&input)

		if found {
			sum += val
		} else {
			input = input[1:]
		}
	}

	return sum
}

part_2 :: proc(input: string) -> int {
	input   := input
	enabled := true
	sum     := 0

	for len(input) > 0 {
		if strings.starts_with(input, "do()") {
			enabled = true
			input = input[4:]
		} else if strings.starts_with(input, "don't()") {
			enabled = false
			input = input[7:]
		} else {
			val, found := read_mul(&input)

			if found {
				if enabled {
					sum += val
				}
			} else {
				input = input[1:]
			}
		}
	}

	return sum
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
