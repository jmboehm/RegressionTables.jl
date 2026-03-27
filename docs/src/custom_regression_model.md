# Implementing Custom Regression Models

RegressionTables.jl is designed to be used with any custom model you create. The easiest way for this to work is to copy the [StatsAPI.jl](https://github.com/JuliaStats/StatsAPI.jl) API, if that API is fully implemented then RegressionTables.jl will work out of the box.

This guide demonstrates how to create custom regression models that work seamlessly with RegressionTables.jl. When you have a regression model type that isn't natively supported, you can extend the package by implementing the required interface methods.

## Overview

To make a custom model work with RegressionTables.jl, you need to implement several key components:

1. **Model Type Definition**: Create a struct that subtypes `RegressionModel`
2. **StatsAPI Interface**: Implement required methods for coefficient extraction and model statistics
3. **RegressionTables Integration**: Add specific methods for table generation and formatting
4. **Optional Enhancements**: Custom statistics, confidence intervals, and display options

## Required Interface Methods

The core functions you need to implement are:

```julia
# Essential StatsAPI methods (minimum required)
StatsAPI.coef(model::YourModelType)           # Coefficient estimates

# For coefficient names, implement ONE of:
StatsAPI.coefnames(model::YourModelType)      # Variable names
# OR
StatsModels.formula(model::YourModelType)     # Formula (if using formula interface)

# For response variable name, implement ONE of:
StatsAPI.responsename(model::YourModelType)   # Response variable name
# OR  
StatsModels.formula(model::YourModelType)     # Formula (if using formula interface)

# For standard errors, implement ONE of:
StatsAPI.stderror(model::YourModelType)       # Standard errors directly
# OR
StatsAPI.vcov(model::YourModelType)           # Variance-covariance matrix (default implementation in StatsAPI)

# For model type identification, implement ONE of:
StatsAPI.islinear(model::YourModelType)       # Returns true/false for linear models
# OR
RegressionTables.RegressionType(model::YourModelType) # Custom model type display
```

## Example 1: Basic Implementation with Formula Interface

This example shows a straightforward implementation suitable for most linear regression use cases, including full formula support:

### Step 1: Define the Model Structure

```julia
using StatsAPI, StatsModels, RegressionTables, RDatasets, Statistics

struct MyStatsModel <: RegressionModel
    coef::Vector{Float64}           # Coefficient estimates
    vcov::Matrix{Float64}           # Variance-covariance matrix
    dof::Int                        # Degrees of freedom (total parameters)
    dof_residual::Int              # Residual degrees of freedom
    nobs::Int                      # Number of observations
    rss::Float64                   # Residual sum of squares
    tss::Float64                   # Total sum of squares
    coefnames::Vector{String}      # Variable names
    responsename::String           # Dependent variable name
    formula::FormulaTerm          # Original formula
    formula_schema::FormulaTerm   # Processed formula with schema
end
```

**Key Points:**
- The struct must subtype `RegressionModel` to be recognized by RegressionTables
- Store all necessary information for computing statistics
- Include formula information if you want formula-based fitting

### Step 2: Implement the StatsAPI Interface

```julia
# Methods to match the StatsAPI interface
StatsAPI.coef(m::MyStatsModel) = m.coef

# Coefficient and response names (using stored values)
StatsAPI.coefnames(m::MyStatsModel) = m.coefnames
StatsAPI.responsename(m::MyStatsModel) = m.responsename

# Standard errors (via variance-covariance matrix)
StatsAPI.vcov(m::MyStatsModel) = m.vcov

# Model type identification
StatsAPI.islinear(m::MyStatsModel) = true

# Additional useful methods for regression statistics
StatsAPI.nobs(m::MyStatsModel) = m.nobs
StatsAPI.dof(m::MyStatsModel) = m.dof
StatsAPI.dof_residual(m::MyStatsModel) = m.dof_residual
StatsAPI.rss(m::MyStatsModel) = m.rss
StatsAPI.nulldeviance(m::MyStatsModel) = m.tss
StatsAPI.deviance(m::MyStatsModel) = StatsAPI.rss(m)
StatsAPI.mss(m::MyStatsModel) = nulldeviance(m) - StatsAPI.rss(m)
StatsAPI.r2(m::MyStatsModel) = StatsAPI.r2(m, :devianceratio)

# Formula support (enables formula-based fitting), formula takes
# precedence over `coefnames` and `reponsename`
StatsModels.formula(m::MyStatsModel) = m.formula_schema
```

**Key Points:**
- `coef()` is the absolute minimum requirement
- `coefnames()` and `responsename()` provide variable names for display
- `vcov()` enables automatic standard error calculation
- `islinear(true)` indicates this is a linear model
- R² calculation uses the deviance ratio method (standard for linear models)

### Step 3: Implement the Fitting Function

```julia
function StatsAPI.fit(::Type{MyStatsModel}, f::FormulaTerm, df::DataFrame)
    # Data preparation
    df = dropmissing(df)
    f_schema = apply_schema(f, schema(f, df))
    y, X = modelcols(f_schema, df)
    response_name, coefnames_exo = coefnames(f_schema)
    n, p = size(X)
    
    # Ordinary least squares estimation
    β = X \ y
    ŷ = X * β
    res = y - ŷ
    
    # Calculate statistics
    rss = sum(abs2, res)
    tss = sum(abs2, y .- mean(y))
    dof = p
    dof_residual = n - p
    vcov = inv(X'X) * rss / dof_residual
    
    # Create and return model
    MyStatsModel(β, vcov, dof, dof_residual, n, rss, tss, 
                 coefnames_exo, response_name, f, f_schema)
end
```

**Key Points:**
- Uses StatsModels.jl for formula processing and data preparation
- Implements standard OLS estimation
- Computes variance-covariance matrix for standard errors
- Returns a fully populated model struct

### Step 4: Usage and Output

```julia
# Example usage
df = dataset("plm", "Cigar")
rr1 = StatsAPI.fit(MyStatsModel, @formula(Sales ~ 1 + Price + NDI), df)
rr2 = StatsAPI.fit(MyStatsModel, @formula(Sales ~ 1 + Price), df)
rr3 = StatsAPI.fit(MyStatsModel, @formula(Sales ~ 1 + NDI), df)
regtable(rr1, rr2, rr3)
```

This produces:
```
--------------------------------------------------
                              Sales
              ------------------------------------
                     (1)          (2)          (3)
--------------------------------------------------
(Intercept)   138.480***   139.734***   132.981***
                 (1.427)      (1.521)      (1.538)
Price          -0.938***    -0.230***
                 (0.054)      (0.019)
NDI             0.007***                 -0.001***
                 (0.000)                   (0.000)
--------------------------------------------------
N                  1,380        1,380        1,380
R2                 0.209        0.097        0.034
--------------------------------------------------
```

## Example 2: Advanced Implementation with Custom Features

This example demonstrates a more sophisticated implementation with numerical optimization, custom statistics, confidence intervals, and specialized display options:

### Step 1: Define the Advanced Model Structure

```julia
using Optim, ForwardDiff, NamedArrays, HypothesisTests, RegressionTables, StatsAPI, NLSolversBase, LinearAlgebra

n = 40                              # Number of observations
nvar = 2                            # Number of variables
β = ones(nvar) * 3.0                # True coefficients
x = [ 1.0   0.156651				# X matrix of explanatory variables plus constant
 1.0  -1.34218
 1.0   0.238262
 1.0  -0.496572
 1.0   1.19352
 1.0   0.300229
 1.0   0.409127
 1.0  -0.88967
 1.0  -0.326052
 1.0  -1.74367
 1.0  -0.528113
 1.0   1.42612
 1.0  -1.08846
 1.0  -0.00972169
 1.0  -0.85543
 1.0   1.0301
 1.0   1.67595
 1.0  -0.152156
 1.0   0.26666
 1.0  -0.668618
 1.0  -0.36883
 1.0  -0.301392
 1.0   0.0667779
 1.0  -0.508801
 1.0  -0.352346
 1.0   0.288688
 1.0  -0.240577
 1.0  -0.997697
 1.0  -0.362264
 1.0   0.999308
 1.0  -1.28574
 1.0  -1.91253
 1.0   0.825156
 1.0  -0.136191
 1.0   1.79925
 1.0  -1.10438
 1.0   0.108481
 1.0   0.847916
 1.0   0.594971
 1.0   0.427909]

ε = [   0.5539830489065279             # Errors
        -0.7981494315544392
        0.12994853889935182
  0.23315434715658184
 -0.1959788033050691
 -0.644463980478783
 -0.04055657880388486
 -0.33313251280917094
 -0.315407370840677
  0.32273952815870866
  0.56790436131181
  0.4189982390480762
 -0.0399623088796998
 -0.2900421677961449
 -0.21938513655749814
 -0.2521429229103657
  0.0006247891825243118
 -0.694977951759846
 -0.24108791530910414
  0.1919989647431539
  0.15632862280544485
 -0.16928298502504732
  0.08912288359190582
  0.0037707641031662006
 -0.016111044809837466
  0.01852191562589722
 -0.762541135294584
 -0.7204431774719634
 -0.04394527523005201
 -0.11956323865320413
 -0.6713329013627437
 -0.2339928433338628
 -0.6200532213195297
 -0.6192380993792371
  0.08834918731846135
 -0.5099307915921438
  0.41527207925609494
 -0.7130133329859893
 -0.531213372742777
 -0.09029672309221337]

y = x * β + ε;                      # Generate Data

struct CustomModel <: StatsAPI.RegressionModel
    coef::Vector{Float64}              # Parameter estimates
    vcov::Matrix{Float64}              # Variance-covariance matrix
    dof_residual::Int                  # Residual degrees of freedom
    nobs::Int                          # Number of observations
    coefnames::Vector{String}          # Parameter names
    responsename::String               # Dependent variable name
    LogLikelihood::Float64             # Log-likelihood value
    BIC::Float64                       # Bayesian Information Criterion
    BS::Float64                        # Jarque-Bera test statistic
    civec::Matrix{Float64}             # Confidence intervals matrix
end
```

**Key Points:**
- Stores additional statistics like log-likelihood and BIC
- Includes diagnostic test results (Jarque-Bera)
- Pre-computes confidence intervals for efficient display

### Step 2: Define Custom Regression Statistics

```julia
# Custom statistic for displaying the test
struct MyStatistic <: RegressionTables.AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end

# Constructor for the custom statistic
MyStatistic(m::CustomModel) = MyStatistic(m.BS)
MyStatistic(m::StatsAPI.RegressionModel) = MyStatistic(nothing)  # Default for other models

# Label for display in tables
RegressionTables.label(render::AbstractRenderType, x::Type{MyStatistic}) = "Normality"
```

**Key Points:**
- Custom statistics must subtype `AbstractRegressionStatistic`
- Provide constructors for your model type and a fallback for others
- Define how the statistic should be labeled in tables

### Step 3: Implement Core Interface Methods

```julia
# Essential StatsAPI methods (minimum required)
StatsAPI.coef(m::CustomModel) = m.coef

# Coefficient and response names
StatsAPI.coefnames(m::CustomModel) = m.coefnames
StatsAPI.responsename(m::CustomModel) = m.responsename

# Standard errors (via variance-covariance matrix)
StatsAPI.vcov(m::CustomModel) = m.vcov
StatsAPI.dof_residual(m::CustomModel) = m.dof_residual
StatsAPI.nobs(m::CustomModel) = m.nobs

# Model fit statistics
StatsAPI.loglikelihood(m::CustomModel) = m.LogLikelihood
StatsAPI.bic(m::CustomModel) = m.BIC

# Confidence intervals
StatsAPI.confint(m::CustomModel; level::Real = 0.95) = m.civec

# Model type identification (using RegressionType instead of islinear)
RegressionTables.RegressionType(m::CustomModel) = RegressionTables.RegressionType("My type")

# Define default statistics for this model type
RegressionTables.default_regression_statistics(m::CustomModel) = [Nobs, MyStatistic, LogLikelihood, BIC]

# Remove significance stars for this model
RegressionTables.default_symbol(render::AbstractRenderType) = ""
```

**Key Points:**
- Implements the same essential methods as Example 1
- Uses `RegressionType()` instead of `islinear()` for custom model identification
- `default_regression_statistics()` defines which statistics appear by default
- Can customize display elements like significance stars

### Step 4: Custom Confidence Interval Formatting

```julia
function Base.repr(render::AbstractRenderType, x::ConfInt; 
                   digits=RegressionTables.default_digits(render, x), args...)
    if RegressionTables.value(x) == (0, 0)
        repr(render, "restricted")
    else
        RegressionTables.below_decoration(render, 
            repr(render, RegressionTables.value(x)[1]; digits) * ", " * 
            repr(render, RegressionTables.value(x)[2]; digits))
    end
end
```

**Key Points:**
- Customizes how confidence intervals are displayed
- Handles special case of restricted parameters
- Uses the package's formatting conventions

### Step 5: Advanced Fitting with Optimization

```julia
function StatsAPI.fit(::Type{CustomModel}, X, Y, s_v, restricted_parameters)
    # Define log-likelihood function
    function Log_Likelihood(X, Y, params::AbstractVector{T}, restricted_parameters) where T
        full_parameter_vector = vcat(params, restricted_parameters)
        n = size(X, 1)
        σ = exp(full_parameter_vector["Sigma"])
        llike = -n/2*log(2π) - n/2*log(σ^2) - 
                (sum((Y - X[:,1] * full_parameter_vector["Beta 1"] - 
                      X[:,2] * full_parameter_vector["Beta 2"]).^2) / (2σ^2))
        return -llike  # Return negative for minimization
    end
    
    # Numerical optimization
    func = TwiceDifferentiable(vars -> Log_Likelihood(X, Y, vars, restricted_parameters), 
                              s_v; autodiff=:forward)
    opt = optimize(func, s_v)
    parameters = Optim.minimizer(opt)
    
    # Compute standard errors from Hessian
    var_cov_matrix = inv(hessian!(func, parameters))
    padding = zeros(length(parameters), length(restricted_parameters))
    augmented_var_cov_matrix = [var_cov_matrix padding; 
                               padding' I(length(restricted_parameters))]
    
    # Calculate additional statistics
    ll = -opt.minimum
    n = size(X, 1)
    names_param = names(vcat(parameters, restricted_parameters), 1)
    
    # Confidence intervals with transformations
    left_end = parameters - 1.96 * sqrt.(diag(var_cov_matrix))
    right_end = parameters + 1.96 * sqrt.(diag(var_cov_matrix))
    left_end["Sigma"] = exp(left_end["Sigma"])
    right_end["Sigma"] = exp(right_end["Sigma"])
    parameters["Sigma"] = exp(parameters["Sigma"])
    
    # Diagnostic tests
    all_parameters = vcat(parameters, restricted_parameters)
    residuals = Y - X * all_parameters[["Beta 1", "Beta 2"]]
    BIC = -2 * ll + log(n) * length(parameters)
    BS = JarqueBeraTest(residuals; adjusted=true).JB
    
    civec = vcat(hcat(left_end.array, right_end.array), [0 0])
    
    CustomModel(all_parameters.array, augmented_var_cov_matrix.array, 
               n - length(s_v), n, names_param, "Outcome", ll, BIC, BS, civec)
end
```

**Key Points:**
- Uses maximum likelihood estimation with numerical optimization
- Automatic differentiation for computing Hessian matrix
- Handles parameter transformations (e.g., log-sigma)
- Includes diagnostic testing (Jarque-Bera for normality)
- Constructs confidence intervals accounting for transformations

### Step 6: Usage and Advanced Output

```julia
# Set up optimization parameters
s_v = NamedArray(Array{Float64}(undef, 2))
setnames!(s_v, ["Beta 2", "Sigma"], 1)
s_v["Beta 2"] = 1.0
s_v["Sigma"] = 0.05

# Set up restricted parameters
s_v_r = NamedArray(Array{Float64}(undef, 1))
setnames!(s_v_r, ["Beta 1"], 1)
s_v_r["Beta 1"] = 3.0

# Fit model and generate table with confidence intervals
rr1 = StatsAPI.fit(CustomModel, x, y, s_v, s_v_r)
regtable(rr1, below_statistic = ConfInt)
```

This produces:
```
-------------------------------
                     Outcome
-------------------------------
Beta 2                    3.069
                 (2.926, 3.212)
Sigma                     0.406
                 (0.326, 0.506)
Beta 1                    3.000
                     restricted
-------------------------------
N                            40
Normality                 1.115
Log Likelihood          -20.722
BIC                      48.823
-------------------------------
```

## Implementation Guidelines

### 1. Choose Your Approach
- **Example 1** is ideal for linear models with standard statistics
- **Example 2** is better for complex models requiring numerical methods

### 2. Essential Methods (Minimum Requirements)
Always implement these core methods:
- `StatsAPI.coef()` - coefficient estimates
- One of: `StatsAPI.coefnames()` OR `StatsModels.formula()`
- One of: `StatsAPI.responsename()` OR `StatsModels.formula()`
- One of: `StatsAPI.stderror()` OR `StatsAPI.vcov()`
- One of: `StatsAPI.islinear()` OR `RegressionTables.RegressionType()`

### 3. Optional Enhancements
- `StatsAPI.confint()` - enables confidence interval display
- Custom statistics via `AbstractRegressionStatistic`
- Custom formatting via `Base.repr()` methods
- Model-specific defaults via `default_regression_statistics()`

### 4. Testing Your Implementation
```julia
# Verify basic functionality
model = fit(YourModel, data...)
@assert length(coef(model)) == length(coefnames(model))

# Test table generation
table = regtable(model)
```

### 5. Advanced Customization
- Override `default_regression_statistics()` to change default statistics
- Use `RegressionType()` to customize model identification
- Implement `other_stats()` for completely custom table sections
