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

day09a :: proc() {
	input := day09_read_input("day09.txt")
	// print(input)
	unpacked := unpack(input)
	// print(unpacked)
	next_whitespace := optimize(unpacked)
	// print(unpacked)
	result := checksum(unpacked[0:next_whitespace])
	fmt.println("Result:", result)
}


day09b_visual :: proc() {
	WIDTH :: 3200
	HEIGHT :: 2000
	rl.InitWindow(WIDTH, HEIGHT, "Day09 Solution")
	defer rl.CloseWindow()
	rl.SetTargetFPS(240)

	state:= day09b_init()
	speed:= 10
	track_pos := false
	is_run := false
	position :[2]f32 = {0, 0}
	for !rl.WindowShouldClose() {
		if is_run {
			for i in 0..<speed {
				optimize_files_next(&state)		
			}
		}
		
		if rl.IsKeyPressed(.P) {
			is_run = !is_run
		}
		if rl.IsKeyPressed(.D) {
			println(state.array)
		}
		if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
			track_pos = !track_pos
			position = rl.GetMousePosition()
			fmt.println(position)
		}
		
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		for v, i in state.array {
			if v == -1 do continue
			scale :i32= 8
			width :i32= WIDTH / scale
			x := i32(i) % width
			y := i32(i) / width
			rect := rl.Rectangle{f32(x * scale), f32(y * scale), f32(scale), f32(scale)}
			if track_pos && rl.CheckCollisionPointRec(position, rect){
				fmt.println("Element", v, i, rect, position)
				track_pos = false
			}
			if v >= state.last_copied {
				rl.DrawRectangleRec(rect, rl.GREEN)
			}
			else {
				rl.DrawRectangleRec(rect, rl.RED)
			}
		}
		rl.EndDrawing()
	}

	// state:= day09b_init()
	// for state.next_data > 0 {
	// 	optimize_files_next(&state)
	// }
	fmt.println("Result:", checksum(state.array))
}

println :: proc(data : []i64) {
	for u in data {
		if u == -1 {
			fmt.print('.')
			fmt.print(' ')
		}
		else {
			fmt.print(u)
			fmt.print(' ')
		}
	}
	fmt.println()
}

unpack :: proc(packed : []i64) -> []i64 {
	result := make([dynamic]i64)
	for v, i in packed {
		if i % 2 == 0 {
			//file
			for t in 0..<v {
				append(&result, i64(i/2))
			}
		}
		else {
			//space
			for t in 0..<v {
				append(&result, i64(-1))
			}
		}
	}
	return result[:]
}


optimize :: proc(array : []i64) -> i32 {
	next_whitespace : i32 = 0
	next_data : i32 = i32(len(array)-1)
	for next_data > next_whitespace {
		if array[next_data] == -1 {
			next_data -= 1
			continue
		}
		if array[next_whitespace] != -1 {
			next_whitespace += 1
			continue
		}
		t := array[next_data]
		array[next_data] = array[next_whitespace]
		array[next_whitespace] = t
	}
	return next_whitespace+1
}

move_file :: proc(array : []i64, start, length : i32) -> bool {
	nw := 0
	max_length : i32 = 0
	ws_length :i32= 0
	for idx in 0..=start {
		if ws_length >= length && ws_length > 0 {
			assert(ws_length >= max_length)
			for i in 0..<length {
				assert(array[idx+i-ws_length] == -1)
				t := array[start+i]
				array[start+i] = array[idx+i-ws_length]
				array[idx+i-ws_length] = t
				
			}
			return true
		}
		if array[idx] == -1 || (array[idx] == array[start] && ws_length > 0) {
			ws_length += 1
			if max_length < ws_length {
				max_length = ws_length
			}
			continue
		}

		ws_length = 0
	}
	if max_length == 0 do return false
	return true
}


State :: struct {
	dt_length, next_data : i32,
	last_copied, v : i64,
	array : []i64
}


day09b_init :: proc() -> State {
	input := day09_read_input("day09.txt")
	fmt.println(len(input))
	// print(input)
	unpacked := unpack(input)
	return State {0, i32(len(unpacked)-1), unpacked[len(unpacked)-1] + 1, unpacked[len(unpacked)-1], unpacked }
}

optimize_files_next :: proc(state : ^State) {
	if state.next_data <= 0 do return
	if state.array[state.next_data] != state.v {
		if state.dt_length > 0 {
			if state.v != -1 {
				if state.v <= state.last_copied {
					has_whitespace := move_file(state.array, state.next_data+1,i32(state.dt_length))	
					state.last_copied = state.v
					if !has_whitespace {
						state.next_data = 0
						fmt.println("NO MORE SPACE LEFT")
						return
					}
				}
				// break
			}
			if state.array[state.next_data] != state.v {
				state.dt_length = 1
				state.v = state.array[state.next_data]	
			}
		}
	}
	else {
		state.dt_length += 1
	}
	state.next_data -= 1
}

optimize_files :: proc(array : []i64) {
	dt_length:= 0
	next_data : i32 = i32(len(array)-1)
	last_copied := array[next_data] + 1
	v :i64= array[next_data]
	for next_data >= 0 {
		if array[next_data] != v {
			if dt_length > 0 {
				if v != -1 {
					if v <= last_copied {
						move_file(array, next_data+1,i32(dt_length))	
						last_copied = v
					}
					// break
				}
				if array[next_data] != v {
					dt_length = 1
					v = array[next_data]	
				}
			}
		}
		else {
			dt_length += 1
		}
		next_data -= 1
	}
	if v != -1 {
		move_file(array, 1, i32(dt_length))	
	}
}


checksum :: proc(array: []i64) -> i128 {
	sum :i128 = 0
	for t, i in array {
		if(t == -1) do continue
		res := i128(t) * i128(i)
		// fmt.println("SUM:", sum, res)
		sum += res
		assert(i128(t) * i128(i) >= 0)
	}
	return sum
}


day09b :: proc() {
	input := day09_read_input("day09.txt")
	unpacked := unpack(input)
	optimize_files(unpacked)
	result := checksum(unpacked)
	fmt.println("Result:", result)
}


day09_read_input :: proc(filename : string) -> []i64 {
    file, ok := os.read_entire_file(filename)
    if !ok {
        panic("Could Not Load Day09 Input")
    }

    chars := transmute([]u8)file
    result := make([]i64, len(chars))

    for c, i in chars {
    	result[i] = i64(c - '0')
    }

    return result
}