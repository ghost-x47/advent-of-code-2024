package main 

import "core:strings"
import "core:fmt"
import "core:strconv"
import "core:slice"
import "core:os"
import "core:math"
import "core:thread"
import "core:time"

Equation :: struct {
	is_correct: int,
	result : i128,
	operands : []i128,
}


Operations :: enum {
	Plus,
	Multiply, 
	Concat
}

day07b_threaded :: proc() {
	input := day07_read_input("day07.txt")
	sum : i128 = 0
	pool: thread.Pool
	thread.pool_init(&pool, allocator= context.allocator, thread_count=16)
	defer thread.pool_destroy(&pool)

	for &t, i in input {
		thread.pool_add_task(&pool, context.allocator, task, &t)
	}

	thread.pool_start(&pool)
	thread.pool_finish(&pool)
	for t in input {
		if t.is_correct == 2 do sum += t.result
	}
	fmt.println("Result:", sum)
}


task :: proc (thr: thread.Task) {
	t := transmute(^Equation)thr.data
	length := i128(math.pow(3, f32(len(t.operands)-1)))
	for i in 0..<length {
		test_result := t.operands[0]
		l := i / 3
		r := i % 3

		for x, y in 1..<len(t.operands) {
			switch(r) {
				case 0: test_result += i128(t.operands[x])
				case 1: test_result *= i128(t.operands[x])
				case 2: 
					test_result *= i128(math.pow(10, f32(math.count_digits_of_base(t.operands[x], 10))))
					test_result += t.operands[x]
			}
			r = l % 3
			l = l / 3
		}
		if test_result == t.result {
			t.is_correct = 2
			return
		}
	}
	t.is_correct = 1
}


day07b_threaded2 :: proc() {
	input := day07_read_input("day07.txt")
	sum : i128 = 0
	thread_pool := make([dynamic]^thread.Thread, 0, len(input))
	defer delete(thread_pool)

	for &t, i in input {
		thr := thread.create(worker)
		thr.init_context = context
		thr.user_index = i
		thr.data = &t
		append(&thread_pool, thr)
		thread.start(thr)
	}
	for len(thread_pool) > 0 {
		for i := 0; i < len(thread_pool); {
			thr:= thread_pool[i]
			if thread.is_done(thr) {
				fmt.printfln("Thread %d is done", thr.user_index)

				if input[thr.user_index].is_correct == 2 {
					sum += input[thr.user_index].result
				}
				thread.destroy(thr)
				ordered_remove(&thread_pool, i)
			} else {
				i += 1
			}
		}
	}
	fmt.println("Result:", sum)
}


worker :: proc (thr: ^thread.Thread) {
	t := transmute(^Equation)thr.data
	length := i128(math.pow(3, f32(len(t.operands)-1)))
	for i in 0..<length {
		test_result := t.operands[0]
		l := i / 3
		r := i % 3

		for x, y in 1..<len(t.operands) {
			switch(r) {
				case 0: test_result += i128(t.operands[x])
				case 1: test_result *= i128(t.operands[x])
				case 2: 
					test_result *= i128(math.pow(10, f32(math.count_digits_of_base(t.operands[x], 10))))
					test_result += t.operands[x]
			}
			r = l % 3
			l = l / 3
		}
		if test_result == t.result {
			t.is_correct = 2
			return
		}
	}
	t.is_correct = 1
}



day07b :: proc() {
	input := day07_read_input("day07.txt")
	sum : i128 = 0
	for t in input {
		length := i128(math.pow(3, f32(len(t.operands)-1)))
		
		test: for i in 0..<length {
			test_result := t.operands[0]
			l := i / 3
			r := i % 3

			for x, y in 1..<len(t.operands) {
				switch(r) {
					case 0: test_result += i128(t.operands[x])
					case 1: test_result *= i128(t.operands[x])
					case 2: 
						test_result *= i128(math.pow(10, f32(math.count_digits_of_base(t.operands[x], 10))))
						test_result += t.operands[x]
				}
				r = l % 3
				l = l / 3
			}
			if test_result == t.result {
				sum += t.result
				break test
			}
		}
	}
	fmt.println("Result:", sum)
}

day07a :: proc() {
	input := day07_read_input("day07.txt")
	sum : i128= 0
	for t in input {
		length := (1 << u32(len(t.operands)-1))
		
		test: for i in 0..<length {
			test_result := t.operands[0]
			for x, y in 1..<len(t.operands) {
				if i32(i) & i32(1 << u32(y)) == 0 {
					test_result += i128(t.operands[x])
				}
				else {
					test_result *= i128(t.operands[x])
				}
			}
			
			if test_result == t.result {
				sum += t.result
				fmt.println(t)
				break test
			}
		}
	}
	fmt.println("Result:", sum)
}

day07_read_input :: proc(filename : string) -> [dynamic]Equation {
	file, ok := os.read_entire_file(filename)
	if !ok {
		panic("Could Not Load Day07 Input")
	}
	split := strings.split_lines(transmute(string)file)
	result := make([dynamic]Equation)
	for line in split {
		pos := strings.index_byte(line, ':')
		eq_result, _ := strconv.parse_i128(line[:pos])
		op_raw := strings.split(line[pos+2:], " ")
		operands := make([dynamic]i128, 0, len(op_raw))
		for op in op_raw {
			op_value, _ := strconv.parse_i128(op)
			append(&operands, op_value)
		}
		append(&result, Equation{ 0, eq_result, operands[:] })
	}
	return result
}