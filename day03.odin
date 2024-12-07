package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"


MUL_TOKEN :: []u8 {'m', 'u', 'l', '('}

DO_TOKEN :: []u8 {'d', 'o', '(', ')'}
DONT_TOKEN :: []u8 {'d', 'o', 'n', '\'', 't', '(', ')' }


find_position :: proc(data: []u8, start_index : int, target : u8) -> int {
    for r, i in data[start_index:] {
        if r == target do return start_index + i
    }
    return -1
}


day03b :: proc() {
    input := day03a_read_input("day03.txt")
    fmt.println(transmute(string)input)
    i := 0
    enabled := true
    sum : i64 = 0
    for {
        if enabled && is_substring(input, i, MUL_TOKEN) {
            fmt.println("Match at", i)
            i += len(MUL_TOKEN)
            end := find_position(input, i, ')')
            if end == -1 {
                break
            }
            lhs, rhs, ok := match_mul_args(input, i, end)
            if ok {
                i = end 
                fmt.println("Multiply ", lhs, rhs)
                sum += i64(lhs * rhs)
            } else {
                fmt.println(transmute(string)input[i:end])
            }
        }
        else if is_substring(input, i, DO_TOKEN) {
            i += len(DO_TOKEN)
            fmt.println("ENABLE")
            enabled = true
        }
        else if is_substring(input, i, DONT_TOKEN) {
            i += len(DONT_TOKEN)
            fmt.println("DISABLE")
            enabled = false
        } else {
            i += 1  
        }
        
        if i >= len(input) {
            break
        }
    }
    fmt.println("Result: ", sum)
}


day03a :: proc() {
    input := day03a_read_input("day03.txt")
    fmt.println(transmute(string)input)
    i := 0
    sum : i64 = 0
    for {
        if input[i] == MUL_TOKEN[0] {
            if is_substring(input, i, MUL_TOKEN) {
                fmt.println("Match at", i)
                i += len(MUL_TOKEN)
                end := find_position(input, i, ')')
                if end == -1 {
                    break
                }
                lhs, rhs, ok := match_mul_args(input, i, end)
                if ok {
                    i = end 
                    fmt.println("Multiply ", lhs, rhs)
                    sum += i64(lhs * rhs)
                } else {
                    fmt.println(transmute(string)input[i:end])
                }
            }
        }
        i += 1
        if i >= len(input) {
            break
        }
    }
    fmt.println("Result: ", sum)
}


match_mul_args :: proc(data : []u8, start_index: int, end_index : int) -> (lhs, rhs : int, ok : bool) {
    slice := data[start_index:end_index]
    items := strings.split(transmute(string)slice, ",")

    if len(items) != 2 || len(items[0]) < 1 || len(items[1]) < 1 || len(items[0]) > 3 || len(items[1]) > 3 {
        return 0, 0, false
    }
    lhs = strconv.parse_int(items[0]) or_return
    rhs = strconv.parse_int(items[1]) or_return
    return lhs, rhs, true
}


is_substring :: proc(data : []u8, start_index: int, token : []u8)  -> bool {
    for r, i in token {
        if r != data[start_index + i] {
            return false
        }
    }
    return true
}


day03a_read_input :: proc(filename : string) -> []u8 {
    file, ok := os.read_entire_file(filename)
    if !ok {
        panic("Could Not Load Day02 Input")
    }
    return file
}