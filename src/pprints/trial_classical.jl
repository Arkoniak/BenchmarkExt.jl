abstract type AbstractOutput end

show_output(::AbstractOutput, io, ::MIME"text/plain", t) = nothing

struct TrialClassicalOutputPre <: AbstractOutput end
struct TrialClassicalHistogram <: AbstractOutput end
struct TrialClassicalOutputPost <: AbstractOutput end

function show_output(::TrialClassicalOutputPre, io, ::MIME"text/plain", t::Trial)
    if length(t) > 0
        min = minimum(t)
        max = maximum(t)
        med = median(t)
        avg = mean(t)
        memorystr = string(prettymemory(memory(min)))
        allocsstr = string(iallocs(min))
        minstr = string(prettytime(time(min)), " (", prettypercent(gcratio(min)), " GC)")
        maxstr = string(prettytime(time(max)), " (", prettypercent(gcratio(max)), " GC)")
        medstr = string(prettytime(time(med)), " (", prettypercent(gcratio(med)), " GC)")
        meanstr = string(prettytime(time(avg)), " (", prettypercent(gcratio(avg)), " GC)")
    else
        memorystr = "N/A"
        allocsstr = "N/A"
        minstr = "N/A"
        maxstr = "N/A"
        medstr = "N/A"
        meanstr = "N/A"
    end
    println(io, "BenchmarkExt.Trial:")
    pad = get(io, :pad, "")
    println(io, pad, "  memory estimate:  ", memorystr)
    println(io, pad, "  allocs estimate:  ", allocsstr)
    println(io, pad, "  --------------")
    println(io, pad, "  minimum time:     ", minstr)
    println(io, pad, "  median time:      ", medstr)
    println(io, pad, "  mean time:        ", meanstr)
    println(io, pad, "  maximum time:     ", maxstr)
    println(io, pad, "  --------------")
    println(io, pad, "  samples:          ", length(t))
    print(io,   pad, "  evals/sample:     ", t.params.evals)
end
