package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:time"

Node :: struct {
	depth:  int,
	value:  int,
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

parse_equation :: proc(s: string, nums: ^[dynamic]int) -> (test_val: int) {
	test_val_end := strings.index_rune(s, ':')
	test_num, _  := strconv.parse_int(s[:test_val_end])
	nums_str     := s[test_val_end + 2:]

	for num_str in strings.split_iterator(&nums_str, " ") {
		num, _ := strconv.parse_int(num_str)
		append(nums, num)
	}

	return test_num
}

// Concatenates the digits of two base 10 numbers, e.g. concat(123, 45) == 12345.
concat :: proc(a, b: int) -> int {
	res := a
	tmp := b

	for tmp > 0 {
		res *= 10
		tmp /= 10
	}

	return res + b
}

is_solvable :: proc(test_val: int, nums: []int, stack: ^[dynamic]Node, concat_op: bool) -> bool {
	// check each combination of operators with a depth-first search,
	// so branches which don't lead to solutions can be pruned early
	append(stack, Node{0, nums[0], true})

	for len(stack) > 0 {
		memo := pop(stack)

		if memo.depth == len(nums) - 1 {
			if memo.value == test_val {
				return true
			} else {
				continue
			}
		}

		if !memo.active || memo.value > test_val {
			continue
		}

		next_index := memo.depth + 1
		next_num   := nums[next_index]

		append(stack,
			Node{next_index, memo.value + next_num, true},
			Node{next_index, memo.value * next_num, true},
		)

		if concat_op {
			append(stack, Node{next_index, concat(memo.value, next_num), true})
		}
	}

	return false
}

get_calibration_result :: proc(input: string, concat_op: bool) -> int {
	input := input
	nums  := make([dynamic]int, 0, 4)
	stack := make([dynamic]Node, 0, 16)

	defer {
		delete(nums)
		delete(stack)
	}

	total := 0

	for line in strings.split_lines_iterator(&input) {
		clear(&nums)
		clear(&stack)

		test_val := parse_equation(line, &nums)

		if is_solvable(test_val, nums[:], &stack, concat_op) {
			total += test_val
		}
	}

	return total
}

part_1 :: proc(input: string) -> int {
	return get_calibration_result(input, false)
}

part_2 :: proc(input: string) -> int {
	return get_calibration_result(input, true)
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
