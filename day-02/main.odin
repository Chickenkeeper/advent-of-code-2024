package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

load_input :: proc(path: string) -> string {
	input_bytes, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("couldn't read input file")
		os.exit(int(os.ERROR_FILE_NOT_FOUND))
	}

	return string(input_bytes)
}

sign :: proc(val: int) -> int {
	switch {
		case val > 0: return +1
		case val < 0: return -1
		case: return 0
	}
}

is_safe :: proc(report: []int, skip_index := -1) -> bool {
	if len(report) < 3 {
		return true
	}

	prev_level := 0
	prev_sign  := 0
	counter    := 0

	for level, i in report {
		if i == skip_index {
			continue
		}

		diff := level - prev_level
		abs_diff := abs(diff)

		if counter > 0 && (abs_diff < 1 || abs_diff > 3) {
			return false
		}

		sign_diff := sign(diff)

		if counter > 1 && sign_diff != prev_sign {
			return false
		}

		prev_level = level
		prev_sign  = sign_diff

		counter += 1
	}

	return true
}

num_safe_reports :: proc(input: string, dampener: bool) -> int {
	input_cpy    := input
	safe_reports := 0
	report_buff  := make([dynamic]int)

	defer delete(report_buff)

	for line in strings.split_lines_iterator(&input_cpy) {
		line := line

		// parse report
		for num_str in strings.split_iterator(&line, " ") {
			num, _ := strconv.parse_int(num_str)
			append(&report_buff, num)
		}

		// check levels
		if !dampener {
			if is_safe(report_buff[:]) {
				safe_reports += 1
			}
		} else {
			for i in 0..<len(report_buff) {
				if is_safe(report_buff[:], i) {
					safe_reports += 1
					break
				}
			}
		}

		clear(&report_buff)
	}

	return safe_reports
}

part_1 :: proc(input: string) -> int {
	return num_safe_reports(input, false)
}

part_2 :: proc(input: string) -> int {
	return num_safe_reports(input, true)
}

main :: proc() {
	input := load_input("input.txt")

	fmt.printfln("part 1: %v", part_1(input))
	fmt.printfln("part 2: %v", part_2(input))
}
