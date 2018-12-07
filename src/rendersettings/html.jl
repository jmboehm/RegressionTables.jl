function htmlOutput(outfile::String = "")
    htmlRegressandTransform(s::String,colmin::Int64,colmax::Int64) = "<td colspan=\"$(colmax-colmin+1)\" style=\"padding:0.2cm; text-align:center; border-bottom:1px solid;\">$s</td>"
    htmlTableHeader(numberOfResults::Int64, align::String) = "<table style=\"border-collapse:collapse; border:none;border-top:double;border-bottom:double;\">\n<tbody>"
    htmlTableFooter(numberOfResults::Int64, align::String) = "</tbody></table>"
    function htmlHeaderRule(headerCellStartEnd::Vector{Vector{Int64}})
        # if length(headerCellStartEnd)<2
        #     error("Invalid headerCellStartEnd: need to have at least two columns.")
        # end
        # s = ""
        # for i in headerCellStartEnd[2:end]
        #     s = s * "\\cmidrule(lr){$(i[1])-$(i[2])}" * " "
        # end
        # return s
        return ""
    end
    
    # toprule: just a spacer <tr>
    toprule = "<tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
    # midrule: a <tr> with black border on bottom, and a <tr> spacer
    midrule = "<tr style=\"border-bottom:1px solid black\"><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr><tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
    # bottomrule: a slightly larger spacer
    bottomrule = "<tr><td style=\"padding:0.15cm\" colspan=\"100%\"></td></tr>"
    headerrule = htmlHeaderRule
    headercolsep = " "
    colsep = " </td><td style=\"padding:0.2em; padding-left:0.8em; padding-right:0.8em;\"> "
    linestart = "<tr><td>"
    linebreak = " </td></tr>"

    label_fe_yes = "Yes"
    label_fe_no = ""

    label_statistic_n = "<i>N</i>"
    label_statistic_r2 = "<i>R<sup>2</sup></i>"
    label_statistic_f = "<i>F</i>"
    label_statistic_adjr2 = "Adjusted <i>R<sup>2</sup></i>"
    label_statistic_r2_within = "Within-<i>R<sup>2</sup></i>"
    label_statistic_p = "<i>F</i>-test <i>p</i> value"
    label_statistic_f_kp = "First-stage <i>F</i> statistic"
    label_statistic_p_kp = "First-stage <i>p</i> value"
    label_statistic_dof = "Degrees of Freedom"

    label_estimator = "Estimator"
    label_estimator_ols = "OLS"
    label_estimator_iv = "IV"
    label_estimator_nl = "NL"

    foutfile = outfile
    encapsulateRegressand = htmlRegressandTransform
    header = htmlTableHeader
    footer = htmlTableFooter
    return RenderSettings(toprule, midrule, bottomrule, headerrule, headercolsep, colsep, linestart, 
        linebreak, label_fe_yes, label_fe_no,
        label_statistic_n, label_statistic_r2, label_statistic_adjr2, label_statistic_r2_within,
        label_statistic_f, label_statistic_p, label_statistic_f_kp, label_statistic_p_kp, label_statistic_dof,
        label_estimator, label_estimator_ols, label_estimator_iv, label_estimator_nl,
        foutfile, encapsulateRegressand, header, footer)
end
