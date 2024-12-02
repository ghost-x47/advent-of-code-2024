package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:math"


day02a :: proc() {
	sum : int = 0
	input := day02_read_input("day02.txt")
	for report in input {
		if is_report_safe(report[:]) {
			sum += 1
		}
	}
	fmt.println(sum)
}


day02_read_input :: proc(filename:string, allocator := context.allocator) -> [dynamic][dynamic]int {
	file, ok := os.read_entire_file(filename, allocator)
	if !ok {
		panic("Could Not Load Day02 Input")
	}
	lines := strings.split_lines(transmute(string)file, allocator)
	result : [dynamic][dynamic]int = make([dynamic][dynamic]int, allocator)
	for line in lines {
		levels := strings.split(line, " ", allocator)
		line_result := make([dynamic]int, allocator)
		for level in levels {
			val, ok := strconv.parse_int(level)
			if !ok do continue
			append(&line_result, val)
		}
		append(&result, line_result)
	}
	return result
}



day02b :: proc() {
	input := day02_read_input("day02.txt")
	sum : int = 0
	levels_partial := make([dynamic]int)
	defer free(&levels_partial)
	for report in input {
		if is_report_safe(report[:]) {
			sum += 1
		} else {
			length := len(report)
			test: for i in 0..<length {
				clear(&levels_partial)
				for j in 0..<length {
					if i == j do continue
					append(&levels_partial, report[j])
				}
				if is_report_safe(levels_partial[:]) {
					sum += 1
					break test
				}
			}
		}
	}
	fmt.println(sum)
}

is_report_safe :: proc(levels: []int) -> bool {
	direction := 0
	last_level := 0
	i := 0
	for level in levels {
		if !is_level_safe(level, i, &direction, &last_level) {
			return false
		}
		i += 1
	}
	return true
}

is_level_safe :: proc(level, i : int, direction,last_level : ^int) -> bool {
	if i == 0 {
		last_level^ = level
		return true
	}
	else {
		diff := abs(level - last_level^)
		if diff < 1 || diff > 3 {
			return false
		}
		else if direction^ == 0 {
			direction^ = (level - last_level^) / diff
		}
		else {
			if direction^ != (level - last_level^) / diff {
				return false
			}
		}
		last_level^ = level
		return true
	}
}