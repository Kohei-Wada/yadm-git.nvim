.PHONY: test lint

test:
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory tests { minimal_init = './scripts/minimal_init.vim' }"

lint:
	luacheck lua/yadm-git
