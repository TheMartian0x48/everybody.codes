package year_2026_quest_1

import "core:container/queue"
import q "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
import "core:sort"
import "core:strconv"
import "core:strings"

main :: proc() {

	abs_path := proc(f: string) -> string {
		location := #location()
		folder, _ := strings.substring(
			location.file_path,
			0,
			strings.last_index_any(location.file_path, "/"),
		)

		return strings.join([]string{folder, f}, "/")
	}

	Task :: struct {
		files: []string,
		fn:    proc(_: string),
	}

	quest := []Task {
		{{"./sample_e2026_q01_p1.txt", "./everybody_codes_e2026_q01_p1.txt"}, part_1},
		{{"./sample_e2026_q01_p2.txt", "./everybody_codes_e2026_q01_p2.txt"}, part_2},
		{{"./sample_e2026_q01_p3.txt", "./everybody_codes_e2026_q01_p3.txt"}, part_3},
	}

	for q in quest {
		for f in q.files {
			fmt.println("\n<===============================================>")
			fmt.printfln("\n[%s]\n", f)
			file := abs_path(f)
			defer delete(file)
			q.fn(file)
		}
	}

}

parse_input :: proc(input: string) -> [dynamic]int {
	data, _ := os.read_entire_file_from_path(input, context.allocator)
	input := string(data)

	result := [dynamic]int{}
	for nstr in strings.split_iterator(&input, ",") {
		n, _ := strconv.parse_int(nstr, 10)
		append(&result, n)
	}
	return result
}


part_1 :: proc(input: string) {

	input := parse_input(input)
	defer delete(input)

	slice.sort(input[:])

	squares: [dynamic]int
	defer delete(squares)

	for i := 0;; i += 1 {
		append(&squares, i * i)
		if i * i > input[len(input) - 1] {
			break
		}
	}

	pines := 0
	for x in input {
		index, _ := slice.binary_search(squares[:], x)
		pines += squares[index] - x
	}
	fmt.printfln("[quest 1] [part 1] answer : %d", pines)
}

part_2 :: proc(input: string) {

	input := parse_input(input)
	defer delete(input)

	slice.sort(input[:])

	perimeter: [dynamic]int
	defer delete(perimeter)

	for i := 3;; i += 1 {
		peri := 2 * (i + i - 2)
		append(&perimeter, peri)
		if peri > input[len(input) - 1] {
			break
		}
	}


	pines := 0
	for x in input {
		index, _ := slice.binary_search(perimeter[:], x)
		pines += perimeter[index] - x
	}
	fmt.printfln("[quest 1] [part 2] answer : %d", pines)
}

part_3 :: proc(input: string) {
	input := parse_input(input)
	defer delete(input)

	slice.sort(input[:])

	almost_squares: [dynamic]int
	defer delete(almost_squares)

	for i := 3;; i += 2 {
		almost_square := i * i - 1
		append(&almost_squares, almost_square)
		if almost_square > input[len(input) - 1] {
			break
		}
	}


	pines := 0
	for x in input {
		index, _ := slice.binary_search(almost_squares[:], x)
		pines += almost_squares[index] - x
	}
	fmt.printfln("[quest 1] [part 3] answer : %d", pines)
}
