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

    using StatsBase: RegressionModel
    using StatsModels: StatsModels, TableRegressionModel, InteractionTerm, FunctionTerm, AbstractTerm, Term
    using Statistics

    using Compat

    import Distributions: ccdf, FDist
    import FixedEffectModels: FixedEffectModels, FixedEffectModel, has_fe, has_iv, eachterm, FixedEffectTerm, fe #AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1
    import GLM: LinearModel
    
    using StatsAPI: StatsAPI, coef, coefnames, dof_residual, nobs, vcov

    # define methods for `responsename` and `islinear` that are missing upstream
    responsename(r)                       = StatsAPI.responsename(r)
    responsename(r::RegressionModel)      = StatsModels.responsename(r) # returns a Symbol
    responsename(r::TableRegressionModel) = lhs(r.mf.f.lhs)
    
    lhs(t::FunctionTerm) = Symbol(t.exorig)
    lhs(t) = t.sym
    
    islinear(r)                       = StatsAPI.islinear(r)
    islinear(r::TableRegressionModel) = r.model isa LinearModel

    using StatsBase: loglikelihood, nullloglikelihood, PValue, model_response

    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export regtable, latexOutput, asciiOutput, htmlOutput, RenderSettings, escape_ampersand
    export make_estim_decorator

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
    include("header.jl")
    include("render.jl")
    include("regtable.jl")

end
