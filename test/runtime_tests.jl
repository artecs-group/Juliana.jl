using Test
using Juliana
using Printf

@testset "Vector Add" begin
    input_file  = joinpath(@__DIR__, "input-files", "vecadd.jl")
    output_dir  = joinpath(@__DIR__, "output-files")
    output_file = joinpath(output_dir, "vecadd.jl")

    Juliana.translate_file(input_file, output_dir);
    output = read(`julia $output_file`, String)

    N = 2048
    A = fill(6.0, N)
    expected = "[" * join([@sprintf("%.1f", x) for x in A], ", ") * "]\n"

    @test output == expected
end