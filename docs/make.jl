using BenchmarkExt
using Documenter
using DocThemeIndigo
indigo = DocThemeIndigo.install(BenchmarkExt)

makedocs(;
    modules=[BenchmarkExt],
    repo="https://github.com/JuliaCI/BenchmarkExt.jl/blob/{commit}{path}#{line}",
    sitename="BenchmarkExt.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaCI.github.io/BenchmarkExt.jl",
        assets=String[indigo],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => "manual.md",
        "Linux-based environments" => "linuxtips.md",
        "Reference" => "reference.md",
        hide("Internals" => "internals.md"),
    ],
)

deploydocs(;
    repo="github.com/JuliaCI/BenchmarkExt.jl",
)
