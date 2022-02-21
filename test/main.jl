module BenchmarkExtTest

const TEST_NAMES = String[]
const TEST_TIMES = Float64[]

for file in sort([file for file in readdir(@__DIR__) if
                  occursin(r"^test.*\.jl$", file)])
    test_name = split(file, "_")[2]
    test_name = split(test_name, ".")[1]
    push!(TEST_NAMES, test_name)

    took_seconds = @elapsed include(file)
    push!(TEST_TIMES, took_seconds)
end

for (name, time) in zip(TEST_NAMES, TEST_TIMES)
    println("Test $name took $time seconds")
end

end # module
