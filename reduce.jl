# To install ReduceModel:
# julia> pkg"add https://github.com/iasonask/ReduceModel.jl.git"

using ReduceModel
using Ipopt


call_rei(ARGS[1], 2; optimizer=Ipopt.Optimizer, export_file=true, path=pwd())