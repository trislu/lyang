usage: basic-usage

test_cases := $(patsubst %.lua, %, $(wildcard *.lua))
$(test_cases):
	@echo "------ Run Testcase ($@.lua) ------" 
	@lua $@.lua
	@echo "------ End ------"
	@echo ""

basic-usage: $(print_cases)
	@echo "Available Options:"
	@printf "\t%-20s - %s\n" "usage" "print this message"
	@printf "\t%-20s - %s\n" "test" "run all the test cases"
	@for case in $(test_cases) ; do \
		printf "\t%-20s - %s\n" $$case "run single case '$$case'"; \
	done

test: $(test_cases)

.PHONY: usage basic-usage test $(test_cases)