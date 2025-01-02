package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

Memo :: struct {
	value: int,
	depth: int,
}

Stone :: struct {
	value:  int,
	count:  int,
	depth:  int,
	parent: int,
	active: bool,
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

log10_int :: proc(n: int) -> int {
	log := 0
	tmp := n

	for tmp > 0 {
		log += 1
		tmp /= 10
	}

	return log
}

pow10_int :: proc(n: int) -> int {
	pow := 1

	for i in 0..<n {
		pow *= 10
	}

	return pow
}

// Splits a base 10 number into two separate numbers at a specified digit position.
split_int :: proc(n, pos: int) -> (left, right: int) {
	power := pow10_int(pos)

	left  = n / power
	right = n - left * power
	return
}

get_num_stones :: proc(input: string, num_blinks: int) -> int {
	input := input
	memos := make(map[Memo]int)
	stack := make([dynamic]Stone)

	defer {
		delete(memos)
		delete(stack)
	}

	// parse initial stones
	for num_str in strings.split_iterator(&input, " ") {
		num, _ := strconv.parse_int(num_str)

		append(&stack, Stone{num, 0, 0, -1, true})
	}

	// recursively count the number of stones after num_blinks blinks
	total_stones := 0

	for len(stack) > 0 {
		index := len(stack) - 1
		stone := &stack[index]

		if stone.active {
			stone.active = false

			if stone.depth == num_blinks {
				stone.count = 1
				continue
			}

			memo_count, found := memos[{stone.value, stone.depth}]
			if found {
				stone.count = memo_count
				continue
			}

			new_depth := stone.depth + 1

			if stone.value == 0 {
				append(&stack, Stone{1, 0, new_depth, index, true})
			} else {
				num_digits := log10_int(stone.value)

				if num_digits % 2 == 0 {
					left, right := split_int(stone.value, num_digits / 2)

					append(&stack, Stone{left,  0, new_depth, index, true})
					append(&stack, Stone{right, 0, new_depth, index, true})
				} else {
					append(&stack, Stone{stone.value * 2024, 0, new_depth, index, true})
				}
			}
		} else {
			if stone.parent == -1 {
				total_stones += stone.count
			} else {
				stack[stone.parent].count += stone.count
			}

			// avoid recomputing this stone if it's encountered again
			memos[{stone.value, stone.depth}] = stone.count
			pop(&stack)
		}
	}

	return total_stones
}

part_1 :: proc(input: string) -> int {
	return get_num_stones(input, 25)
}

part_2 :: proc(input: string) -> int {
	return get_num_stones(input, 75)
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
