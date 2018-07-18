using Base.Test
using FlashWeave
using FlashWeave.Types: LGLResult, RejDict, HitonState
using JLD2, FileIO
using SimpleWeightedGraphs

G = load(joinpath("data", "io_expected.jld"))["graph"]
net_result = LGLResult(G)

@testset "networks" begin
    tmp_path = tempname()

    for net_format in ["edgelist", "jld"]
        @testset "$net_format" begin
            tmp_net_path = tmp_path * "." * net_format
            FlashWeave.Io.save_network(tmp_net_path, net_result)
            net_result_ld = FlashWeave.Io.load_network(tmp_net_path)
            @test net_result_ld.graph == net_result.graph
        end
    end
end


data, header = readdlm(joinpath("data", "HMP_SRA_gut_small.tsv"), '\t', header=true)
data = Matrix{Int}(data[1:19, 2:20])
header = Vector{String}(header[2:20])
meta_data, meta_header = readdlm(joinpath("data", "HMP_SRA_gut_tiny_meta.tsv"), '\t', Int, header=true)
meta_header = Vector{String}(meta_header[:])


@testset "input data" begin
    tmp_path = tempname()

    for (data_format, data_suff, meta_suff) in zip(["tsv", "csv", "biom", "jld"],
                                                   [".tsv", ".csv", ".biom", "_plus_meta.jld"],
                                                   ["_meta.tsv", "_meta.csv", "", ""])
        @testset "$data_format" begin
            data_path, meta_path = [joinpath("data", "HMP_SRA_gut_tiny" * suff) for suff in [data_suff, meta_suff]]
            data_ld = FlashWeave.Io.load_data(data_path, meta_path)

            if data_format == "biom"
                @test_broken 1 == 2
            else
                @test all(data_ld[1] .== data)
                @test all(data_ld[2] .== header)
                @test all(data_ld[3] .== meta_data)
                @test all(data_ld[4] .== meta_header)
            end
        end
    end
end


# to create expected output

# function make_network(data, test_name, make_sparse=false, prec=64, verbose=false; kwargs...)
#     data_norm = FlashWeave.Preprocessing.preprocess_data_default(data, test_name, verbose=false, make_sparse=make_sparse, prec=prec)
#     kwargs_dict = Dict(kwargs)
#     graph_res = FlashWeave.Learning.LGL(data_norm; test_name=test_name, verbose=verbose,  kwargs...)
#     graph_res.graph
# end
#
# data = Matrix{Float64}(readdlm(joinpath("data", "HMP_SRA_gut_small.tsv"), '\t')[2:end, 2:end])
#
# max_k = 3
# make_sparse = false
# parallel = "single"
# test_name = "mi"
# graph = make_network(data, test_name, make_sparse, 64, true, max_k=max_k, parallel=parallel, time_limit=30.0, correct_reliable_only=false, n_obs_min=0, debug=0, verbose=true, FDR=true, weight_type="cond_stat")
# save(joinpath("data", "io_expected.jld"), "graph", graph)
