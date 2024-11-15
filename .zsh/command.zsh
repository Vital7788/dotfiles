
# Clean up patch file
scrub_patch() {
	sed -i \
		-e '/^index /d' \
		-e '/^new file mode /d' \
		-e '/^Index:/d' \
		-e '/^=========/d' \
		-e '/^RCS file:/d' \
		-e '/^retrieving/d' \
		-e '/^diff/d' \
		-e '/^Files .* differ$/d' \
		-e '/^Only in /d' \
		-e '/^Common subdirectories/d' \
		-e '/^deleted file mode [0-9]*$/d' \
		-e '/^+++/s:\t.*::' \
		-e '/^---/s:\t.*::' \
		"$@"
}