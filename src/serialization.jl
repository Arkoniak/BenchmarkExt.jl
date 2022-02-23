StructTypes.subtypes(::Type{AbstractBenchmark}) = (benchmark_group=BenchmarkGroup,)
const BENCHMARKEXT_VERSION = v"0.1.0"

function snake_case(camelsymbol::Symbol)
    camelstring = String(camelsymbol)

    wordpat = r"
    ^[a-z]+ |                  #match initial lower case part
    [A-Z][a-z]+ |              #match Words Like This
    \d*([A-Z](?=[A-Z]|$))+ |   #match ABBREV 30MW 
    \d+                        #match 1234 (numbers without units)
    "x

    smartlower(word) = any(islowercase, word) ? lowercase(word) : word
    words = [smartlower(m.match) for m in eachmatch(wordpat, camelstring)]

    Symbol(join(words, "_"))
end

# TODO: Add any new types as they're added
const SUPPORTED_TYPES = Dict{Symbol, Symbol}(Base.typename(x).name => snake_case(Base.typename(x).name) for x in [Parameters, BenchmarkGroup, TagFilter, Trial,
    TrialEstimate, TrialJudgement, TrialRatio])
# n.b. Benchmark type not included here, since it is gensym'd

# We can make a macro, which generate this structure when new types appear.
# Or we can just add new fields manually
mutable struct Serializator
    julia::String
    benchmark_version::String
    parameters::Dict{String, Parameters}
    benchmark_group::Dict{String, BenchmarkGroup}
    tag_filter::Dict{String, TagFilter}
    trial::Dict{String, Trial}
    trial_estimate::Dict{String, TrialEstimate}
    trial_judgement::Dict{String, TrialJudgement}
    trial_ratio::Dict{String, TrialRatio}
end
StructTypes.StructType(::Type{Serializator}) = StructTypes.Mutable()
StructTypes.omitempties(::Type{Serializator}) = true
Serializator(julia, version) = Serializator(julia, version, Dict(), Dict(), Dict(), Dict(), Dict(), Dict(), Dict())
Serializator() = Serializator("", "")

function badext(filename)
    noext, ext = splitext(filename)
    msg = "Only JSON serialization is supported, please provide file name in the form \"$noext.json\"."
    throw(ArgumentError(msg))
end

"""
    save(file::Union{String, IO}, args...)

Save `args` to a json file. Arguments `args` can be either `BenchmarkExt` objects or pairs of the form `name => arg`.
"""
function save(filename::AbstractString, args...)
    endswith(filename, ".json") || badext(filename)
    open(filename, "w") do io
        save(io, args...)
    end
end

function save(io::IO, args...)
    isempty(args) && throw(ArgumentError("Nothing to save"))
    ser = Serializator(string(VERSION), string(BENCHMARKEXT_VERSION))
    store = false
    for arg in args
        name = typeof(arg).name.name
        if !haskey(SUPPORTED_TYPES, name)
            arg isa Pair || throw(ArgumentError("Only BenchmarkExt types can be serialized, encountered \"$name\"."))
            name2 = typeof(arg[2]).name.name
            haskey(SUPPORTED_TYPES, name2) || throw(ArgumentError("Only BenchmarkExt types can be serialized, encountered \"$name2\"."))
            getfield(ser, SUPPORTED_TYPES[name2])[string(arg[1])] = arg[2]
        else
            field = getfield(ser, SUPPORTED_TYPES[name])
            field[string(SUPPORTED_TYPES[name])*"_"*string(length(field) + 1)] = arg
        end
        store = true
    end
    isempty(store) && error("Nothing to save")
    JSON3.write(io, ser)

    return nothing
end

"""
    load(file::Union{String, IO}, pattern = "", group = true)

Load benchmark values from json `file`. If `pattern` is not `nothing` then results will be filtered according to `pattern`. If `group` is `true`, then result is given as `Vector{Any}` where all values from all types combined together, otherwise it is returned as `BenchmarkExt.Serializator`.
"""
function load(filename::AbstractString, pattern = nothing, group = true)
    endswith(filename, ".json") || badext(filename)
    open(filename, "r") do f
        load(f, pattern, group)
    end
end

function load(io::IO, pattern = nothing, group = true)
    parsed = JSON3.read(io, Serializator)
    if isempty(parsed.julia) || isempty(parsed.benchmark_version)
        error("Unexpected JSON format") 
    end
    if pattern !== nothing
        for name in values(SUPPORTED_TYPES)
            field = getfield(parsed, name)
            filter!(x -> occursin(pattern, x[1]), field)
        end
    end

    group || return parsed

    res = []
    for name in fieldnames(Serializator)
        name in values(SUPPORTED_TYPES) || continue
        append!(res, values(getfield(parsed, name)))
    end

    return res
end
