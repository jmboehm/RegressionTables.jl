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

    using Distributions
    using Formatting
    using StatsModels

    using StatsBase
    
    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, LatexTable, LatexTableStar, AsciiTable, HTMLTable
    export make_estim_decorator
    export Nobs, R2, R2McFadden, R2CoxSnell, R2Nagelkerke,
    R2Deviance, AdjR2, AdjR2McFadden, AdjR2Deviance, DOF, LogLikelihood, AIC, BIC, AICC,
    FStat, FStatPValue, FStatIV, FStatIVPvalue, R2Within
    export TStat, STDError, RegressionType


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
