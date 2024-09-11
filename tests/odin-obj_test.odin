package odin_obj_tests

import "core:log"
import "core:os"
import "core:strings"
import "core:testing"

import oo "../"

main :: proc() {
	t := testing.T{}

	test_parse_keywords(&t)
}

@(test)
test_parse_keywords :: proc(t: ^testing.T) {
	raw, rok := os.read_entire_file_from_filename("./assets/cube/cube.obj")
	testing.expect(t, rok == true)

	defer delete(raw)

	data := string(raw)

	expected_results: [40]oo.Obj_Keyword = [40]oo.Obj_Keyword {
		.Comment,
		.Comment,
		.Material_Library,
		.Object_Name,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Geometric_Vertex,
		.Vertex_Normal,
		.Vertex_Normal,
		.Vertex_Normal,
		.Vertex_Normal,
		.Vertex_Normal,
		.Vertex_Normal,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Texture_Vertex,
		.Smoothing_Group,
		.Material_Name,
		.Face,
		.Face,
		.Face,
		.Face,
		.Face,
		.Face,
	}

	count := 0
	for line in strings.split_lines_iterator(&data) {
		if len(line) == 0 {
			count += 1
			continue
		}

		keyword := oo.extract_keyword(line)

		testing.expect(t, keyword == expected_results[count])

		count += 1
	}

}
