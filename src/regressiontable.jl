mutable struct RegressionTable
    headerString::String
    header::Array{String, 2}
    bodies::Vector{Array{String, 2}}
    footerString::String

    function RegressionTable(columns::Int64, headerString::String, header::Array{String, 2}, bodies::Vector{Array{String, 2}}, footerString::String)
        this = new()
        if any([size(body,2) for body in bodies] .!= columns)
            error("Incorrect number of columns in table")
        end
        if size(header, 2) != columns
            error("Header has wrong number of columns")
        end
        if (size(bodies,1) == 0 ) || (size(bodies[1],1)==0)
            error("Table must contain at least one body, and at least one row in the first body.")
        end
        this.headerString = headerString
        this.header = header
        this.bodies = bodies
        this.footerString = footerString
        return this
    end

end

# some helper functions
columns(tab::RegressionTable) = size(tab.bodies[1],2)
