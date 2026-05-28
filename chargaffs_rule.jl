using Random, Statistics, Plots, StatsBase
using LinearAlgebra, DataFrames

Random.seed!(42)




function analyze_dna(sequence::String)
    seq = uppercase(sequence)
    bases = Dict(b => count(==(b), seq) for b in "ATGC")
    total = length(seq)

    gc_content = 100.0 * (bases['G'] + bases['C']) / total

    println("Base Composition: ")
    for b in "ATGC"
        pct = round(100 * bases[b] / total; digits = 1)
        println("  $b: $(bases[b]) ($pct%)")
    end
    println("\nGC Content: $(round(gc_content, digits = 1))%")
end



# Human beta-globulin gene frag
hbb_fragment=
