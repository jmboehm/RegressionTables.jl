module RegressionTables

    ##############################################################################
    ##
    #   TODO:
    #
    #   FUNCTIONALITY: (asterisk means priority)
    #   - write more serious tests
    #
    #   TECHNICAL:
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
    using Format
    
    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, LatexTable, LatexTableStar, AsciiTable, HtmlTable, AbstractRenderType,
    AbstractAscii, AbstractLatex, AbstractHtml
    export Nobs, R2, R2McFadden, R2CoxSnell, R2Nagelkerke,
    R2Deviance, AdjR2, AdjR2McFadden, AdjR2Deviance, DOF, LogLikelihood, AIC, BIC, AICC,
    FStat, FStatPValue, FStatIV, FStatIVPValue, R2Within, PseudoR2, AdjPseudoR2
    export TStat, StdError, ConfInt, RegressionType
    export DataRow, RegressionTable

    export make_estim_decorator

    export latexOutput, asciiOutput, htmlOutput


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
    include("regressionResults.jl")
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
