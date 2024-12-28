package main

import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

load_input :: proc(path: string) -> string {
	input_bytes, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("couldn't read input file")
		os.exit(int(os.ERROR_FILE_NOT_FOUND))
	}

	return string(input_bytes)
}

parse_input :: proc(input: string) -> (left_nums, right_nums: []int) {
	input_cpy := input
	num_lines := strings.count(input, "\n")

	left_nums  = make([]int, num_lines)
	right_nums = make([]int, num_lines)

	for i in 0..<num_lines {
		line, _ := strings.split_lines_iterator(&input_cpy)

		left_num_end    := strings.index(line, " ")
		right_num_start := strings.last_index(line, " ") + 1

		left_num,  _ := strconv.parse_int(line[:left_num_end])
		right_num, _ := strconv.parse_int(line[right_num_start:])

		left_nums[i]  = left_num
		right_nums[i] = right_num
	}

	return left_nums, right_nums
}

binary_search_first :: proc(array: $T/[]$E, key: E) -> (index: int, found: bool) where intrinsics.type_is_ordered(E) {
	if array[0] == key { // avoids going out of bounds when checking previous values in the main loop
		return 0, true
	}

	first := 1
	last  := len(array)

	for first < last {
		mid := first + (last - first) >> 1 // computes the average without risking an overflow
		val := array[mid]

		if val < key {
			first = mid + 1
		} else if val > key {
			last = mid
		} else {
			prev := array[mid - 1]

			if prev < key {
				return mid, true
			} else {
				last = mid
			}
		}
	}

	return 0, false
}

binary_search_last :: proc(array: $T/[]$E, key: E) -> (index: int, found: bool) where intrinsics.type_is_ordered(E) {
	if array[len(array) - 1] == key { // avoids going out of bounds when checking next values in the main loop
		return len(array) - 1, true
	}

	first := 0
	last  := len(array) - 1

	for first < last {
		mid := first + (last - first) >> 1 // computes the average without risking an overflow
		val := array[mid]

		if val < key {
			first = mid + 1
		} else if val > key {
			last = mid
		} else {
			next := array[mid + 1]

			if next > key {
				return mid, true
			} else {
				first = mid + 1
			}
		}
	}

	return 0, false
}

part_1 :: proc(input: string) -> int {
	left_nums, right_nums := parse_input(input)

	defer {
		delete(left_nums)
		delete(right_nums)
	}

	slice.sort(left_nums)
	slice.sort(right_nums)

	total_dist := 0

	for i in 0..<len(left_nums) {
		dist := abs(left_nums[i] - right_nums[i])
		total_dist += dist
	}

	return total_dist
}

part_2 :: proc(input: string) -> int {
	left_nums, right_nums := parse_input(input)

	defer {
		delete(left_nums)
		delete(right_nums)
	}

	slice.sort(left_nums)
	slice.sort(right_nums)

	similarity := 0

	for left_num in left_nums {
		// since all the numbers are sorted, identical values are grouped together
		// and we can use binary searches to find the starts and ends of these groups
		first, found := binary_search_first(right_nums, left_num)
		if !found {
			continue
		}

		// if there's a first value there must be a last value,
		// so we don't need to check if one was found here
		last, _ := binary_search_last(right_nums, left_num)

		num_repeats := last - first + 1
		similarity  += left_num * num_repeats
	}

	return similarity
}

main :: proc() {
	input := load_input("input.txt")

	fmt.printfln("part 1: %v", part_1(input))
	fmt.printfln("part 2: %v", part_2(input))
}
