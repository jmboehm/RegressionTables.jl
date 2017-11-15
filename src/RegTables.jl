__precompile__(true)

module RegTables

    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #import DataFrames: DataFrame, AbstractDataFrame, ModelMatrix, ModelFrame, Terms, coefnames, Formula, completecases, names!, pool, @formula
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV

    # order = ["varname_1", "varname_2", ...]

    function regtable(rr::AbstractRegressionResult...; lhslabel::String = "")

        println("Showing regtable... \n")

        for r in rr
            @show r.coef
            @show r.vcov
        end

        #@show rr

    end


end
