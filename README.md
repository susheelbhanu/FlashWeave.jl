# FlashWeave #

[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![Build Status](https://travis-ci.org/meringlab/FlashWeave.jl.svg?branch=master)](https://travis-ci.org/meringlab/FlashWeave.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/vdesge86ssj91htc?svg=true)](https://ci.appveyor.com/project/jtackm/flashweave-jl)
[![Coverage Status](https://coveralls.io/repos/github/meringlab/FlashWeave.jl/badge.svg?branch=master)](https://coveralls.io/github/meringlab/FlashWeave.jl?branch=master)

FlashWeave predicts ecological interactions between microbes from large-scale compositional abundance data (i.e. OTU tables constructed from sequencing data) through statistical co-occurrence. It reports direct associations, corrected for bystander effects and other confounders, and can furthermore integrate environmental or technical factors into the analysis of microbial systems.

## Installation ##

To install Julia, please follow instructions on https://github.com/JuliaLang/julia. The prefered way is to obtain a binary from https://julialang.org/downloads/. Make sure you install Julia 0.6.x, the versions currently supported by FlashWeave.

In an interactive Julia session, you can then install FlashWeave via

```julia
# if it's a fresh julia installation first run Pkg.init()
Pkg.clone("https://github.com/meringlab/FlashWeave.jl")
# to run tests: Pkg.test("FlashWeave")
```

## Basic usage ##

OTU tables can be provided in several formats: delimited formats (".csv", ".tsv"), [BIOM 1.0](http://biom-format.org/documentation/format_versions/biom-1.0.html) (".biom") or the high-performance formats [BIOM 2.0](http://biom-format.org/documentation/format_versions/biom-2.0.html) and [JLD](https://github.com/JuliaIO/JLD.jl)/[JLD2](https://github.com/simonster/JLD2.jl) (".jld", ".jld2"). Meta data should be provided as delimited format (except for JLD/2, see below). See the ```test/data/HMP_SRA_gut``` directory for examples. IMPORTANT NOTE: For delimited and JLD/2 formats, FlashWeave treats rows of the table as observations (i.e. samples) and columns as variables (i.e. OTUs or meta variables), consistent with the majority of statistical and machine-learning applications, but in contrast to several other microbiome analysis frameworks. Behavior can be switched with the ```transposed=true``` flag.

To learn an interaction network, you can do

```julia
julia> using FlashWeave # this has some pre-compilation delay the first time it's called, subsequent imports are fast

julia> data_path = "/my/example/data.tsv" # or .csv, .biom
julia> meta_data_path = "/my/example/meta_data.tsv"
julia> netw_results = learn_network(data_path, meta_data_path, sensitive=true, heterogeneous=false)

<< summary statistics of the learned network >>

julia> G = graph(netw_results) # weighted graph representing interactions + weights

julia> # for JLD2, you can provide keys:
julia> # data_path = "/my/example/data.jld2"
julia> # netw_results = learn_network(data_path, otu_data_key="otu_data", otu_header_key="otu_header", meta_data_key="meta_data", meta_header_key="meta_header", sensitive=true, heterogeneous=false)
```

Results can currently be saved in JLD/2, fast for large networks, or as traditional [Graph Modelling Language](https://en.wikipedia.org/wiki/Graph_Modelling_Language) (".gml") or edgelist (".edgelist") formats:

```julia
julia> save_network("/my/example/network_output.jld2", netw_results)
julia> ## or: save_network("/my/example/network_output.gml", netw_results)
```

For output of additional information (such as discarding sets, if available) in separate files you can specify the "detailed" flag:

```julia
julia> save_network("/my/example/network_output.jld2", netw_results, detailed=true)
```

A convenient loading function is available:
 ```julia
 julia> netw_results = load_network("/my/example/network_output.jld2")
 ```

To get more information on a function, use `?`:

```julia
julia> ?learn_network
```

## Performance tips ##

Depending on your data, make sure to chose the appropriate flags (```heterogeneous=true``` for multi-habitat or -protocol data sets with ideally at least thousands of samples; ```sensitive=false``` for faster, but more coarse-grained associations) to achieve optimal runtime. If FlashWeave should get stuck on a small fraction of nodes with large neighborhoods, try increasing the convergence criterion (```conv```). To learn a network in parallel, see the section below.

Note, that this package is optimized for large-scale data sets. On small data (hundreds of samples and OTUs) its speed advantages can be negated by JIT-compilation overhead.

## Parallel computing ##

FlashWeave leverages Julia's built-in [parallel infrastructure](https://docs.julialang.org/en/stable/manual/parallel-computing/). In the most simple case, you can start julia with several workers

```bash
$ julia -p 4 # for 4 workers
```

or manually add workers at the beginning of an interactive session

```julia
julia> addprocs(4)
julia> using FlashWeave
julia> learn_network(...
```

and network learning will be parallelized in a shared-memory, multi-process fashion.

If you want to run FlashWeave remotely on a computing cluster, a ```ClusterManager``` can be used (for example from the [ClusterManagers.jl](https://github.com/JuliaParallel/ClusterManagers.jl) package, installable via ```Pkg.add("ClusterManagers")```). Details differ depending on the setup (queueing system, resource requirements etc.), but a simple example for a Sun Grid Engine (SGE) system would be:

```julia
julia> using ClusterManagers
julia> addprocs_qrsh(20) # 20 remote workers
julia> ## for more fine-grained control: addprocs(QRSHManager(20, "<your queue>"), qsub_env="<your environment>", params=Dict(:res_list=>"<requested resources>"))

julia> # or

julia> addprocs_sge(20)
julia> ## addprocs_sge(5, queue="<your queue>", qsub_env="<your environment>", res_list="<requested resources>")
```

Please refer to the [ClusterManagers.jl documentation](https://github.com/JuliaParallel/ClusterManagers.jl) for further details.

## Versioning and API ##

FlashWeave follows [semantic versioning](https://semver.org/). Stability guarantees are only provided for exported functions (official API), anything else should be considered untested and subject to change.
