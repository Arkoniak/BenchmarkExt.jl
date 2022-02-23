struct TrialFancyOutputPre end

function prep_trial_fancy_data(t::Trial)
    length(t) > 1 || return nothing

    perm = sortperm(t.times)
    times = t.times[perm]
    gctimes = t.gctimes[perm]

    med = median(t)
    avg = mean(t)
    std = Statistics.std(t)
    min = minimum(t)
    max = maximum(t)

    medtime, medgc = prettytime(time(med)), prettypercent(gcratio(med))
    avgtime, avggc = prettytime(time(avg)), prettypercent(gcratio(avg))
    stdtime, stdgc = prettytime(time(std)), prettypercent(Statistics.std(gctimes ./ times))
    mintime, mingc = prettytime(time(min)), prettypercent(gcratio(min))
    maxtime, maxgc = prettytime(time(max)), prettypercent(gcratio(max))

    memorystr = string(prettymemory(memory(min)))
    allocsstr = string(iallocs(min))
    
    return (perm, times, gctimes,
            med, avg, std, min, max,
            medtime, medgc,
            avgtime, avggc,
            stdtime, stdgc,
            mintime, mingc,
            maxtime, maxgc,
            memorystr, allocsstr)
end

function show_output(::TrialFancyOutputPre, io, ::MIME"text/plain", t::Trial)
    pad = get(io, :pad, "")
    print(io, "BenchmarkExt.Trial: ", length(t), " sample", if length(t) > 1 "s" else "" end,
          " with ", t.params.evals, " evaluation", if t.params.evals > 1 "s" else "" end ,".\n")

    if length(t) > 1
       (perm, times, gctimes,
            med, avg, std, min, max,
            medtime, medgc,
            avgtime, avggc,
            stdtime, stdgc,
            mintime, mingc,
            maxtime, maxgc,
            memorystr, allocsstr) = prep_trial_fancy_data(t)
    elseif length(t) == 1
        perm = sortperm(t.times)
        times = t.times[perm]
        gctimes = t.gctimes[perm]

        print(io, pad, " Single result which took ")
        printstyled(io, prettytime(times[1]); color=:blue)
        print(io, " (", prettypercent(gctimes[1]/times[1]), " GC) ")
        print(io, "to evaluate,\n")
        print(io, pad, " with a memory estimate of ")
        printstyled(io, prettymemory(t.memory[1]); color=:yellow)
        print(io, ", over ")
        printstyled(io, t.allocs[1]; color=:yellow)
        print(io, " allocations.")
        return
    else
        print(io, pad, " No results.")
        return
    end

    lmaxtimewidth = maximum(length.((medtime, avgtime, mintime)))
    rmaxtimewidth = maximum(length.((stdtime, maxtime)))
    lmaxgcwidth = maximum(length.((medgc, avggc, mingc)))
    rmaxgcwidth = maximum(length.((stdgc, maxgc)))

    # Main stats

    print(io, pad, " Range ")
    printstyled(io, "("; color=:light_black)
    printstyled(io, "min"; color=:cyan, bold=true)
    print(io, " … ")
    printstyled(io, "max"; color=:magenta)
    printstyled(io, "):  "; color=:light_black)
    printstyled(io, lpad(mintime, lmaxtimewidth); color=:cyan, bold=true)
    print(io, " … ")
    printstyled(io, lpad(maxtime, rmaxtimewidth); color=:magenta)
    print(io, "  ")
    printstyled(io, "┊"; color=:light_black)
    print(io, " GC ")
    printstyled(io, "("; color=:light_black)
    print(io, "min … max")
    printstyled(io, "): "; color=:light_black)
    print(io, lpad(mingc, lmaxgcwidth), " … ", lpad(maxgc, rmaxgcwidth))

    print(io, "\n", pad, " Time  ")
    printstyled(io, "("; color=:light_black)
    printstyled(io, "median"; color=:blue, bold=true)
    printstyled(io, "):     "; color=:light_black)
    printstyled(io, lpad(medtime, lmaxtimewidth), rpad(" ", rmaxtimewidth + 5); color=:blue, bold=true)
    printstyled(io, "┊"; color=:light_black)
    print(io, " GC ")
    printstyled(io, "("; color=:light_black)
    print(io, "median")
    printstyled(io, "):    "; color=:light_black)
    print(io, lpad(medgc, lmaxgcwidth))

    print(io, "\n", pad, " Time  ")
    printstyled(io, "("; color=:light_black)
    printstyled(io, "mean"; color=:green, bold=true)
    print(io, " ± ")
    printstyled(io, "σ"; color=:green)
    printstyled(io, "):   "; color=:light_black)
    printstyled(io, lpad(avgtime, lmaxtimewidth); color=:green, bold=true)
    print(io, " ± ")
    printstyled(io, lpad(stdtime, rmaxtimewidth); color=:green)
    print(io, "  ")
    printstyled(io, "┊"; color=:light_black)
    print(io, " GC ")
    printstyled(io, "("; color=:light_black)
    print(io, "mean ± σ")
    printstyled(io, "):  "; color=:light_black)
    print(io, lpad(avggc, lmaxgcwidth), " ± ", lpad(stdgc, rmaxgcwidth))

end

struct TrialFancyHistogram end

function show_output(::TrialFancyHistogram, io, ::MIME"text/plain", t::Trial)
    length(t) <= 1 && return
    pad = get(io, :pad, "")
    (perm, times, gctimes,
     med, avg, std, min, max,
     medtime, medgc,
     avgtime, avggc,
     stdtime, stdgc,
     mintime, mingc,
     maxtime, maxgc,
     memorystr, allocsstr) = prep_trial_fancy_data(t)

    lmaxtimewidth = maximum(length.((medtime, avgtime, mintime)))
    rmaxtimewidth = maximum(length.((stdtime, maxtime)))
    lmaxgcwidth = maximum(length.((medgc, avggc, mingc)))
    rmaxgcwidth = maximum(length.((stdgc, maxgc)))

    histquantile = 0.99
    # The height and width of the printed histogram in characters.
    histheight = 2
    histwidth = 42 + lmaxtimewidth + rmaxtimewidth

    histtimes = times[1:round(Int, histquantile*end)]
    histmin = get(io, :histmin, first(histtimes))
    histmax = get(io, :histmax, last(histtimes))
    logbins = get(io, :logbins, nothing)
    bins = bindata(histtimes, histwidth - 1, histmin, histmax)
    append!(bins, [1, floor((1-histquantile) * length(times))])
    # if median size of (bins with >10% average data/bin) is less than 5% of max bin size, log the bin sizes
    if logbins === true || (logbins === nothing && median(filter(b -> b > 0.1 * length(times) / histwidth, bins)) / maximum(bins) < 0.05)
        bins, logbins = log.(1 .+ bins), true
    else
        logbins = false
    end
    hist = asciihist(bins, histheight)
    hist[:,end-1] .= ' '
    maxbin = maximum(bins)

    delta1 = (histmax - histmin) / (histwidth - 1)
    if delta1 > 0
        medpos = 1 + round(Int, (histtimes[length(times) ÷ 2] - histmin) / delta1)
        avgpos = 1 + round(Int, (mean(times) - histmin) / delta1)
    else
        medpos, avgpos = 1, 1
    end

    print(io, "\n")
    for r in axes(hist, 1)
        print(io, "\n", pad, "  ")
        for (i, bar) in enumerate(view(hist, r, :))
            color = :default
            if i == avgpos color = :green end
            if i == medpos color = :blue end
            printstyled(io, bar; color=color)
        end
    end

    remtrailingzeros(timestr) = replace(timestr, r"\.?0+ " => " ")
    minhisttime, maxhisttime = remtrailingzeros.(prettytime.(round.([histmin, histmax], sigdigits=3)))

    print(io, "\n", pad, "  ", minhisttime)
    caption = "Histogram: " * ( logbins ? "log(frequency)" : "frequency" ) * " by time"
    if logbins
        printstyled(io, " " ^ ((histwidth - length(caption)) ÷ 2 - length(minhisttime)); color=:light_black)
        printstyled(io, "Histogram: "; color=:light_black)
        printstyled(io, "log("; bold=true, color=:light_black)
        printstyled(io, "frequency"; color=:light_black)
        printstyled(io, ")"; bold=true, color=:light_black)
        printstyled(io, " by time"; color=:light_black)
    else
        printstyled(io, " " ^ ((histwidth - length(caption)) ÷ 2 - length(minhisttime)), caption; color=:light_black)
    end
    print(io, lpad(maxhisttime, ceil(Int, (histwidth - length(caption)) / 2) - 1), " ")
    printstyled(io, "<"; bold=true)
end

struct TrialFancyOutputPost end

function show_output(::TrialFancyOutputPost, io, ::MIME"text/plain", t::Trial)
    # Memory info
    length(t) <= 1 && return
    pad = get(io, :pad, "")
    (perm, times, gctimes,
     med, avg, std, min, max,
     medtime, medgc,
     avgtime, avggc,
     stdtime, stdgc,
     mintime, mingc,
     maxtime, maxgc,
     memorystr, allocsstr) = prep_trial_fancy_data(t)

    print(io, "\n\n", pad, " Memory estimate")
    printstyled(io, ": "; color=:light_black)
    printstyled(io, memorystr; color=:yellow)
    print(io, ", allocs estimate")
    printstyled(io, ": "; color=:light_black)
    printstyled(io, allocsstr; color=:yellow)
    print(io, ".")
end
