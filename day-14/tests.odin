package main

import "core:testing"

@(private="file")
input := load_input("example.txt")

@(test)
test_part_1 :: proc(t: ^testing.T) {
	testing.expect_value(t, part_1(input, 11, 7), 12)
}
