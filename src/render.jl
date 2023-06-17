
function calc_widths(rows::Vector{DataRow}, rndr)
    out_lengths = fill(0, length(rows[1]))
    for row in rows
        for (i, value) in enumerate(row.data)
            s = full_string(value, rndr)
            if length(s) == 0
                continue
            end
            if isa(value, Pair)
                diff = length(s) - sum(out_lengths[last(value)]) - length(colsep(rndr)) * length(last(value))
                if diff > 0
                    # increase width
                    to_add = Int(round(diff / length(last(value))))
                    out_lengths[last(value)] .+= to_add
                    if length(last(value)) * to_add < diff # did not quite add enough
                        out_lengths[last(value)[end]] += diff - length(last(value)) * to_add
                    end
                end
            else
                out_lengths[i] = max(out_lengths[i], length(s))
            end
        end
    end
    out_lengths
end

function update_widths!(row::DataRow, new_lengths, rndr)
    @assert length(row) == length(new_lengths) "Wrong number of lengths"
    for (i, value) in enumerate(row.data)
        if isa(value, Pair)
            row.colwidths[i] = sum(new_lengths[last(value)]) + length(colsep(rndr)) * (length(last(value))-1)
        else
            row.colwidths[i] = new_lengths[i]
        end
    end
end

round_digits(rndr::AbstractRenderType, x::AbstractRegressionStatistic) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x::AbstractUnderStatistic) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x::CoefValue) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x) = 3

to_string(rndr::AbstractRenderType, x; args...) = "$x"
to_string(rndr::AbstractRenderType, x::Int; args...) = format(x, commas=true)
to_string(rndr::AbstractRenderType, x::Float64; digits=round_digits(rndr, x)) = format(x, precision=digits)
to_string(rndr::AbstractRenderType, x::Nothing; args...) = ""
to_string(rndr::AbstractRenderType, x::Missing; args...) = ""
to_string(rndr::AbstractRenderType, x::AbstractString; args...) = String(x)
to_string(rndr::AbstractRenderType, x::Bool; args...) = x ? "Yes" : ""
to_string(rndr::AbstractRenderType, x::AbstractRegressionStatistic; digits=round_digits(rndr, x)) = to_string(rndr, value(x); digits)
to_string(rndr::AbstractRenderType, x::AbstractUnderStatistic; digits=round_digits(rndr, x)) = "(" * to_string(rndr, value(x); digits) * ")"
to_string(rndr::AbstractRenderType, x::CoefValue; digits=round_digits(rndr, x)) = estim_decorator(rndr, to_string(rndr, value(x); digits), x.pvalue)
to_string(rndr::AbstractRenderType, x::RegressionType; args...) = to_string(rndr, value(x))
to_string(rndr::AbstractRenderType, x::Type{T}; args...) where {T <: AbstractRegressionStatistic} = label(rndr, T)
to_string(rndr::AbstractRenderType, x::Type{RegressionType}; args...) = label(rndr, x)
to_string(rndr::AbstractRenderType, x::Tuple) = join(to_string.(Ref(rndr), x), " ")

function make_padding(s, colWidth, align)
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


