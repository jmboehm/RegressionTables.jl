```julia
using Optim, NLSolversBase
using ForwardDiff
using NamedArrays
using StatsAPI, StatsModels, RegressionTables, Statistics, LinearAlgebra, HypothesisTests


n = 40                              # Number of observations
nvar = 2                            # Number of variables
β = ones(nvar) * 3.0                # True coefficients
x = [ 1.0   0.156651				# X matrix of explanatory variables plus constant
 1.0  -1.34218
 1.0   0.238262
 1.0  -0.496572
 1.0   1.19352
 1.0   0.300229
 1.0   0.409127
 1.0  -0.88967
 1.0  -0.326052
 1.0  -1.74367
 1.0  -0.528113
 1.0   1.42612
 1.0  -1.08846
 1.0  -0.00972169
 1.0  -0.85543
 1.0   1.0301
 1.0   1.67595
 1.0  -0.152156
 1.0   0.26666
 1.0  -0.668618
 1.0  -0.36883
 1.0  -0.301392
 1.0   0.0667779
 1.0  -0.508801
 1.0  -0.352346
 1.0   0.288688
 1.0  -0.240577
 1.0  -0.997697
 1.0  -0.362264
 1.0   0.999308
 1.0  -1.28574
 1.0  -1.91253
 1.0   0.825156
 1.0  -0.136191
 1.0   1.79925
 1.0  -1.10438
 1.0   0.108481
 1.0   0.847916
 1.0   0.594971
 1.0   0.427909]

ε = [   0.5539830489065279             # Errors
        -0.7981494315544392
        0.12994853889935182
  0.23315434715658184
 -0.1959788033050691
 -0.644463980478783
 -0.04055657880388486
 -0.33313251280917094
 -0.315407370840677
  0.32273952815870866
  0.56790436131181
  0.4189982390480762
 -0.0399623088796998
 -0.2900421677961449
 -0.21938513655749814
 -0.2521429229103657
  0.0006247891825243118
 -0.694977951759846
 -0.24108791530910414
  0.1919989647431539
  0.15632862280544485
 -0.16928298502504732
  0.08912288359190582
  0.0037707641031662006
 -0.016111044809837466
  0.01852191562589722
 -0.762541135294584
 -0.7204431774719634
 -0.04394527523005201
 -0.11956323865320413
 -0.6713329013627437
 -0.2339928433338628
 -0.6200532213195297
 -0.6192380993792371
  0.08834918731846135
 -0.5099307915921438
  0.41527207925609494
 -0.7130133329859893
 -0.531213372742777
 -0.09029672309221337]

y = x * β + ε;                      # Generate Data



module ExampleModule
using StatsAPI, StatsModels, RegressionTables, Statistics
export CustomModel, MyStatistic

struct CustomModel <: RegressionModel
    coef::Vector{Float64}
    vcov::Matrix{Float64}
    dof_residual::Int
    #islinear::Bool
    nobs::Int
    #rss::Float64
    #tss::Float64
    coefnames::Vector{String}
    responsename::String
    LogLikelihood::Float64
    BIC::Float64
    BS::Float64
    #Tuple{Float64,Float64}
    #civec::Vector{Tuple{Union{Nothing,Float64},Union{Nothing,Float64}}}
    civec::Matrix{Float64}
    #formula::FormulaTerm
    #formula_schema::FormulaTerm
end

struct MyStatistic <: RegressionTables.AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end

end

using .ExampleModule

StatsAPI.coef(m::ExampleModule.CustomModel) = m.coef
RegressionTables._coefnames(m::ExampleModule.CustomModel) = RegressionTables.get_coefname(m.coefnames)
StatsAPI.coefnames(m::ExampleModule.CustomModel) = m.coefnames
StatsAPI.responsename(m::ExampleModule.CustomModel) = m.responsename
RegressionTables._responsename(m::ExampleModule.CustomModel) = RegressionTables.get_coefname(m.responsename)
StatsAPI.vcov(m::ExampleModule.CustomModel) = m.vcov
StatsAPI.nobs(m::ExampleModule.CustomModel) = m.nobs
#StatsAPI.rss(m::ExampleModule.CustomModel) = m.rss
StatsAPI.dof_residual(m::ExampleModule.CustomModel) = m.dof_residual
#StatsAPI.nulldeviance(m::ExampleModule.CustomModel) = m.tss
RegressionTables.RegressionType(m::ExampleModule.CustomModel) = RegressionTables.RegressionType("My type")
#StatsAPI.deviance(m::ExampleModule.CustomModel) = StatsAPI.rss(m)
#StatsAPI.mss(m::ExampleModule.CustomModel) = nulldeviance(m) - StatsAPI.rss(m)

#StatsAPI.r2(m::ExampleModule.CustomModel) = StatsAPI.r2(m, :devianceratio)
StatsAPI.loglikelihood(m::ExampleModule.CustomModel) = m.LogLikelihood;
#StatsModels.formula(m::ExampleModule.CustomModel) = m.formula

StatsAPI.bic(m::ExampleModule.CustomModel) = m.BIC
#RegressionTables.BIC(m::ExampleModule.CustomModel) = m.BIC


function Base.repr(render::AbstractRenderType, x::ConfInt; digits=RegressionTables.default_digits(render, x), args...)
    if RegressionTables.value(x) == (0, 0) # 0 == 0.000
        repr(render, "restricted")
    else
        RegressionTables.below_decoration(render, repr(render, RegressionTables.value(x)[1]; digits) * ", " * Base.repr(render::AbstractRenderType, RegressionTables.value(x)[2]; digits))
    end
end
#=
function RegressionTables.ConfInt(m::ExampleModule.CustomModel, k::Int; level=0.95, standardize=false, vargs...)
    RegressionTables.ConfInt(m.civec[k])
end
=#
# should work again
function StatsAPI.confint(m::ExampleModule.CustomModel; level::Real = 0.95)
    m.civec
end

ExampleModule.MyStatistic(m::ExampleModule.CustomModel) = ExampleModule.MyStatistic(nothing)
ExampleModule.MyStatistic(m::ExampleModule.CustomModel) = ExampleModule.MyStatistic(m.BS)
RegressionTables.label(render::AbstractRenderType, x::Type{ExampleModule.MyStatistic}) = "Normality"
RegressionTables.default_regression_statistics(m::ExampleModule.CustomModel) = [Nobs,ExampleModule.MyStatistic,LogLikelihood,BIC]

RegressionTables.default_symbol(render::AbstractRenderType) = ""


function StatsAPI.fit(::Type{ExampleModule.CustomModel},X,Y,s_v,restricted_parameters)
    
    function Log_Likelihood(X, Y, params::AbstractVector{T}, restricted_parameters) where T
    
        full_parameter_vector = vcat(params,restricted_parameters)
        n = size(X,1);
        σ = exp(full_parameter_vector["Sigma"])
        llike = -n/2*log(2π) - n/2* log(σ^2) - (sum((Y - X[:,1] * full_parameter_vector["Beta 1"] - X[:,2] * full_parameter_vector["Beta 2"]).^2) / (2σ^2))
        llike = -llike
    end
    
    func = TwiceDifferentiable(vars -> Log_Likelihood(x, y, vars, s_v_r),s_v; autodiff=:forward);
    
    opt = optimize(func, s_v)
    
    parameters = Optim.minimizer(opt)
    
    var_cov_matrix = inv(hessian!(func,parameters))

    padding = zeros(length(parameters),length(restricted_parameters));
    augmented_var_cov_matrix = [var_cov_matrix padding;
                                padding'     I(length(restricted_parameters))]

    n = size(x,1);

    names_param = names(vcat(parameters,restricted_parameters),1);

    

    ll = -opt.minimum

    left_end = parameters - 1.96 * sqrt.(diag(var_cov_matrix))
    right_end = parameters + 1.96 * sqrt.(diag(var_cov_matrix))

    #apply transformations where needed
    left_end["Sigma"] = exp(left_end["Sigma"]);
    right_end["Sigma"] = exp(right_end["Sigma"]);
    parameters["Sigma"] = exp(parameters["Sigma"]);
    
    #Diagnostics
    all_parameters = vcat(parameters,restricted_parameters)
    residuals = y - x * all_parameters[["Beta 1","Beta 2"]];
    BIC = -2 * ll + log(n) * length(parameters);
    BS = JarqueBeraTest(residuals; adjusted=true).JB;
    
    civec = vcat(hcat(left_end.array,right_end.array),[0 0]);

    #create fitted model and return that
    ExampleModule.CustomModel(all_parameters.array,augmented_var_cov_matrix.array,n-length(s_v),n,names_param,"Outcome",ll,BIC,BS,civec)
    
end


s_v = NamedArray(Array{Float64}(undef,2));
setnames!(s_v,["Beta 2","Sigma"],1)
s_v["Beta 2"] = 1;
s_v["Sigma"] = 0.05;

s_v_r = NamedArray(Array{Float64}(undef,1));
setnames!(s_v_r,["Beta 1"],1);
s_v_r["Beta 1"] = 3.


rr1 = StatsAPI.fit(ExampleModule.CustomModel,x,y,s_v,s_v_r)


RegressionTables.regtable(rr1,below_statistic = ConfInt)
```