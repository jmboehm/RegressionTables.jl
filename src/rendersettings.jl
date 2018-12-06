
struct RenderSettings

    # horizontal lines. if character, repeat.
    toprule::String
    midrule::String
    bottomrule::String

    headerrule::Function  # Function that takes the headerCellStartEnd array and returns a
                            # sting that describes the text line below the header titles
                            # if it's one single character, it's put into a table format and repeated (e.g. "-" for ascii)

    headercolsep::String # separator between columns for header
    colsep::String  # separator between columns
    linestart::String # start of each line string
    linebreak::String   # link break string

    label_fe_yes::String    # what the FE block prints if the FE is present. override with __LABEL_FE_YES__ in 'label' argument
    label_fe_no::String    # what the FE block prints if the FE is not present. override with __LABEL_FE_NO__ in 'label' argument

    label_statistic_n::String # label for number of observations. override with __LABEL_STATISTIC_N__ in 'label' argument
    label_statistic_r2::String # label for R^2. override with __LABEL_STATISTIC_R2__ in 'label' argument
    label_statistic_adjr2::String # label for adjusted R^2. override with __LABEL_STATISTIC_adjr2__
    label_statistic_r2_within::String # label for within-R^2. override with __LABEL_STATISTIC_R2_WITHIN__
    label_statistic_f::String # label for F-Stat. override with __LABEL_STATISTIC_F__ in 'label' argument
    label_statistic_p::String # label for F-test p value. override with __LABEL_STATISTIC_P__
    label_statistic_f_kp::String # label for first-stage F statistic. override with __LABEL_STATISTIC_F_KP__
    label_statistic_p_kp::String # label for first-stage F-stat p value. override with __LABEL_STATISTIC_P_KP__
    label_statistic_dof::String # label for degrees of freedom. override with __LABEL_STATISTIC_DOF__

    label_estimator::String # label for the Estimator block. Override with __LABEL_ESTIMATOR__
    label_estimator_ols::String # label for the Estimator block. Override with __LABEL_ESTIMATOR_OLS__
    label_estimator_iv::String # label for the Estimator block. Override with __LABEL_ESTIMATOR_IV__
    label_estimator_nl::String # label for the Estimator block. Override with __LABEL_ESTIMATOR_NL__

    outfile::String    # file to print output into.
                       # if empty, print to STDOUT.

    encapsulateRegressand::Function     # function that takes a string and
                                        # min and max column index and returns
                                        # a formatted string

    header::Function                    # function that return the header string
    footer::Function                    # function that returns the footer string
                                        # both should take the number of results and align string as arguments

end
