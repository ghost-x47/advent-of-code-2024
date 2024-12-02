package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:math"


day02a :: proc() {
	file, ok := os.read_entire_file("day02.txt")
	if !ok {
		panic("Could Not Load Day02 Input")
	}
	sum : int = 0
	lines := strings.split_lines(transmute(string)file)
	for line in lines {
		levels := strings.split(line, " ")
		if is_report_safe(levels) {
			sum += 1
		}
	}
	fmt.println(sum)
}



day02b :: proc() {
	file, ok := os.read_entire_file("day02.txt")
	if !ok {
		panic("Could Not Load Day02 Input")
	}
	sum : int = 0
	levels_partial := make([dynamic]string)
	defer free(&levels_partial)
	lines := strings.split_lines(transmute(string)file)
	for line in lines {
		levels := strings.split(line, " ")
		fmt.println("Test")
		fmt.println(levels)
		if is_report_safe(levels) {
			sum += 1
		} else {
			length := len(levels)
			test: for i in 0..<length {
				clear(&levels_partial)
				for j in 0..<length {
					if i == j do continue
					append(&levels_partial, levels[j])
				}
				fmt.println(levels_partial)
				if is_report_safe(levels_partial[:]) {
					sum += 1
					break test
				}
			}
		}
	}
	fmt.println(sum)
}

is_report_safe :: proc(levels: []string) -> bool {
	
	direction := 0
	last_level := 0
	i := 0
	for level in levels {
		val, _ := strconv.parse_int(level)
		if !is_level_safe(val, i, &direction, &last_level) {
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