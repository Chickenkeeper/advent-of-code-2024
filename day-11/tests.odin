package main

import "core:testing"

@(private="file")
input := load_input("example.txt")

@(test)
test_part_1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(input), 55312)
}

@(test)
test_part_2 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_2(input), 65601038650482)
}
