
function update_widths!(tab)
    x = maximum(length.(to_string.(Ref(tab), body(tab))), dims=1)
    hdr = Header(tab)
    for (i, row) in enumerate(hdr.rows)
        for (j, value) in enumerate(row.values)
            s = encapsulateRegressand(tab, first(value), last(value)[1], last(value)[end])
            diff = length(s) - sum(x[last(value)]) # difference between current and new width
            if diff > 0
                # increase width
                to_add = Int(round(diff / length(last(value))))
                x[last(value)] .+= to_add
                if length(last(value)) * to_add != diff # did not quite add enough
                    x[last(value)[end]] += diff - to_add
                end
            end
        end
    end
    for i in eachindex(tab.colwidths, x)
        tab.colwidths[i] = x[i]
    end
    x
end

round_digits(tab::AbstractRenderType, x::AbstractRegressionStatistic) = round_digits(tab, value(x))
round_digits(tab::AbstractRenderType, x::AbstractUnderStatistic) = round_digits(tab, value(x))
round_digits(tab::AbstractRenderType, x::CoefValue) = round_digits(tab, value(x))
round_digits(tab::AbstractRenderType, x::Float64) = 3

to_string(tab::AbstractRenderType, x; args...) = "$x"
to_string(tab::AbstractRenderType, x::Int; args...) = format(x, commas=true)
to_string(tab::AbstractRenderType, x::Float64; digits=round_digits(tab, x)) = format(x, precision=digits)
to_string(tab::AbstractRenderType, x::Nothing; args...) = ""
to_string(tab::AbstractRenderType, x::Missing; args...) = ""
to_string(tab::AbstractRenderType, x::AbstractString; args...) = String(x)
to_string(tab::AbstractRenderType, x::Bool; args...) = x ? "Yes" : ""
to_string(tab::AbstractRenderType, x::AbstractRegressionStatistic; digits=round_digits(tab, x)) = to_string(tab, value(x); digits)
to_string(tab::AbstractRenderType, x::AbstractUnderStatistic; digits=round_digits(tab, x)) = "(" * to_string(tab, value(x); digits) * ")"
to_string(tab::AbstractRenderType, x::CoefValue; digits=round_digits(tab, x)) = estim_decorator(tab, to_string(tab, value(x); digits), x.pvalue)
to_string(tab::AbstractRenderType, x::RegressionType; args...) = to_string(tab, value(x))
to_string(tab::AbstractRenderType, x::Type{T}; args...) where {T <: AbstractRegressionStatistic} = label(tab, T)
to_string(tab::AbstractRenderType, x::Type{RegressionType}; args...) = label(tab, x)
to_string(tab::AbstractRenderType, x::Tuple) = join(to_string.(Ref(tab), x), " ")

function make_padding(tab, value, colWidth, align)
    s = to_string(tab, value)
    if align == 'l'
        s = rpad(s, colWidth)
    elseif align == 'r'
        s = lpad(s, colWidth)
    elseif align == 'c'
        diff = colWidth - length(s)
        l = iseven(diff) ? Int64((diff)/2) : Int64((diff+1)/2)
        r = iseven(diff) ? Int64((diff)/2) : Int64((diff-1)/2)
        # if the printstring is too long, so be it
        l = max(l,0)
        r = max(r,0)
        s = (" " ^ l) * s * (" " ^ r)
    end
    s
end

function print_cell(io::IO, tab, value, colWidth, align, print_colsep=true; hdr=false)
    s = make_padding(tab, value, colWidth, align)
    print(io, s)
    if print_colsep
        if hdr
            print(io, headercolsep(tab))
        else
            print(io, colsep(tab))
        end
    end
end


# render a whole table
function Base.print(io::IO, tab::AbstractRenderType)
    update_widths!(tab)

    hdr = Header(tab)
    
    println(io, tablestart(tab))
    println(io, toprule(tab))
    print(io, hdr)

    # bodies
    for row = 1:size(body(tab),1)
        print(io, linestart(tab))
        for col in 1:size(body(tab),2)
            print_cell(io, tab, body(tab)[row,col], colwidths(tab)[col], align(tab)[col], col < size(body(tab),2))
        end
        println(io, linebreak(tab))
        # if we're not at the last block, print the midrule
        if row ∈ tab.breaks && row != last(tab.breaks)
            println(io, midrule(tab))
        end
    end
    println(io, bottomrule(tab))
    # print bottomrule
    println(io, tableend(tab))
end
Base.show(io::IO, tab::AbstractRenderType) = print(io, tab)