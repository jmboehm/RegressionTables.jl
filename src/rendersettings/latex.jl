function latexOutput(outfile::String = "")
    latexRegressandTransform(s::String,colmin::Int64,colmax::Int64) = "\\multicolumn{$(colmax-colmin+1)}{c}{$s}"
    latexTableHeader(numberOfResults::Int64, align::String) = "\\begin{tabular}{$align}"
    latexTableFooter(numberOfResults::Int64, align::String) = "\\end{tabular}"
    function latexHeaderRule(headerCellStartEnd::Vector{Vector{Int64}})
        if length(headerCellStartEnd)<2
            error("Invalid headerCellStartEnd: need to have at least two columns.")
        end
        s = ""
        for i in headerCellStartEnd[2:end]
            s = s * "\\cmidrule(lr){$(i[1])-$(i[2])}" * " "
        end
        return s
    end
    toprule = "\\toprule"
    midrule = "\\midrule"
    bottomrule = "\\bottomrule"
    headerrule = latexHeaderRule
    headercolsep = " & "
    colsep = " & "
    linestart = ""
    linebreak = " \\\\ "

    label_fe_yes = "Yes"
    label_fe_no = ""

    label_statistic_n = "\$N\$"
    label_statistic_r2 = "\$R^2\$"
    label_statistic_f = "\$F\$"
    label_statistic_adjr2 = "Adjusted \$R^2\$"
    label_statistic_r2_within = "Within-\$R^2\$"
    label_statistic_p = "\$F\$-test \$p\$ value"
    label_statistic_f_kp = "First-stage \$F\$ statistic"
    label_statistic_p_kp = "First-stage \$p\$ value"
    label_statistic_dof = "Degrees of Freedom"

    label_estimator = "Estimator"
    label_estimator_ols = "OLS"
    label_estimator_iv = "IV"
    label_estimator_nl = "NL"


    foutfile = outfile
    encapsulateRegressand = latexRegressandTransform
    header = latexTableHeader
    footer = latexTableFooter
    return RenderSettings(toprule, midrule, bottomrule, headerrule, headercolsep, colsep, linestart, 
        linebreak, label_fe_yes, label_fe_no,
        label_statistic_n, label_statistic_r2, label_statistic_adjr2, label_statistic_r2_within,
        label_statistic_f, label_statistic_p, label_statistic_f_kp, label_statistic_p_kp, label_statistic_dof,
        label_estimator, label_estimator_ols, label_estimator_iv, label_estimator_nl,
        foutfile, encapsulateRegressand, header, footer)
end
