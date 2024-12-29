package main

import "core:fmt"
import "core:os"
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

parse_orderings :: proc(s: string) -> map[[2]int]struct{} {
	s := s
	orderings := make(map[[2]int]struct{})

	for line in strings.split_lines_iterator(&s) {
		split    := strings.index_rune(line, '|')
		left,  _ := strconv.parse_int(line[:split])
		right, _ := strconv.parse_int(line[split + 1:])

		orderings[{left, right}] = {}
	}

	return orderings
}

parse_page_nums :: proc(s: string, buff: ^[dynamic]int) {
	s := s

	for num_str in strings.split_iterator(&s, ",") {
		num, _ := strconv.parse_int(num_str)
		append(buff, num)
	}
}

part_1 :: proc(input: string) -> int {
	split := strings.index(input, "\n\n") + 1
	orderings_str := input[:split]
	page_nums_str := input[split + 1:]

	orderings := parse_orderings(orderings_str)
	page_buff := make([dynamic]int)

	defer {
		delete(orderings)
		delete(page_buff)
	}

	page_sum := 0

	outer: for line in strings.split_lines_iterator(&page_nums_str) {
		clear(&page_buff)
		parse_page_nums(line, &page_buff)

		for i in 0..<len(page_buff) - 1 {
			left  := page_buff[i]
			right := page_buff[i + 1]

			if !({left, right} in orderings) {
				continue outer
			}
		}

		middle   := len(page_buff) / 2
		page_sum += page_buff[middle]
	}

	return page_sum
}

part_2 :: proc(input: string) -> int {
	split := strings.index(input, "\n\n") + 1
	orderings_str := input[:split]
	page_nums_str := input[split + 1:]

	orderings := parse_orderings(orderings_str)
	page_buff := make([dynamic]int)

	defer {
		delete(orderings)
		delete(page_buff)
	}

	page_sum := 0

	for line in strings.split_lines_iterator(&page_nums_str) {
		clear(&page_buff)
		parse_page_nums(line, &page_buff)

		needed_sorting := false
		sorted := false

		for !sorted {
			sorted = true

			for i in 0..<len(page_buff) - 1 {
				left  := &page_buff[i]
				right := &page_buff[i + 1]

				if ({right^, left^} in orderings) {
					left^, right^ = right^, left^
					needed_sorting = true
					sorted = false
				}
			}
		}

		if needed_sorting {
			middle   := len(page_buff) / 2
			page_sum += page_buff[middle]
		}
	}

	return page_sum
}

main :: proc() {
	input := load_input("input.txt")

	fmt.printfln("part 1: %v", part_1(input))
	fmt.printfln("part 2: %v", part_2(input))
}
