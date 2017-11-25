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

    import Distributions: ccdf, FDist
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1


    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, latexOutput, asciiOutput, RenderSettings

    ##############################################################################
    ##
    ## Load files
    ##
    ##############################################################################

    # main types
    include("RenderSettings.jl")
    include("RegressionTable.jl")

    # misc
    include("util/util.jl")

    # main settings
    include("decorations/default_decorations.jl")
    include("rendersettings/ascii.jl")
    include("rendersettings/latex.jl")

    # main functions
    include("render.jl")
    include("regtable.jl")

end
