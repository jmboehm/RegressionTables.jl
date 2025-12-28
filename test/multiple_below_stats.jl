#=
This tests multiple below statistics feature

Tests that multiple statistics can be displayed below each coefficient,
with customizable decorations and formatting for each statistic type.
=#

using RegressionTables
using FixedEffectModels, RDatasets, Test
using Format

df = RDatasets.dataset("datasets", "iris")

rr1 = reg(df, @formula(SepalLength ~ SepalWidth))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength))
##

# Test 1: Two statistics (StdError and TStat)
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat], 
    regression_statistics = [Nobs, R2])

@test tab[3, 2] == "6.526***"      # rr1 intercept coefficient
@test tab[4, 2] == "(0.479)"       # rr1 intercept StdError
@test tab[5, 2] == "(13.628)"      # rr1 intercept TStat
@test tab[7, 3] == "(0.069)"       # rr2 SepalWidth StdError
@test tab[8, 3] == "(8.590)"       # rr2 SepalWidth TStat
@test tab[12, 1] == "N"            # regression statistics

##

# Test 2: StdError and ConfInt
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt], 
    regression_statistics = [Nobs, R2])

@test tab[3, 2] == "6.526***"      # rr1 intercept coefficient
@test tab[4, 2] == "(0.479)"       # rr1 intercept StdError
@test occursin("5.5", tab[5, 2]) && occursin("7.4", tab[5, 2])  # rr1 intercept ConfInt
@test tab[10, 3] == "(0.017)"      # rr2 PetalLength StdError
@test occursin("0.4", tab[11, 3]) && occursin("0.5", tab[11, 3])  # rr2 PetalLength ConfInt

##

# Test 3: Custom decorations with Dict
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    below_decoration = Dict(StdError => s -> "($s)", ConfInt => s -> "[$s]"),
    regression_statistics = [Nobs, R2])

@test tab[4, 2] == "(0.479)"       # StdError uses parentheses
@test startswith(tab[5, 2], "[")   # ConfInt uses brackets

##

# Test 4: Custom decorations with Vector
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = [s -> "($s)", s -> "{$s}"])

@test tab[4, 2] == "(0.479)"       # First statistic (StdError) uses parentheses
@test tab[5, 2] == "{13.628}"      # Second statistic (TStat) uses braces

##

# Test 5: Custom decorations with Function
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = s -> "<$s>")  # Applied to all statistics

@test tab[4, 2] == "<0.479>"       # StdError uses custom decoration
@test tab[5, 2] == "<13.628>"      # TStat uses same decoration

##

# Test 6: Custom statisticformat with Dict
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    statisticformat = Dict(StdError => "%0.4f", ConfInt => "%0.2f"))

@test occursin("0.478", tab[4, 2])      # StdError with 4 decimals
@test occursin("5.5", tab[5, 2]) || occursin("7.4", tab[5, 2])  # ConfInt with 2 decimals

##

# Test 7: LaTeX output with multiple statistics
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    below_decoration = Dict(StdError => s -> "($s)", ConfInt => s -> "[$s]"),
    regression_statistics = [Nobs, R2],
    render = LatexTable())

@test occursin("6.526", tab[3, 2])      # coefficient present
@test occursin("(0.479)", tab[4, 2])    # StdError with parentheses
@test occursin("[", tab[5, 2])          # ConfInt uses brackets

##

# Test 8: Invalid below_statistic symbols throw errors
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=:invalid)
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=[:se, :invalid])
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=[:invalid, :se])

##

# Test 8b: Valid symbols as scalars work correctly
# This tests the scalar symbol conversion path (:se -> StdError, :tstat -> TStat)
tab_se = regtable(rr1; below_statistic=:se)
@test length(tab_se.data) > 0  # Verify table was created successfully

tab_tstat = regtable(rr1; below_statistic=:tstat)
@test length(tab_tstat.data) > 0  # Verify table was created successfully

##

# Test 9: Valid symbol vectors work correctly
tab = regtable(rr1; below_statistic=[:se, :tstat])
# With [:se, :tstat], we should have coefficient, se, and tstat rows
@test length(tab.data) > 0  # Verify table was created successfully

##

# Test 10: Custom below_decoration with digits_stats
# This tests the code path where below_decoration is used WITH digits_stats
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = [s -> "($s)", s -> "{$s}"],
    digits_stats = 4)

@test occursin("(0.4789", tab[4, 2])    # StdError: custom decoration with digits_stats formatting
@test occursin("{13.6276", tab[5, 2])   # TStat: custom decoration with digits_stats formatting

##

# Test 11: Dict-based statisticformat for BOTH below and regression statistics
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    statisticformat = Dict(
        StdError => "%0.4f",
        ConfInt => "%0.1f",
        R2 => "%0.5f"
    ),
    regression_statistics = [Nobs, R2])

# Check below statistics formatting
@test occursin("(0.4789", tab[4, 2])    # StdError uses 4 decimals
@test occursin("5.6", tab[5, 2]) || occursin("7.5", tab[5, 2])  # ConfInt uses 1 decimal

# Check regression statistics formatting - find R2 row
r2_row_idx = findfirst(row -> row[1] == "R2" || occursin("R2", string(row[1])), tab.data)
@test r2_row_idx !== nothing
@test occursin("0.01382", tab[r2_row_idx, 2])  # R2 uses 5 decimals

##

# Test 12: Dict-based below_decoration with Dict-based statisticformat
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = Dict(
        StdError => s -> "{"*s*"}",
        TStat => s -> "["*s*"]"
    ),
    statisticformat = Dict(
        StdError => "%0.4f",
        TStat => "%0.1f"
    ))

@test occursin("{0.4789", tab[4, 2])    # StdError: braces with 4 decimals
@test occursin("[13.6", tab[5, 2])      # TStat: brackets with 1 decimal

# Test 13: Integer values in statisticformat for below statistics
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    statisticformat = Dict(
        StdError => 4,
        TStat => 1
    ))

@test occursin("(0.4789", tab[4, 2])    # StdError uses 4 decimals
@test occursin("(13.6", tab[5, 2])      # TStat uses 1 decimal

# Test 14: Integer values in statisticformat for regression statistics
tab = regtable(rr1, rr2; 
    regression_statistics = [Nobs, R2],
    statisticformat = Dict(
        R2 => 5,
        Nobs => 0
    ))

r2_row_idx = findfirst(row -> row[1] == "R2" || occursin("R2", string(row[1])), tab.data)
nobs_row_idx = findfirst(row -> row[1] == "N" || occursin("Nobs", string(row[1])), tab.data)
@test r2_row_idx !== nothing
@test nobs_row_idx !== nothing
@test occursin("0.01382", tab[r2_row_idx, 2])  # R2 uses 5 decimals
@test occursin("150", tab[nobs_row_idx, 2])     # Nobs uses 0 decimals (integer)

# Test 15: Mixed String and Integer values in statisticformat
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    statisticformat = Dict(
        StdError => 4,
        ConfInt => "%0.2f",
        R2 => 5
    ),
    regression_statistics = [Nobs, R2])

@test occursin("(0.4789", tab[4, 2])    # StdError uses 4 decimals (Integer)
@test occursin("5.5", tab[5, 2]) || occursin("7.4", tab[5, 2])  # ConfInt uses 2 decimals (String)
r2_row_idx = findfirst(row -> row[1] == "R2" || occursin("R2", string(row[1])), tab.data)
@test r2_row_idx !== nothing
@test occursin("0.01382", tab[r2_row_idx, 2])  # R2 uses 5 decimals (Integer)

##

# Test 16: Function values in statisticformat for below statistics
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    statisticformat = Dict(
        StdError => x -> "SE:" * string(round(x, digits=3)),
        TStat => x -> "T:" * string(round(x, digits=2))
    ))

@test occursin("SE:", tab[4, 2])        # StdError uses custom function
@test occursin("T:", tab[5, 2])         # TStat uses custom function

##

# Test 17: Function values in statisticformat for regression statistics
tab = regtable(rr1, rr2; 
    regression_statistics = [Nobs, R2],
    statisticformat = Dict(
        R2 => x -> "R²=" * string(round(x, digits=3)),
        Nobs => x -> "n=" * string(Int(x))
    ))

r2_row_idx = findfirst(row -> row[1] == "R2" || occursin("R2", string(row[1])), tab.data)
nobs_row_idx = findfirst(row -> row[1] == "N" || occursin("Nobs", string(row[1])), tab.data)
@test r2_row_idx !== nothing
@test nobs_row_idx !== nothing
@test occursin("R²=", tab[r2_row_idx, 2])      # R2 uses custom function
@test occursin("n=", tab[nobs_row_idx, 2])     # Nobs uses custom function

##

# Test 18: Mixed Function, Integer, and String values in statisticformat
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat, ConfInt],
    statisticformat = Dict(
        StdError => 4,
        TStat => x -> "[" * string(round(x, digits=3)) * "]",
        ConfInt => "%0.2f"
    ),
    regression_statistics = [Nobs, R2])

@test occursin("(0.4789", tab[4, 2])    # StdError uses 4 decimals (Integer)
@test occursin("[", tab[5, 2])          # TStat uses custom function
@test occursin("5.5", tab[6, 2]) || occursin("7.4", tab[6, 2])  # ConfInt uses 2 decimals (String)

##

# Test 19: Function using format() with raw numeric values
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = Dict(TStat => s -> "["*s*"]"),
    statisticformat = Dict(
        TStat => x -> format(x, commas=true, precision=3)
    ))

@test occursin("(0.479)", tab[4, 2])    # StdError uses default formatting
@test occursin("[13.628]", tab[5, 2])   # TStat uses format() with 3 decimals and brackets
