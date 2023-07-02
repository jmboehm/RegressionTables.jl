__precompile__(true)

module RegressionTables

    ##############################################################################
    ##
    #   TODO:
    #
    #   FUNCTIONALITY: (asterisk means priority)
    #   - write more serious tests
    #   - allow custom ordering of blocks (e.g. [:estimates, :fe, :estimator, :statistics])
    #   - HTML or CSV output
    #   - custom statistics
    #
    #   TECHNICAL:
    #   - Rewrite table cell/row formats using an encapsulating function instead
    #      of strings (which would allow HTML <td></td>)
    #   - Formatting option: string (or function) for spacer rows
    #
    ##
    ##############################################################################


    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #using DataFrames

    using StatsBase
    using StatsModels
    using Statistics
    using StatsAPI

    import Distributions: ccdf, FDist
    import Formatting: sprintf1, format
    import GLM: LinearModel
    import StatsModels: TableRegressionModel

    import StatsBase: coef, coeftable, confint, deviance, nulldeviance, dof, dof_residual,
                      loglikelihood, nullloglikelihood, nobs, stderr, vcov, residuals, predict,
                      fit, model_response, r2, r², adjr2, adjr², PValue
    
    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, LatexTable, AsciiTable, HTMLTable
    export make_estim_decorator
    export Nobs, R2, R2McFadden, R2CoxSnell, R2Nagelkerke,
    R2Deviance, AdjR2, AdjR2McFadden, AdjR2Deviance, DOF, LogLikelihood, AIC, BIC, AICC,
    FStat, FStatPValue, FStatIV, FStatIVPvalue, R2Within
    export TStat, STDError


    ##############################################################################
    ##
    ## Load files
    ##
    ##############################################################################

    # main types
    include("datarow.jl")
    include("RegressionStatistics.jl")
    include("coefnames.jl")
    include("regressiontable.jl")
    include("simpleRegressionResult.jl")
    include("rendersettings/default.jl")
    include("rendersettings/ascii.jl")
    include("rendersettings/latex.jl")
    include("rendersettings/html.jl")


    # main settings
    include("decorations/default_decorations.jl")

    include("label_transforms/default_transforms.jl")

    # main functions
    
    include("regtable.jl")

end
