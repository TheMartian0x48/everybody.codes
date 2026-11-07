package year_2026_quest_1

import q "core:container/queue"
import "core:fmt"
import "core:os"
import "core:slice"
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
		{{"./sample_e2026_q02_p1.txt", "./everybody_codes_e2026_q02_p1.txt"}, part_1},
		{{"./sample_e2026_q02_p2.txt", "./everybody_codes_e2026_q02_p2.txt"}, part_2},
		{{"./sample_e2026_q02_p3.txt", "./everybody_codes_e2026_q02_p3.txt"}, part_3},
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


Edge :: struct {
	from: u8,
	to:   u8,
}

parse_input :: proc(file: string) -> [dynamic][dynamic]Edge {
	data, _ := os.read_entire_file_from_path(file, context.allocator)
	input := string(data)

	groups := [dynamic][dynamic]Edge{}
	for line in strings.split_lines_iterator(&input) {
		line := line
		group := [dynamic]Edge{}
		for edge in strings.split_iterator(&line, " ") {
			a := edge[0] - '0'
			b := edge[2] - '0'
			if edge[1] == '>' {
				a, b = b, a
			}
			append(&group, {a, b})
		}
		append(&groups, group)
	}
	return groups
}

parse_destroy :: proc(groups: [dynamic][dynamic]Edge) {
	for g in groups {
		delete(g)
	}
	delete(groups)
}

topological_sort :: proc(graph: [dynamic]Edge) -> [dynamic]u8 {
	max_node_value: u8 = 1
	for e in graph {
		max_node_value = max(max_node_value, e.to)
		max_node_value = max(max_node_value, e.from)
	}
	adj := make([][dynamic]u8, max_node_value + 1)
	indeg := make([]int, max_node_value + 1)
	for e in graph {
		append(&adj[e.from], e.to)
		indeg[e.to] += 1
	}

	defer {
		delete(indeg)
		for a in adj {
			delete(a)
		}
		delete(adj)
	}


	task: q.Queue(u8)
	q.init(&task)
	defer q.destroy(&task)

	for i in 1 ..< (max_node_value + 1) {
		if indeg[i] == 0 {
			q.push_back(&task, u8(i))
		}
	}

	order := [dynamic]u8{}
	for {
		u := q.pop_front(&task)
		append(&order, u)
		for v in adj[u] {
			indeg[v] -= 1
			if indeg[v] == 0 {
				q.push_back(&task, v)
			}
		}
		if q.len(task) == 0 {
			break
		}
	}

	return order
}

part_1 :: proc(file: string) {

	groups := parse_input(file)
	defer parse_destroy(groups)

	checksum := 0
	for group in groups {
		sorted_group := topological_sort(group)
		defer delete(sorted_group)
		slice.reverse(sorted_group[:])
		n := 0
		for e in sorted_group {
			n = n * 10 + int(e)
		}
		checksum += n
	}

	fmt.printfln("[quest 2] [part 1] answer : %d", checksum)
}

part_2 :: part_1
part_3 :: part_1
