using SymbolServer, Pkg
using SymbolServer: packagename, packageuuid, deps, manifest, project, version, Package, frommanifest
using Base:UUID
using Test

@testset "SymbolServer" begin

    mktempdir() do path
        cp(joinpath(@__DIR__, "testenv", "Project.toml"), joinpath(path, "Project.toml"))
        cp(joinpath(@__DIR__, "testenv", "Manifest.toml"), joinpath(path, "Manifest.toml"))

        jl_cmd = joinpath(Sys.BINDIR, Base.julia_exename())
        run(`$jl_cmd --project=$path --startup-file=no -e 'using Pkg; Pkg.instantiate()'`)

        ssi = SymbolServerInstance("")
        results = Channel(Inf)
        getstore(ssi, path, results)
        store = take!(results)

        @test length(store) == 6
        @test haskey(store, "Core")
        @test haskey(store, "Base")
        @test haskey(store, "Base64")
        @test haskey(store, "IteratorInterfaceExtensions")
        @test haskey(store, "Markdown")
        @test haskey(store, "TableTraits")

        # TODO Test more things that should be present in the store
    end
end
