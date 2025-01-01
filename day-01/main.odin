package main

import "core:fmt"
import "core:os"
import "core:slice"
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

parse_nums :: proc(s: string) -> (left, right: int) {
	left_num_end    := strings.index(s, " ")
	right_num_start := strings.last_index(s, " ") + 1

	left_num,  _ := strconv.parse_int(s[:left_num_end])
	right_num, _ := strconv.parse_int(s[right_num_start:])

	return left_num, right_num
}

part_1 :: proc(input: string) -> int {
	input_cpy  := input
	num_lines  := strings.count(input, "\n")
	left_nums  := make([]int, num_lines)
	right_nums := make([]int, num_lines)

	defer {
		delete(left_nums)
		delete(right_nums)
	}

	// parse numbers
	for i in 0..<num_lines {
		line, _ := strings.split_lines_iterator(&input_cpy)
		left_nums[i], right_nums[i] = parse_nums(line)
	}

	slice.sort(left_nums)
	slice.sort(right_nums)

	total_dist := 0

	// sum the distance between each pair of numbers
	for i in 0..<num_lines {
		dist := abs(left_nums[i] - right_nums[i])
		total_dist += dist
	}

	return total_dist
}

part_2 :: proc(input: string) -> int {
	input_cpy := input
	num_lines := strings.count(input, "\n")
	left_nums := make([]int, num_lines)
	num_freq  := make(map[int]int, num_lines)

	defer {
		delete(left_nums)
		delete(num_freq)
	}

	// parse numbers
	for i in 0..<num_lines {
		line, _ := strings.split_lines_iterator(&input_cpy)
		left_num, right_num := parse_nums(line)

		left_nums[i] = left_num
		num_freq[right_num] += 1
	}

	similarity := 0

	// sum the number of times each number in the left list appears in the right list
	for left_num in left_nums {
		similarity += left_num * (num_freq[left_num] or_else 0)
	}

	return similarity
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
