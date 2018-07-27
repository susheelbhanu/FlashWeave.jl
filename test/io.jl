using Base.Test
using FlashWeave
using SimpleWeightedGraphs

net_result = load_network(joinpath("data", "io_expected.jld2"))

@testset "networks" begin
    tmp_path = tempname()

    for net_format in ["edgelist", "gml", "jld2", "jld"]
        @testset "$net_format" begin
            tmp_net_path = tmp_path * "." * net_format
            save_network(tmp_net_path, net_result)
            net_result_ld = load_network(tmp_net_path)
            @test graph(net_result_ld) == graph(net_result)
        end
    end
end


data, header = readdlm(joinpath("data", "HMP_SRA_gut", "HMP_SRA_gut_small.tsv"), '\t', header=true)
data = Matrix{Int}(data[1:19, 2:20])
header = Vector{String}(header[2:20])
meta_data, meta_header = readdlm(joinpath("data", "HMP_SRA_gut", "HMP_SRA_gut_tiny_meta.tsv"), '\t', Int, header=true)
meta_header = Vector{String}(meta_header[:])


@testset "table data" begin
    tmp_path = tempname()

    for (data_format, data_suff, meta_suff) in zip(["tsv", "tsv_rownames", "csv", "biom_json", "biom_hdf5", "jld2", "jld"],
                                                   [".tsv", "_ids.tsv", ".csv", "_json.biom", "_hdf5.biom", "_plus_meta.jld2", "_plus_meta.jld"],
                                                   ["_meta.tsv", "_meta.csv", "_meta.csv", "_meta.tsv", "_meta.tsv", "", ""])
        @testset "$data_format" begin
            data_path, meta_path = [joinpath("data", "HMP_SRA_gut", "HMP_SRA_gut_tiny" * suff) for suff in [data_suff, meta_suff]]
            data_ld = load_data(data_path, meta_path)
            @test all(data_ld[1] .== data)
            @test all(data_ld[2] .== header)
            @test all(data_ld[3] .== meta_data)
            @test all(data_ld[4] .== meta_header)
        end
    end
end


@testset "transposed" begin
    tmp_path = tempname()

    for (data_format, data_suff, meta_suff) in zip(["tsv", "jld", "jld2"],
                                                   ["_ids_transposed.tsv", "_plus_meta_transposed.jld", "_plus_meta_transposed.jld2"],
                                                   ["_meta_transposed.tsv", "", ""])
        @testset "$data_format" begin
            data_path, meta_path = [joinpath("data", "HMP_SRA_gut", "HMP_SRA_gut_tiny" * suff) for suff in [data_suff, meta_suff]]
            data_ld = load_data(data_path, meta_path, transposed=true)
            @test all(data_ld[1] .== data)
            @test all(data_ld[2] .== header)
            @test all(data_ld[3] .== meta_data)
            @test all(data_ld[4] .== meta_header)
        end
    end
end





# to create expected output
# using FileIO
# using FlashWeave
#
# function make_network(data, test_name, make_sparse=false, prec=64, verbose=false; kwargs...)
#     data_norm = FlashWeave.preprocess_data_default(data, test_name, verbose=false, make_sparse=make_sparse, prec=prec)
#     kwargs_dict = Dict(kwargs)
#     graph_res = FlashWeave.LGL(data_norm; test_name=test_name, verbose=verbose,  kwargs...)
#     graph_res
# end
#
# data = Matrix{Float64}(readdlm(joinpath("data", "HMP_SRA_gut_small.tsv"), '\t')[2:end, 2:end])
#
# max_k = 3
# make_sparse = false
# parallel = "single"
# test_name = "mi"
# lgl_res = make_network(data, test_name, make_sparse, 64, true, max_k=max_k, parallel=parallel, time_limit=30.0, correct_reliable_only=false, n_obs_min=0, debug=0, verbose=true, FDR=true, weight_type="cond_stat")
# save(joinpath("data", "io_expected.jld2"), "results", lgl_res)
