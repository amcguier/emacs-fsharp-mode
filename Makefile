# Directories

base_d = $(abspath ..)/
test_d = $(abspath test)/
tmp_d  = $(abspath tmp)/
bin_d  = $(abspath bin)/

# Elisp files required for tests.
src_files         = $(wildcard ./*.el)
integration_tests = $(test_d)integration-tests.el
unit_tests        = $(filter-out $(integration_tests), $(wildcard $(test_d)*tests.el))
utils             = $(test_d)test-common.el $(test_d)pos-tip-mock.el

# Emacs command format.
emacs            = emacs
load_files       = $(patsubst %,-l %, $(utils))
load_unit_tests  = $(patsubst %,-l %, $(unit_tests))
load_integration_tests = $(patsubst %,-l %, $(integration_tests))
emacs_opts       = --batch -f run-fsharp-tests

# HACK: Vars for manually building the ac binary.
# We should be really able to use the top-level makefile for this...
ac_exe    = $(bin_d)fsautocomplete.exe
ac_fsproj = $(base_d)FSharp.AutoComplete/FSharp.AutoComplete.fsproj
ac_out    = $(base_d)FSharp.AutoComplete/bin/Debug/

# Installation paths.
dest_root = $(HOME)/.emacs.d/fsharp-mode/
dest_bin  = $(HOME)/.emacs.d/fsharp-mode/bin/

# ----------------------------------------------------------------------------

.PHONY : env test unit-test integration-test packages clean-elc install

clean : clean-elc
	rm -fr $(bin_d)
	rm -rf $(tmp_d)

clean-elc :
	rm -f  *.elc
	rm -f  $(test_d)*.elc

# Building

install : $(ac_exe) $(dest_root) $(dest_bin)

	for f in $(src_files); do \
		cp $$f $(dest_root) ;\
	done

	cp -R $(bin_d) $(dest_bin)


$(ac_exe) : $(bin_d)
	xbuild $(ac_fsproj) /property:OutputPath=$(bin_d)

$(dest_root) :; mkdir -p $(dest_root)
$(dest_bin)  :; mkdir -p $(dest_bin)
$(bin_d)     :; mkdir -p $(bin_d)

# Testing

test unit-test : packages
	HOME=$(tmp_d) ;\
	$(emacs) $(load_files) $(load_unit_tests) $(emacs_opts)

integration-test : $(ac_exe) packages
	cd $(test_d) ;\
	HOME=$(tmp_d) ;\
	$(emacs) $(load_files) $(load_integration_tests) $(emacs_opts)

test-all : unit-test integration-test

packages :
	HOME=$(tmp_d) ;\
	$(emacs) $(load_files) --batch -f load-packages
