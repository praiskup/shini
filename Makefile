BASIC_TESTS = \
	tests/nofork \
	tests/service \
	tests/spaces

TESTS = \
	$(BASIC_TESTS)

check: $(TESTS)

.PHONY: $(TESTS)

$(BASIC_TESTS):
	tests/test_basic.sh $@


clean:
	@rm -f tests/*.out tests/*.err
