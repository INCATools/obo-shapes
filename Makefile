# This Makefile assumes you have the Jena command-line tools installed,
# including the `shacl` and `shex` commands.

all: validate-shapes run-all-shex run-all-shacl

.PHONY: all validate run-all-shacl run-all-shex clean

validate-shapes: .validate-shex .validate-shacl

# Validate the ShEx file; ignore parsed structure output.
.validate-shex: shex/obo-shapes.shex
	shex p -q $< >/dev/null #&& touch $@ # Disable this marker file until Jena shex is fixed to exit with non-zero code on failure: https://github.com/apache/jena/issues/1257

# Validate the SHACL file; ignore parsed structure output.
.validate-shacl: shacl/obo-shapes.ttl
	shacl p -q $< >/dev/null && touch $@

PASS_FILES := $(wildcard test-data/pass/*)
FAIL_FILES := $(wildcard test-data/fail/*)
SHACL_PASS_OUT := $(patsubst test-data/pass/%,output/pass/%-shacl.out,$(PASS_FILES))
SHACL_FAIL_OUT := $(patsubst test-data/fail/%,output/fail/%-shacl.out,$(FAIL_FILES))
SHEX_PASS_OUT := $(patsubst test-data/pass/%,output/pass/%-shex.out,$(PASS_FILES))
SHEX_FAIL_OUT := $(patsubst test-data/fail/%,output/fail/%-shex.out,$(FAIL_FILES))

output/%-shacl.out: test-data/% shacl/obo-shapes.ttl .validate-shacl
	mkdir -p $(dir $@)
	shacl v --shapes shacl/obo-shapes.ttl --data $< >$@ #--text 

output/%-shex.out: test-data/% shex/obo-shapes.shex shex/obo-shapes.shapeMap .validate-shex
	mkdir -p $(dir $@)
	shex v --schema shex/obo-shapes.shex --data $< --map shex/obo-shapes.shapeMap --text >$@

run-all-shacl: $(SHACL_PASS_OUT) $(SHACL_FAIL_OUT)

run-all-shex: $(SHEX_PASS_OUT) $(SHEX_FAIL_OUT)

clean:
	rm -rf output
