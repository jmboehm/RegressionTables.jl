label_fe_yes(::Type{AbstractRenderType}) = "Yes"
label_fe_no(::Type{AbstractRenderType}) = ""


label_estimator(tab::AbstractRenderType) = "Estimator"
label_estimator(tab::AbstractRenderType, x::Val{:OLS})  = "OLS"
label_estimator(tab::AbstractRenderType, x::Val{:IV})   = "IV"
label_estimator(tab::AbstractRenderType, x::Val{:NL})   = "NL"

label_p(tab::AbstractRenderType) = "p"

wrapper(tab::AbstractRenderType, s) = s