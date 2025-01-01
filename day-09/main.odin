package main

import "core:fmt"
import "core:os"
import "core:slice"
import "core:time"

Range :: struct {
	start:  int,
	length: int,
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

// Parses a disk map to an array of blocks.
parse_disk :: proc(disk_map: string) -> []int {
	disk_len := 0

	for char in disk_map {
		disk_len += int(char - '0')
	}

	disk := make([]int, disk_len)
	file_num := 0
	disk_pos := 0

	for char, i in disk_map {
		length := int(char - '0')

		if i % 2 == 0 {
			slice.fill(disk[disk_pos:][:length], file_num)
			file_num += 1
		} else {
			slice.fill(disk[disk_pos:][:length], -1)
		}

		disk_pos += length
	}

	return disk
}

// Parses a disk map to an array of ranges of file blocks and an array of ranges of free blocks.
parse_ranges :: proc(disk_map: string) -> (files, unused: []Range) {
	num_files  := len(disk_map) / 2
	num_unused := len(disk_map) / 2

	// handle odd numbers of blocks
	if len(disk_map) % 2 != 0 {
		num_files += 1
	}

	files  = make([]Range, num_files)
	unused = make([]Range, num_unused)

	disk_pos := 0

	for char, i in disk_map {
		length := int(char - '0')

		if i % 2 == 0 {
			files[i / 2] = Range{disk_pos, length}
		} else {
			unused[i / 2] = Range{disk_pos, length}
		}

		disk_pos += length
	}

	return files, unused
}

part_1 :: proc(input: string) -> int {
	input_cpy := input[:len(input) - 1] // ignore newline
	disk := parse_disk(input_cpy)
	defer delete(disk)

	checksum  := 0
	first_pos := 0
	last_pos  := len(disk) - 1

	for first_pos <= last_pos {
		block_1 := disk[first_pos]

		// if the block is already part of a file
		// then add it straight to the checksum
		if block_1 != -1 {
			checksum  += block_1 * first_pos
			first_pos += 1
			continue
		}

		// otherwise find the last file block on
		// the disk to 'swap' with the free block
		block_2 := disk[last_pos]

		if block_2 != -1 {
			checksum  += block_2 * first_pos
			first_pos += 1
		}

		last_pos -= 1
	}

	return checksum
}

part_2 :: proc(input: string) -> int {
	input_cpy := input[:len(input) - 1] // ignore newline
	files, unused := parse_ranges(input_cpy)

	defer {
		delete(files)
		delete(unused)
	}

	checksum := 0
	file_id  := len(files) - 1

	#reverse for file in files {
		file := file

		// attempt to move the file to the first group of free
		// blocks which is large enough to hold the file, if any
		for &free in unused {
			if free.start > file.start {
				break
			}

			if free.length >= file.length {
				// move the file to the group of free blocks
				file.start = free.start

				// remove the space used by the moved file from the group of free blocks
				free.start  += file.length
				free.length -= file.length
				break
			}
		}

		// add the file's blocks to the checksum
		for i in 0..<file.length {
			checksum += file_id * (file.start + i)
		}

		file_id -= 1
	}

	return checksum
}

main :: proc() {
	input := load_input("input.txt")

	print_solution("part 1", input, part_1)
	print_solution("part 2", input, part_2)
}
