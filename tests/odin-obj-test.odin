package odin_obj_tests

import "core:fmt"
import "core:log"
import "core:testing"

import oo "../"

_ :: log

main :: proc() {
	t := testing.T{}

	test_separator_index(&t)
	test_new_element_index(&t)
}

@(test)
test_separator_index :: proc(t: ^testing.T) {
	test_values := [?]string {
		"1/1",
		"112923/2",
		"3424/152/232",
		"3424/152/232",
		"1292999323/1232324",
		"12/42/124",
		"12/42/124",
	}

	test_offsets := [?]int{0, 0, 0, 5, 0, 0, 3}

	expected := [?]int{1, 6, 4, 8, 10, 2, 5}

	for idx in 0 ..< len(test_values) {
		v := oo.separator_index(test_values[idx], test_offsets[idx])

		testing.expect(
			t,
			v == expected[idx],
			fmt.tprintf("Expected: %v, Actual: %v", expected[idx], v),
		)
	}
}

@(test)
test_new_element_index :: proc(t: ^testing.T) {
	test_values := [?]string {
		"1.000000 1.000000 -1.000000",
		"1.000000 -1.000000 -1.000000",
		"1.000000 1.000000",
	}

	test_offsets := [?]int{0, 9, 17}
	expected_ok := [?]bool{true, true, false}
	expected_values := [?]int{8, 18, -1}

	for idx in 0 ..< len(test_values) {
		v, ok := oo.new_element_index(test_values[idx], test_offsets[idx])
		testing.expect(
			t,
			ok == expected_ok[idx],
			fmt.tprintf("Expected: %v, Actual: %v", expected_values[idx], v),
		)

		testing.expect(
			t,
			v == expected_values[idx],
			fmt.tprintf("Expected: %v, Actual: %v", expected_values[idx], v),
		)
	}
}
