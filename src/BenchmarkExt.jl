module BenchmarkExt

using Base.Iterators

using Logging: @logmsg, LogLevel
using Statistics
using UUIDs: uuid4
using Printf
using Profile
using TOML
using StructTypes
using JSON3

const BENCHMARKEXT_VERSION = v"0.1.0"

########################################
# Preferences
########################################

include("preferences.jl")

# Public unexported API:
#    set_preferences,
#    save_preferences!,
#    load_preferences!


########################################
# Parameters
########################################

include("parameters.jl")

export loadparams!

########################################
# Trial Data
########################################

include("trials.jl")

export gctime,
       memory,
       allocs,
       params,
       ratio,
       judge,
       isinvariant,
       isregression,
       isimprovement,
       median,
       mean,
       rmskew!,
       rmskew,
       trim

########################################
# Benchmark Data
########################################

include("groups.jl")

export BenchmarkGroup,
       invariants,
       regressions,
       improvements,
       @tagged,
       addgroup!,
       leaves,
       @benchmarkset,
       @case

########################################
# Execution Strategy 
########################################

include("execution.jl")

export tune!,
       warmup,
       @ballocated,
       @benchmark,
       @benchmarkable,
       @belapsed,
       @btime,
       @bprofile

########################################
# Serialization
########################################

include("serialization.jl")

########################################
# Pretty printing
########################################

include("pprints/trial_classical.jl")
include("pprints/trial_fancy.jl")

########################################
# Initialization
########################################

include("init.jl")

end # module BenchmarkExt
