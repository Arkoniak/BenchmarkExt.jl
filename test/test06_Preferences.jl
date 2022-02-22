module PreferencesTests

using BenchmarkExt
using ReTest
using Logging

using BenchmarkExt: set_preferences!, save_preferences!, load_preferences!
using BenchmarkExt: get_prefs_path, initialize_prefs, Preferences

@testset "Public API" begin
    @testset "set_preferences" begin
        prefs = Preferences("classical", "classical")
        set_preferences!(prefs; benchmark_output = "fancy", benchmark_histogram = "fancy")
        @test prefs.benchmark_output == "fancy"
        @test prefs.benchmark_histogram == "fancy"

        with_logger(NullLogger()) do
            set_preferences!(prefs; benchmark_output = "foobar", foo = "baz")
            @test prefs.benchmark_output == "fancy"
        end
    end

    @testset "save and load preferences" begin
        epath = ""
        if haskey(ENV, "JULIA_BENCHMARKEXT_CONFIG")
            epath = pop!(ENV, "JULIA_BENCHMARKEXT_CONFIG")
        end
        default = "test_benchmark_ext.toml"
        path = get_prefs_path(default)
        rm(path, force = true)
        
        prefs = Preferences("foo", "bar")
        save_preferences!(prefs, default)
        
        prefs2 = Preferences("", "")
        load_preferences!("", prefs2, default)
        @test prefs2.benchmark_output == "foo"
        @test prefs2.benchmark_histogram == "bar"

        prefs3 = Preferences("", "")
        initialize_prefs(prefs3, default)
        @test prefs3.benchmark_output == "foo"
        @test prefs3.benchmark_histogram == "bar"

        path = get_prefs_path(default)
        rm(path, force = true)
        isempty(epath) || (ENV["JULIA_BENCHMARKEXT_CONFIG"] = epath)
    end
end

end # module
