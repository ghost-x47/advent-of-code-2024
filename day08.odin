package main 

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:os"
import "core:math"
import "core:thread"
import "core:time"
import ba "core:container/bit_array"


Day08Input :: struct {
	size : [2]int,
	content : [dynamic]Node
}

Node :: struct {
	pos: [2]int,
	freq : u8
}


day08a :: proc() {
	input := day08_read_input("day08.txt")
	defer delete(input.content)
	defer free(input)

	freq_map := create_map(input)
	defer delete(freq_map)

	results : ba.Bit_Array
	for freq in freq_map {
		list:= freq_map[freq]
		if len(list) == 0 do continue

		for start in list {
			for end in list {
				if start == end do continue
				antifreq := end + (end - start)
				if antifreq.x < 0 || antifreq.x >= input.size.x || antifreq.y < 0 || antifreq.y >= input.size.y {
					continue
				}
				result := antifreq.y * input.size.x + antifreq.x
				ba.set(&results, result)
			}
		}
	}	
	count := 0
	iterator := ba.make_iterator(&results)
	for x in ba.iterate_by_set(&iterator) {
		count += 1
	}
	fmt.println("Result:", count)
}


create_map :: proc(input : ^Day08Input)-> map[u8][dynamic][2]int {
	result:= make(map[u8][dynamic][2]int)

	for n in input.content {
		if n.freq not_in result {
			result[n.freq] = make([dynamic][2]int)
		}
		append(&result[n.freq], n.pos)
	}
	return result
}

day08b :: proc() {
	input := day08_read_input("day08.txt")
	defer delete(input.content)
	defer free(input)

	freq_map := create_map(input)
	defer delete(freq_map)

	results : ba.Bit_Array
	for freq in freq_map {
		list:= freq_map[freq]
		if len(list) == 0 do continue

		for start in list {
			for end in list {
				if start == end do continue
				antifreq := end
				for !(antifreq.x < 0 || antifreq.x >= input.size.x || antifreq.y < 0 || antifreq.y >= input.size.y) {
					result := antifreq.y * input.size.x + antifreq.x
					ba.set(&results, result)
					antifreq += (end - start)
				}
			}
		}
	}	
	count := 0
	iterator := ba.make_iterator(&results)
	for x in ba.iterate_by_set(&iterator) {
		count += 1
	}
	fmt.println("Result:", count)
}


day08_read_input :: proc(filename : string) -> ^Day08Input {
    file, ok := os.read_entire_file(filename)
    if !ok {
        panic("Could Not Load Day08 Input")
    }
    split := strings.split_lines(transmute(string)file)
    result := new(Day08Input)
    result.size = [2]int{len(split[0]), len(split)}
    for line, y in split {
    	for c, x in transmute([]u8)line {
    		if c == '.' do continue
    		append(&result.content, Node{{x, y}, c})
    	}
    }
    return result
}