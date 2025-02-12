using CUDA
using Printf

function kernel_vadd!(C, A, B)
    i = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    if i <= length(C)
        @inbounds C[i] = A[i] + B[i]
    end
    return
end

function gpu_vadd(A::Vector{T}, B::Vector{T}) where {T<:Number}
    dA = CuArray(A)
    dB = CuArray(B)
    dC = similar(dA)

    threads = 256
    blocks  = cld(length(A), threads)

    @cuda threads=threads blocks=blocks kernel_vadd!(dC, dA, dB)

    return Array(dC)
end

N = 2048
A = fill(2.5f0, N)
B = fill(3.5f0, N)
C = gpu_vadd(A, B)

println("[" * join([@sprintf("%.1f", x) for x in C], ", ") * "]")
