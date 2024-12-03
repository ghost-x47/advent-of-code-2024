package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"
import "core:sort"

day01a :: proc() {
	file, ok := os.read_entire_file("day01_First.txt")
	if !ok {
		panic("Could Not Load Day01_First_Test.txt")
	}
	sum : int = 0
	lines := strings.split_lines(transmute(string)file)
	firsts := make([dynamic]int, len(lines))
	seconds := make([dynamic]int, len(lines))
	for line in lines {
		line_numbers := strings.split_n(line, " ", 2)

		first, _ := strconv.parse_int(line_numbers[0])
		second, _ := strconv.parse_int(strings.trim_left_space(line_numbers[1]))
		append(&firsts, first)
		append(&seconds, second)
	}

	sort.quick_sort(firsts[:])
	sort.quick_sort(seconds[:])

	for i in 0..<len(firsts) {
		distance:= abs(firsts[i]-seconds[i])
		sum += distance
	}

	fmt.println("Result:", sum)
}

day01b :: proc() {
	file, ok := os.read_entire_file("day01_First.txt")
	if !ok {
		panic("Could Not Load Day01_First_Test.txt")
	}
	sum : int = 0
	lines := strings.split_lines(transmute(string)file)
	firsts := make([dynamic]int, len(lines))
	seconds := make([dynamic]int, len(lines))
	for line in lines {
		line_numbers := strings.split_n(line, " ", 2)

		first, _ := strconv.parse_int(line_numbers[0])
		second, _ := strconv.parse_int(strings.trim_left_space(line_numbers[1]))
		append(&firsts, first)
		append(&seconds, second)
	}

	sort.quick_sort(firsts[:])
	sort.quick_sort(seconds[:])

	count_index := 0

	for i in 0..<len(firsts) {
		first := firsts[i]
		count := count(first, seconds[:], &count_index)
		sum += first * count
	}

	fmt.println("Result:", sum)
}

count :: proc(x : int, array: []int, index : ^int) -> int {
	cnt := 0
	for {
		i := array[index^]
		if x < i || index^ == len(array)-1 do return cnt
		if x == i do cnt += 1
		index^ += 1
	}
}