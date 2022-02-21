module ParametersTests

using ReTest
using BenchmarkExt
using BenchmarkExt: Parameters

@testset "Parameters test" begin
    @test BenchmarkExt.DEFAULT_PARAMETERS == Parameters()

    p = Parameters(seconds = 1, gctrial = false)
    oldseconds = BenchmarkExt.DEFAULT_PARAMETERS.seconds
    oldgctrial = BenchmarkExt.DEFAULT_PARAMETERS.gctrial
    BenchmarkExt.DEFAULT_PARAMETERS.seconds = p.seconds
    BenchmarkExt.DEFAULT_PARAMETERS.gctrial = p.gctrial

    @test p == Parameters()
    @test Parameters(p; evals = 3, time_tolerance = .32) == Parameters(evals = 3, time_tolerance = .32)
    
    BenchmarkExt.DEFAULT_PARAMETERS.seconds = oldseconds
    BenchmarkExt.DEFAULT_PARAMETERS.gctrial = oldgctrial

    p = Parameters(seconds = 1, gctrial = false, samples = 2, evals = 2, overhead = 42,
                   gcsample = false, time_tolerance = 0.043, memory_tolerance = 0.15)
    oldseconds = BenchmarkExt.DEFAULT_PARAMETERS.seconds
    oldgctrial = BenchmarkExt.DEFAULT_PARAMETERS.gctrial
    old_time_tolerance = BenchmarkExt.DEFAULT_PARAMETERS.time_tolerance
    old_memory_tolerance = BenchmarkExt.DEFAULT_PARAMETERS.memory_tolerance
    oldsamples = BenchmarkExt.DEFAULT_PARAMETERS.samples
    oldevals = BenchmarkExt.DEFAULT_PARAMETERS.evals
    oldoverhead = BenchmarkExt.DEFAULT_PARAMETERS.overhead
    oldgcsample = BenchmarkExt.DEFAULT_PARAMETERS.gcsample
    BenchmarkExt.DEFAULT_PARAMETERS.seconds = p.seconds
    BenchmarkExt.DEFAULT_PARAMETERS.gctrial = p.gctrial
    BenchmarkExt.DEFAULT_PARAMETERS.time_tolerance = p.time_tolerance
    BenchmarkExt.DEFAULT_PARAMETERS.memory_tolerance = p.memory_tolerance
    BenchmarkExt.DEFAULT_PARAMETERS.samples = p.samples
    BenchmarkExt.DEFAULT_PARAMETERS.evals = p.evals
    BenchmarkExt.DEFAULT_PARAMETERS.overhead = p.overhead
    BenchmarkExt.DEFAULT_PARAMETERS.gcsample = p.gcsample
    
    @test p == Parameters()
    @test p == Parameters(p)
    
    BenchmarkExt.DEFAULT_PARAMETERS.seconds = oldseconds
    BenchmarkExt.DEFAULT_PARAMETERS.gctrial = oldgctrial
    BenchmarkExt.DEFAULT_PARAMETERS.time_tolerance = old_time_tolerance
    BenchmarkExt.DEFAULT_PARAMETERS.memory_tolerance = old_memory_tolerance
    BenchmarkExt.DEFAULT_PARAMETERS.samples = oldsamples
    BenchmarkExt.DEFAULT_PARAMETERS.evals = oldevals
    BenchmarkExt.DEFAULT_PARAMETERS.overhead = oldoverhead
    BenchmarkExt.DEFAULT_PARAMETERS.gcsample = oldgcsample
end

end # module
