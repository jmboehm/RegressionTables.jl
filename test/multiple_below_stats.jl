#=
This tests multiple below statistics feature

Tests that multiple statistics can be displayed below each coefficient,
with customizable decorations and formatting for each statistic type.
=#

using RegressionTables
using FixedEffectModels, RDatasets, Test

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

# Test 7: Custom statisticformat with Vector
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    statisticformat = ["%0.4f", "%0.1f"])

@test occursin("0.478", tab[4, 2])      # StdError with 4 decimals
@test tab[5, 2] == "(13.6)"        # TStat with 1 decimal

##

# Test 8: LaTeX output with multiple statistics
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, ConfInt],
    below_decoration = Dict(StdError => s -> "($s)", ConfInt => s -> "[$s]"),
    regression_statistics = [Nobs, R2],
    render = LatexTable())

@test occursin("6.526", tab[3, 2])      # coefficient present
@test occursin("(0.479)", tab[4, 2])    # StdError with parentheses
@test occursin("[", tab[5, 2])          # ConfInt uses brackets

##

# Test 9: Invalid below_statistic symbols throw errors
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=:invalid)
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=[:se, :invalid])
@test_throws ErrorException("unrecognized below_statistic") regtable(rr1; below_statistic=[:invalid, :se])

##

# Test 9b: Valid symbols as scalars work correctly
# This tests the scalar symbol conversion path (:se -> StdError, :tstat -> TStat)
tab_se = regtable(rr1; below_statistic=:se)
@test length(tab_se.data) > 0  # Verify table was created successfully

tab_tstat = regtable(rr1; below_statistic=:tstat)
@test length(tab_tstat.data) > 0  # Verify table was created successfully

##

# Test 10: Valid symbol vectors work correctly
tab = regtable(rr1; below_statistic=[:se, :tstat])
# With [:se, :tstat], we should have coefficient, se, and tstat rows
@test length(tab.data) > 0  # Verify table was created successfully

##

# Test 11: Custom below_decoration with digits_stats
# This tests the code path where below_decoration is used WITH digits_stats
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = [s -> "($s)", s -> "{$s}"],
    digits_stats = 4)

@test occursin("(0.4789", tab[4, 2])    # StdError: custom decoration with digits_stats formatting
@test occursin("{13.6276", tab[5, 2])   # TStat: custom decoration with digits_stats formatting

##

# Test 12: Custom below_decoration with statisticformat
# This tests the code path where below_decoration is used WITH statisticformat
tab = regtable(rr1, rr2; 
    below_statistic = [StdError, TStat],
    below_decoration = [s -> "($s)", s -> "{$s}"],
    statisticformat = ["%0.2f", "%0.1f"])

@test occursin("(0.48", tab[4, 2])     # StdError: custom decoration with statisticformat
@test occursin("{13.6", tab[5, 2])     # TStat: custom decoration with statisticformat
