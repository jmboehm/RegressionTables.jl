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

    using DataFrames

    import Distributions: ccdf, FDist
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1
    import DataFrames: DataFrameRegressionModel, ModelFrame , coef, coefnames, vcov, nobs, dof_residual, r2
    import GLM: LinearModel


    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, latexOutput, asciiOutput, htmlOutput, RenderSettings

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

    # main functions
    include("render.jl")
    include("regtable.jl")

end
