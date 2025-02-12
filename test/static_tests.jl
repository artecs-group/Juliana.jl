using Test
using Juliana
using Printf

function ast_compare(ast1, ast2)
    ast1_c = deepcopy(ast1)
    ast2_c = deepcopy(ast2)
    Base.remove_linenums!(ast1_c)
    Base.remove_linenums!(ast2_c)
    str1 = string(ast1_c)
    str2 = string(ast2_c)
    res = string(Meta.parse(str1)) == string(Meta.parse(str2))
    if !res
        @error Meta.parse(str1)
        @error Meta.parse(str2)
    end
    return res
end
function parse(ast_str)
    return Meta.parse("begin " * ast_str * " end")
end

@testset "Process Kernels" begin
    kernel1_str = """
    function kernel_1()
        return nothing
    end
    """
    kernel1_str_truth = """
    KernelAbstractions.@kernel function kernel_1()
        begin
            var_kernel_1 = nothing
            @goto end_kernel_1_0
        end
        @label end_kernel_1_0
    end
    """
    res_ast = Juliana.process_kernels!(parse(kernel1_str), [:kernel_1], [])
    @test ast_compare(res_ast, parse(kernel1_str_truth))
end