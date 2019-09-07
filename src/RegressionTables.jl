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

    using Compat

    import Distributions: ccdf, FDist
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1
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

    export regtable, latexOutput, asciiOutput, htmlOutput, RenderSettings, escape_ampersand

    ##############################################################################
    ##
    ## Load files
    ##
    ##############################################################################

    # main types
    include("rendersettings.jl")
    include("regressiontable.jl")

    # misc
    include("util/util.jl")

    # main settings
    include("decorations/default_decorations.jl")
    include("rendersettings/ascii.jl")
    include("rendersettings/latex.jl")
    include("rendersettings/html.jl")
    include("label_transforms/default_transforms.jl")

    # main functions
    include("render.jl")
    include("regtable.jl")

end
