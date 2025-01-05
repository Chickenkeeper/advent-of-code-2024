package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:time"

Robot :: struct {
	pos: [2]int,
	vel: [2]int,
}

parse_robot :: proc(robot: string) -> (pos, vel: [2]int) {
	first_comma := strings.index_rune(robot              , ',')
	space_index := strings.index_rune(robot[first_comma:], ' ') + first_comma
	last_comma  := strings.index_rune(robot[space_index:], ',') + space_index

	pos_x, _ := strconv.parse_int(robot[2              :first_comma])
	pos_y, _ := strconv.parse_int(robot[first_comma + 1:space_index])
	vel_x, _ := strconv.parse_int(robot[space_index + 3:last_comma ])
	vel_y, _ := strconv.parse_int(robot[last_comma  + 1:           ])

	return {pos_x, pos_y}, {vel_x, vel_y}
}

print_room :: proc(room: []int, width, height: int) {
	for y in 0..<height {
		for x in 0..<width {
			num_robots := room[y * width + x]

			if num_robots == 0 {
				fmt.print(" ,")
			} else {
				fmt.printf("%v,", num_robots)
			}
		}

		fmt.println()
	}

	fmt.println()
}

load_input :: proc(path: string) -> string {
	input_bytes, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("couldn't read input file")
		os.exit(int(os.ERROR_FILE_NOT_FOUND))
	}

	return string(input_bytes)
}

print_solution :: proc(name, input: string, width, height: int, solution_proc: proc(string, int, int) -> int) {
	start_tk := time.tick_now()
	solution := solution_proc(input, width, height)
	duration := time.tick_since(start_tk)
	millis   := time.duration_milliseconds(duration)

	fmt.printfln("%v: %v, time: %.4fms", name, solution, millis)
}

part_1 :: proc(input: string, width, height: int) -> int {
	input_cpy := input
	quadrants := [4]int{0, 0, 0, 0}

	for line in strings.split_lines_iterator(&input_cpy) {
		pos, vel := parse_robot(line)

		// calculate the robot's position after 100 seconds
		pos = (pos + vel * 100) %% {width, height}

		// add the robot to its quadrant, if it occupies any
		if pos.x < width / 2 {
			if pos.y < height / 2 {
				quadrants[0] += 1
			} else if pos.y > height / 2 {
				quadrants[1] += 1
			}
		} else if pos.x > width / 2 {
			if pos.y < height / 2 {
				quadrants[2] += 1
			} else if pos.y > height / 2 {
				quadrants[3] += 1
			}
		}
	}

	safety_factor := quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3]

	return safety_factor
}

part_2 :: proc(input: string, width, height: int) -> int {
	input_cpy  := input
	num_robots := strings.count(input, "\n")

	robots := make([]Robot, num_robots)
	room   := make([]int, width * height)

	defer {
		delete(robots)
		delete(room)
	}

	for &robot in robots {
		line, _  := strings.split_lines_iterator(&input_cpy)
		pos, vel := parse_robot(line)

		robot = Robot{pos, vel}
	}

	seconds := 1

	outer: for {
		// calculate all the robot's positions after 1 second, and
		// record the number of robots at each position in the room
		for &robot in robots {
			robot.pos = (robot.pos + robot.vel) %% {width, height}
			room[robot.pos.y * width + robot.pos.x] += 1
		}

		// if there's a suspicious vertical line of robots down the
		// center of the room, then assume they've formed a tree
		MAX_LINE_LEN :: 10
		line_len := 0

		for y in 0..<height {
			num_robots := room[y * width + width / 2]

			if num_robots > 0 {
				line_len += 1
			} else {
				line_len = 0
			}

			if line_len == MAX_LINE_LEN {
				// print the room to the terminal to visually check that the robots have formed a tree
				// print_room(room[:], width, height)
				break outer
			}
		}

		slice.fill(room, 0)
		seconds += 1
	}

	return seconds
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, 101, 103, part_1)
	print_solution("part 2", input, 101, 103, part_2)
}
