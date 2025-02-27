module Juliana

	using MacroTools
	using SyntaxTree
	using TOML
	using KAUtils

	include("warnings.jl")
	include("utils.jl")
	include("quoting_handling.jl")
	include("preprocessing.jl")
	include("processing.jl")
	include("postprocessing.jl")

	export translate_files, translate_file, translate_pkg, dump_gpu_info

	function translate_pkg(pkg_input_path, pkg_output_path, extra_files=[], extra_knames=[], extra_kfuncs=[], gpu_sim="NVIDIA_GeForce_GTX_950")
		toml_path = pkg_input_path * "/Project.toml"
		toml_file = TOML.parsefile(toml_path)
		toml_file["deps"]["KernelAbstractions"] = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
		toml_file["deps"]["KAUtils"] = "d4a7e5c6-9d4b-4b5c-9d4b-3a3b0b6b4c7c"
		toml_file["deps"]["GPUArrays"] = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
		open(toml_path, "w") do io
			TOML.print(io, toml_file)
		end
		pkg_name = toml_file["name"]
		@info "Translating the package " * pkg_name
		main_file_path = pkg_input_path * "/src/" * pkg_name * ".jl"
		run_tests_file_path = pkg_input_path * "/test/runtests.jl"
		Base.Filesystem.cptree(pkg_input_path, pkg_output_path, force=true)

		if isfile(run_tests_file_path)
			push!(extra_files, run_tests_file_path)
		end

		output_paths = joinpath.(pkg_output_path, relpath.(dirname.([main_file_path, extra_files...]), pkg_input_path))
		

		translate_files(vcat(main_file_path, extra_files), output_paths , extra_knames, extra_kfuncs, gpu_sim)		
	end

	function translate_files(filepaths, output_dirs, extra_knames=[], extra_kfuncs=[], gpu_sim="NVIDIA_GeForce_GTX_950")
		@info "Translating " * string(filepaths)
		asts, kernel_names, require_ctx_funcs = preprocess(filepaths, extra_knames, extra_kfuncs)
		asts = process(asts, kernel_names, require_ctx_funcs, gpu_sim)
		asts = postprocess(asts, output_dirs)	
		println("Warnings: ")
    	print_warnings()
	end

	translate_file(filepath, output_dir, extra_knames=[], extra_kfuncs=[], gpu_sim="NVIDIA_GeForce_GTX_950") = translate_files([filepath], [output_dir], extra_knames, extra_kfuncs, gpu_sim)


end
