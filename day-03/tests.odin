package main

import "core:testing"

@(test)
test_part_1 :: proc(t: ^testing.T) {
	input := load_input("example_1.txt")
	testing.expect_value(t, part_1(input), 161)
}

@(test)
test_part_2 :: proc(t: ^testing.T) {
	input := load_input("example_2.txt")
	testing.expect_value(t, part_2(input), 48)
}
