package main


import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:os"
import "base:runtime"

OBSTACLE :: '#'
GUARD_MARK :: 'X'

Input :: struct {
	mapp : [][]u8,
	size : [2]i32,
}

Direction :: enum {
	North,
	South,
	West,
	East
}

GuardChar := [Direction]u8 {
	.North = '^',
	.South = 'v',
	.West = '<',
	.East = '>'
}

GuardDir := [Direction][2]i32 {
	.North = {0, -1},
	.South = {0, 1},
	.West = {-1, 0},
	.East = {1, 0}
}
Guard :: struct {
	position : [2]i32, direction : Direction
}

Track :: struct {
	pos : [2]i32,
	dir : Direction
}
obstacles_placed := 0
initial_pos : [2]i32
length := 0
turns := 0

day06b :: proc() {
	collisions := make([dynamic]Track)
	defer free(&collisions)

	taken_path := make([dynamic]Track)
	defer free(&taken_path)

	input := day06_read_input("day06.txt")
	count := 0
	guard := guard_get(input.mapp)
	initial_pos = guard.position
	input.mapp[guard.position.y][guard.position.x] = '.'

	loop:= true
	for move(&input, &guard) {
		if can_loop(&input, guard, &collisions, &taken_path) {
			count += 1
		}
		append(&taken_path, Track{guard.position, guard.direction})
	}
	fmt.println("Result", count)
}
can_loop :: proc(data: ^Input, initial_guard: Guard, collisions, taken_path: ^[dynamic]Track) -> bool {
	guard := guard_turn(initial_guard)
	additional_obstacle := place_obstacle(data, initial_guard, taken_path[:])
	if additional_obstacle == {-1, -1} do return false
	obstacles_placed += 1
	defer remove_obstacle(data, additional_obstacle)
	defer clear(collisions)
	
	for move_2(data, &guard) {
		for col in collisions {
			if col.pos == guard.position && col.dir == guard.direction {
				fmt.println("", additional_obstacle)
				return true
			}
		}
		append(collisions, Track{guard.position, guard.direction})
	}
	return false
}


place_obstacle :: proc(data: ^Input, guard: Guard, taken_path : []Track) -> [2]i32 {
	next_pos := guard.position + GuardDir[guard.direction]
	if next_pos == initial_pos do return {-1,-1}
	if outside_bounds(next_pos, data.size) do return {-1,-1}
	for t in taken_path {
		if next_pos == t.pos do return {-1,-1}
	}
	if data.mapp[next_pos.y][next_pos.x] == OBSTACLE do return {-1,-1}
	data.mapp[next_pos.y][next_pos.x] = OBSTACLE
	return next_pos
}

remove_obstacle :: proc(data: ^Input, position : [2]i32) {
 	data.mapp[position.y][position.x] = '.'
}

day06a :: proc() {
	input := day06_read_input("day06.txt")
	guard := guard_get(input.mapp)
	moves := 0
	input.mapp[guard.position.y][guard.position.x] = GUARD_MARK
	for move(&input, &guard) {
		input.mapp[guard.position.y][guard.position.x] = GUARD_MARK
		moves += 1
	}

	sum := 0
	for line, y in input.mapp {
		for c, x in line {
			if c == GUARD_MARK {
				sum += 1
			}
		}
	}
	fmt.println("Moves", moves)
	fmt.println("Result", sum)
}


outside_bounds :: proc(pos : [2]i32, size: [2]i32) -> bool {
	return pos.x < 0 || pos.x >= size.x || pos.y < 0 || pos.y >= size.y
}

move_2 :: proc(input : ^Input, guard : ^Guard) -> bool {
	next_pos := guard.position + GuardDir[guard.direction]

	if outside_bounds(next_pos, input.size) do return false
	if input.mapp[next_pos.y][next_pos.x] == OBSTACLE {
		guard^ = guard_turn(guard^)
		return true
	}
	guard.position = next_pos
	return true
}

move :: proc(input : ^Input, guard : ^Guard) -> bool {
	next_pos := guard.position + GuardDir[guard.direction]

	if outside_bounds(next_pos, input.size) do return false
	if input.mapp[next_pos.y][next_pos.x] == OBSTACLE {
		guard^ = guard_turn(guard^)
		turns += 1
		return true
	}
	guard.position = next_pos
	return true
}

guard_get :: proc(data : [][]u8) -> Guard {
	for line, y in data {
		for c, x in line {
			for g, d in GuardChar {
				if g == c do return Guard{{i32(x), i32(y)}, d}	
			}
		}
	}
	unreachable()
}

guard_turn :: proc(guard : Guard) -> Guard {
	direction := guard.direction
	switch guard.direction {
		case .North: direction = .East
		case .South: direction = .West
		case .West : direction = .North
		case .East : direction = .South
	}
	return {guard.position, direction}
}

day06_read_input :: proc(filename : string) -> Input {
	file, ok := os.read_entire_file(filename)
	if !ok {
		panic("Could Not Load Day06 Input")
	}
	split := strings.split_lines(transmute(string)file)
	sp2 := make([dynamic][]u8)
	for line in split {
		append(&sp2, transmute([]u8)line)
	}
	size := [2]i32{i32(len(split[0])), i32(len(split))}
	return { sp2[:], size}
}