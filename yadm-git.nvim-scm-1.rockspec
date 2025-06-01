rockspec_format = "3.0"
package = "yadm-git.nvim"
version = "scm-1"

test_dependencies = {
   "lua = 5.1",
}

source = {
   url = "git://github.com/Kohei-Wada/" .. package,
}

build = {
   type = "builtin",
}
