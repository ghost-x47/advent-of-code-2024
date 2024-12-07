package main

import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"


day05b :: proc() {
    input := day05_read_input("day05.txt")
    sum : i32 = 0
    for u in input.updates {
        if !check_update(u, input.rules) {
            correct := find_correct(u, input.rules)
            st := check_update(correct, input.rules)
            s := middle_page(correct)
            sum += s
        }
    }
    fmt.println("Result:", sum)
}


find_correct :: proc(update : []i32, rules : [][2]i32) -> []i32 {
    l := len(update)
    swapped := true
    for swapped {
        swapped = false
        for i in 0..<l-1 {
            if is_higher(update[i], update[i+1], rules) {
                update[i], update[i+1] = update[i+1], update[i]
                swapped = true
            }
        }
    }
    return update
}

is_higher :: proc(lhs, rhs : i32, rules : [][2]i32) -> bool {
    for r in rules {
        if r.x == rhs && r.y == lhs {
            return true
        }
    }
    return false
}


day05a :: proc() {
    input := day05_read_input("day05.txt")
    sum : i32 = 0
    for u in input.updates {
        if check_update(u, input.rules) {
            s := middle_page(u)
            sum += s
        }
    }
    fmt.println("Result:", sum)
}


check_update :: proc(update : []i32, rules : [][2]i32) -> bool {
    for page, i in update {
        lower := check_update_lower(page, update[:i], rules)
        higher := check_update_higher(page, update[i+1:], rules)
        if !lower || !higher {
            return false
        }
    }
    return true
}

check_update_lower :: proc(page:i32, check:[]i32, rules : [][2]i32) -> bool {
    for r in rules {
        if r.x != page do continue 
        for c in check {
            if r.y == c do return false
        }   
    }
    return true
}
check_update_higher :: proc(page:i32, check:[]i32, rules : [][2]i32) -> bool {
    for r in rules {
        if r.y != page do continue 
        for c in check {
            if r.x == c do return false
        }   
    }
    return true
}

middle_page :: proc(update : []i32) -> i32 {
    l := len(update)
    result := update[l / 2]
    return result
}

Manual :: struct {
    rules : [][2]i32,
    updates : [][]i32
}

day05_read_input :: proc(filename : string) -> Manual {
    file, ok := os.read_entire_file(filename)
    if !ok {
        panic("Could Not Load Day05 Input")
    }
    split := strings.split_lines(transmute(string)file)
    rules := make([dynamic][2]i32)
    updates := make([dynamic][]i32)
    parse_rules := true
    for line in split {
        if len(line) == 0 {
            parse_rules = false
            continue
        }
        if parse_rules {
            pages_raw := strings.split(line, "|")
            page_left, _ := strconv.parse_int(pages_raw[0])
            page_right, _ := strconv.parse_int(pages_raw[1])
            append(&rules, [2]i32{i32(page_left), i32(page_right)})
        }
        else {
            updates_raw := strings.split(line, ",")
            updates_line := make([dynamic]i32, 0, len(updates_raw))
            for update_raw in updates_raw {
                update, _ := strconv.parse_int(update_raw)
                append(&updates_line, i32(update))
            }
            append(&updates, updates_line[:])
        }
    }

    return {rules[:], updates[:]}
}