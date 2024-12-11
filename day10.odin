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
import "core:math/big"
import rl "vendor:raylib"


Day10Input :: struct {
	size: [2]i32,
	data : []i64
}

day10a :: proc() {
	scores :i64= 0
	input := day10_read_input("day10.txt")
	sum := 0
	for y in 0..<input.size.x {
		for x in 0..<input.size.y {
			if input.data[input.size.x * y + x] == 0 {
				clear(&destinations)
				calculate_score(&input, {x, y}, &scores)
				sum += len(destinations)
			}
		}
	}

	fmt.println(sum)
}


directions :: [4][2]i32 {{0, 1}, {0, -1}, {1, 0}, {-1, 0}}

calculate_score :: proc(input : ^Day10Input, start: [2]i32, score : ^i64) {
	find_next_pos(input, start, input.data[to_index(start, input.size.x)], score)
}

to_index :: proc(pos:[2]i32, stride: i32) -> i32  {
	return pos.y * stride + pos.x
}

find_next_pos :: proc(input : ^Day10Input, pos : [2]i32, value:i64, acc:^i64) {
	idx := to_index(pos, input.size.x)
	if input.data[idx] == 9 {
		acc^ += 1
		found := false
		for d in destinations {
			if d == pos {
				found = true	
				break
			} 
		}
		if !found {
			append(&destinations, pos)
		}
		return	
	} 
	for d in directions {
		next := pos + d
		next_idx := to_index(next, input.size.x)
		if outside_bounds(next, input.size) do continue
		if value + 1 != input.data[next_idx] do continue
		find_next_pos(input, next, input.data[next_idx], acc)
	}
}

destinations : [dynamic][2]i32

day10_print :: proc(input : ^Day10Input) {
	for y in 0..<input.size.y {
		for x in 0..<input.size.x {
			fmt.print(input.data[to_index({x,y}, input.size.x)])
		}
		fmt.println()
	}
}

day10b :: proc() {
	scores :i64= 0
	input := day10_read_input("day10.txt")
	sum := 0
	for y in 0..<input.size.x {
		for x in 0..<input.size.y {
			if input.data[input.size.x * y + x] == 0 {
				clear(&destinations)
				calculate_score(&input, {x, y}, &scores)
				sum += len(destinations)
			}
		}
	}

	fmt.println(scores)
}


day10_read_input :: proc(filename : string) -> Day10Input {
    file, ok := os.read_entire_file(filename)
    if !ok {
        panic("Could Not Load Day10 Input")
    }

    chars := transmute([]u8)file
    result := make([dynamic]i64)
    length := i32(strings.index_byte(transmute(string)file, '\n'))

    for c, i in chars {
    	if c == '\n' do continue
    	append(&result, i64(c - '0'))
    }

    return Day10Input{{length, length}, result[:]}
}