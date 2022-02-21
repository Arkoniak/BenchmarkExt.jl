include(joinpath(@__DIR__, "main.jl"))

# You can run `Pkg.test("BenchmarkExt", test_args = ["foo", "bar"])` or just
# `Pkg.test(test_args = ["foo", "bar"])` to select only specific tests. If no `test_args`
# is given or you are running usual `> ] test` command, then all tests are executed.
# Strings are used as regexps and you can prepend "-" char before filter match to exclude specific subset of tests, for example `Pkg.test("BenchmarkExt, test_args = ["-foo.*"])` execute all tests except those which starts with `foo`.
if isempty(ARGS)
    BenchmarkExtTest.runtests(spin = false)
else
    BenchmarkExtTest.runtests(map(arg -> startswith(arg, "-") ? not(Regex(arg[2:end])) : Regex(arg), ARGS), spin = false)
end
