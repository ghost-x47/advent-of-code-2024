package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:os"

TOKEN_A := []u8 {'X', 'M', 'A', 'S'}
Pos :: [2]int

VARIANTS_A :: enum { HOR_FOW, HOR_BAK, VER_FOW, VER_BAK, DIA_FOW, DIA_BAK, AID_FOW, AID_BAK }
TARGETS_A :: [VARIANTS_A][4]Pos {
	.HOR_FOW = {{0,0}, {1,0}, {2, 0}, {3, 0}},
	.HOR_BAK = {{0,0}, {-1,0}, {-2, 0}, {-3, 0}},
	.VER_FOW = {{0,0}, {0,1}, {0, 2}, {0, 3}},
	.VER_BAK = {{0,0}, {0,-1}, {0, -2}, {0, -3}},
	.DIA_FOW = {{0,0}, {1,1}, {2, 2}, {3, 3}},
	.DIA_BAK = {{0,0}, {-1,-1}, {-2, -2}, {-3, -3}},
	.AID_FOW = {{0,0}, {-1,1}, {-2, 2}, {-3, 3}},
	.AID_BAK = {{0,0}, {1,-1}, {2, -2}, {3, -3}},
}

VARIANTS_B :: enum { LF_RF, LB_RF, LF_RB, LB_RB }
TOKEN_B := []u8 {'M', 'S', 'M', 'S'}

TARGETS_B :: [VARIANTS_B][4]Pos {
	.LF_RF = {{-1, -1}, {1, 1}, {1,-1}, {-1, 1}},
	.LB_RF = {{1, 1}, {-1, -1}, {1,-1}, {-1, 1}},
	.LF_RB = {{-1, -1}, {1, 1}, {-1, 1}, {1,-1}},
	.LB_RB = {{1, 1}, {-1, -1}, {-1,1}, {1, -1}}
}

match_target :: proc(input : ^[]string, start_pos : Pos, size : [2]int, mask: [4]Pos, token : []u8) -> bool {
	for c, i in mask {
		pos := start_pos + c
		if pos.x < 0 || pos.x >= size.x || pos.y < 0 || pos.y >= size.y {
			return false
		}
		if input[pos.y][pos.x] != token[i] {
			return false
		}
	}
	return true
}

day04b :: proc() {
	input := day04a_read_input("day04.txt")
	count := 0
	height := len(input)
	assert(height > 0)
	width := len(input[0])
	for y in 0..<height {
		for x in 0..<width {
			if(input[y][x] == 'A') {
				for t, idx in TARGETS_B {
					if match_target(&input, {x,y},{width, height}, t, TOKEN_B) {
						count += 1
						break
					}
				}
			}
		}
	}
	fmt.println("Matches Found", count)
}

day04a :: proc() {
	input := day04a_read_input("day04.txt")
	count := 0
	height := len(input)
	assert(height > 0)
	width := len(input[0])
	for y in 0..<height {
		for x in 0..<width {
			if(input[y][x] == TOKEN_A[0]) {
				for t in TARGETS_A {
					if match_target(&input, {x,y},{width, height}, t, TOKEN_A) {
						count += 1
					}
				}
			}
		}
	}
	fmt.println(input)
	fmt.println("Find", count, "Matches")
}

day04a_read_input :: proc(filename : string) -> []string {
	file, ok := os.read_entire_file(filename)
	if !ok {
		panic("Could Not Load Day04 Input")
	}
	split := strings.split_lines(transmute(string)file)
	return split
}