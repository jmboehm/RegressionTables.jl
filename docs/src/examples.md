# Examples
```@contents
Pages=["examples.md"]
```
Setup for the following examples:
```@meta example_run
DocTestSetup = quote
    using RegressionTables, DataFrames, RDatasets, FixedEffectModels, GLM;
    df = dataset("datasets", "iris");
    df[!,:isSmall] = df[!,:SepalWidth] .< 2.9;
    rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
    rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)));
    rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength * PetalWidth + fe(Species) + fe(isSmall)));
    rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)));
    rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(Species)));
    rr6 = glm(@formula(isSmall ~ PetalLength + PetalWidth + Species), df, Binomial());
end
```
```julia
using RegressionTables, DataFrames, RDatasets, FixedEffectModels, GLM;
df = dataset("datasets", "iris");
df[!,:isSmall] = df[!,:SepalWidth] .< 2.9;
rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)));
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength * PetalWidth + fe(Species) + fe(isSmall)));
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)));
rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(Species)));
rr6 = glm(@formula(isSmall ~ PetalLength + PetalWidth + Species), df, Binomial());
```

## Default

```jldoctest
regtable(rr1,rr2,rr3,rr4,rr5,rr6)

# output

 
------------------------------------------------------------------------------------------
                                     SepalLength                SepalWidth        isSmall
                           ------------------------------   ------------------   ---------
                                (1)        (2)        (3)        (4)       (5)         (6)
------------------------------------------------------------------------------------------
(Intercept)                6.526***                                                 -1.917
                            (0.479)                                                (1.242)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    -0.188*   1.048**      -0.773
                                       (0.064)    (0.129)    (0.083)   (0.362)     (0.554)
PetalWidth                                         -0.625   0.626***              -3.782**
                                                  (0.354)    (0.123)               (1.256)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 0.378***    -0.313
                                                             (0.066)   (0.239)
Species: versicolor                                                              10.441***
                                                                                   (1.957)
Species: virginica                                                               13.230***
                                                                                   (2.636)
------------------------------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes        Yes       Yes
isSmall Fixed Effects                                 Yes
------------------------------------------------------------------------------------------
Estimator                       OLS        OLS        OLS        OLS        IV    Binomial
------------------------------------------------------------------------------------------
N                               150        150        150        150       150         150
R2                            0.014      0.863      0.868      0.635     0.080
Within-R2                                0.642      0.598      0.391    -0.535
First-stage F statistic                                                 19.962
Pseudo R2                     0.006      0.811      0.826      0.862     0.072       0.347
------------------------------------------------------------------------------------------
```

## Below Statistics

### STDError (default)

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = STDError)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

### No statistics

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = nothing)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
SepalWidth                   -0.223   0.432***   0.516***
PetalLength                           0.776***   0.723***      -0.188*
PetalWidth                                         -0.625     0.626***
PetalLength & PetalWidth                            0.066
SepalLength                                                   0.378***
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

### TStat

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = TStat)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                           (13.628)
SepalWidth                   -0.223   0.432***   0.516***
                           (-1.440)    (5.310)    (4.982)
PetalLength                           0.776***   0.723***      -0.188*
                                      (12.073)    (5.615)     (-2.246)
PetalWidth                                         -0.625     0.626***
                                                 (-1.763)      (5.072)
PetalLength & PetalWidth                            0.066
                                                  (0.981)
SepalLength                                                   0.378***
                                                               (5.761)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

### ConfInt (Confidence Interval)

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = ConfInt)

# output

 
------------------------------------------------------------------------------------------------
                                               SepalLength                         SepalWidth
                           --------------------------------------------------   ----------------
                                       (1)              (2)               (3)                (4)
------------------------------------------------------------------------------------------------
(Intercept)                       6.526***
                            (5.580, 7.473)
SepalWidth                          -0.223         0.432***          0.516***
                           (-0.530, 0.083)   (0.271, 0.593)    (0.311, 0.721)
PetalLength                                        0.776***          0.723***            -0.188*
                                             (0.649, 0.903)    (0.469, 0.978)   (-0.353, -0.023)
PetalWidth                                                             -0.625           0.626***
                                                              (-1.325, 0.076)     (0.382, 0.870)
PetalLength & PetalWidth                                                0.066
                                                              (-0.067, 0.199)
SepalLength                                                                             0.378***
                                                                                  (0.248, 0.507)
------------------------------------------------------------------------------------------------
Species Fixed Effects                                   Yes               Yes                Yes
isSmall Fixed Effects                                                     Yes
------------------------------------------------------------------------------------------------
N                                      150              150               150                150
R2                                   0.014            0.863             0.868              0.635
Within-R2                                             0.642             0.598              0.391
------------------------------------------------------------------------------------------------
```

## Standard Errors on same line as coefficient

```jldoctest
regtable(rr1,rr2,rr3,rr4; stat_below=false)

# output

 
----------------------------------------------------------------------------------------------------
                                                 SepalLength                           SepalWidth
                           ------------------------------------------------------   ----------------
                                        (1)                (2)                (3)                (4)
----------------------------------------------------------------------------------------------------
(Intercept)                6.526*** (0.479)
SepalWidth                   -0.223 (0.155)   0.432*** (0.081)   0.516*** (0.104)
PetalLength                                   0.776*** (0.064)   0.723*** (0.129)    -0.188* (0.083)
PetalWidth                                                         -0.625 (0.354)   0.626*** (0.123)
PetalLength & PetalWidth                                            0.066 (0.067)
SepalLength                                                                         0.378*** (0.066)
----------------------------------------------------------------------------------------------------
Species Fixed Effects                                      Yes                Yes                Yes
isSmall Fixed Effects                                                         Yes
----------------------------------------------------------------------------------------------------
N                                       150                150                150                150
R2                                    0.014              0.863              0.868              0.635
Within-R2                                                0.642              0.598              0.391
----------------------------------------------------------------------------------------------------
```

## Keep, drop and order

See [Keep Drop and Order Arguments](@ref)

## Formatting Estimates, Statistics and decimal points

Also see [Customization of Defaults](@ref)

```jldoctest
regtable(rr1,rr2,rr3,rr4; estimformat = "%02.5f")

# output

 
----------------------------------------------------------------------------
                                        SepalLength               SepalWidth
                           ------------------------------------   ----------
                                  (1)          (2)          (3)          (4)
----------------------------------------------------------------------------
(Intercept)                6.52622***
                              (0.479)
SepalWidth                   -0.22336   0.43222***   0.51611***
                              (0.155)      (0.081)      (0.104)
PetalLength                             0.77563***   0.72335***    -0.18757*
                                           (0.064)      (0.129)      (0.083)
PetalWidth                                             -0.62469   0.62571***
                                                        (0.354)      (0.123)
PetalLength & PetalWidth                                0.06596
                                                        (0.067)
SepalLength                                                       0.37777***
                                                                     (0.066)
----------------------------------------------------------------------------
Species Fixed Effects                          Yes          Yes          Yes
isSmall Fixed Effects                                       Yes
----------------------------------------------------------------------------
N                                 150          150          150          150
R2                              0.014        0.863        0.868        0.635
Within-R2                                    0.642        0.598        0.391
----------------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; digits = 4)

# output

 
-------------------------------------------------------------------------
                                      SepalLength              SepalWidth
                           ---------------------------------   ----------
                                 (1)         (2)         (3)          (4)
-------------------------------------------------------------------------
(Intercept)                6.5262***
                             (0.479)
SepalWidth                   -0.2234   0.4322***   0.5161***
                             (0.155)     (0.081)     (0.104)
PetalLength                            0.7756***   0.7234***     -0.1876*
                                         (0.064)     (0.129)      (0.083)
PetalWidth                                           -0.6247    0.6257***
                                                     (0.354)      (0.123)
PetalLength & PetalWidth                              0.0660
                                                     (0.067)
SepalLength                                                     0.3778***
                                                                  (0.066)
-------------------------------------------------------------------------
Species Fixed Effects                        Yes         Yes          Yes
isSmall Fixed Effects                                    Yes
-------------------------------------------------------------------------
N                                150         150         150          150
R2                             0.014       0.863       0.868        0.635
Within-R2                                  0.642       0.598        0.391
-------------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; statisticformat = "%02.5f")

# output

 
-------------------------------------------------------------------------
                                      SepalLength              SepalWidth
                           ---------------------------------   ----------
                                 (1)         (2)         (3)          (4)
-------------------------------------------------------------------------
(Intercept)                 6.526***
                           (0.47890)
SepalWidth                    -0.223    0.432***    0.516***
                           (0.15508)   (0.08139)   (0.10359)
PetalLength                             0.776***    0.723***      -0.188*
                                       (0.06425)   (0.12883)    (0.08349)
PetalWidth                                            -0.625     0.626***
                                                   (0.35439)    (0.12338)
PetalLength & PetalWidth                               0.066
                                                   (0.06726)
SepalLength                                                      0.378***
                                                                (0.06557)
-------------------------------------------------------------------------
Species Fixed Effects                        Yes         Yes          Yes
isSmall Fixed Effects                                    Yes
-------------------------------------------------------------------------
N                                150         150         150          150
R2                           0.01382     0.86331     0.86824      0.63516
Within-R2                                0.64151     0.59784      0.39114
-------------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; digits_stats = 4)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                           0.0138     0.8633     0.8682       0.6352
Within-R2                               0.6415     0.5978       0.3911
----------------------------------------------------------------------
```

## Labeling Coefficients

`labels` is applied first, `transform_labels` applies to within each coefficient

```jldoctest
regtable(rr1,rr2; labels = Dict(
    "SepalLength" => "My dependent variable: SepalLength",
    "PetalLength" => "Length of Petal",
    "PetalWidth" => "Width of Petal",
    "(Intercept)" => "Const." ,
    "isSmall" => "isSmall Dummies",
    "SpeciesDummy" => "Species Dummies"
))

# output

 
-----------------------------------------------------------
                         My dependent variable: SepalLength
                        -----------------------------------
                                     (1)                (2)
-----------------------------------------------------------
Const.                          6.526***
                                 (0.479)
SepalWidth                        -0.223           0.432***
                                 (0.155)            (0.081)
Length of Petal                                    0.776***
                                                    (0.064)
-----------------------------------------------------------
Species Fixed Effects                                   Yes
-----------------------------------------------------------
N                                    150                150
R2                                 0.014              0.863
Within-R2                                             0.642
-----------------------------------------------------------
```

Each piece of an interaction term (or categorical term) is labeled based on its components:

```jldoctest
regtable(rr3; labels=Dict(
     "SepalWidth" => "Sepal Width",
     "PetalLength" => "Petal Length",
     "PetalWidth" => "Petal Width"
)) # it is not necessary to specify a "PetalLength & PetalWidth" label

# output

 
----------------------------------------
                             SepalLength
----------------------------------------
Sepal Width                     0.516***
                                 (0.104)
Petal Length                    0.723***
                                 (0.129)
Petal Width                       -0.625
                                 (0.354)
Petal Length & Petal Width         0.066
                                 (0.067)
----------------------------------------
Species Fixed Effects                Yes
isSmall Fixed Effects                Yes
----------------------------------------
N                                    150
R2                                 0.868
Within-R2                          0.598
----------------------------------------
```

`transform_labels` uses the `replace` function, so the name does not have to match completely:
```jldoctest
regtable(rr1, rr2, rr3; transform_labels = Dict("Width" => " Width", "Length" => " Length"))

# output

 
-----------------------------------------------------------
                                      Sepal Length
                             ------------------------------
                                  (1)        (2)        (3)
-----------------------------------------------------------
(Intercept)                  6.526***
                              (0.479)
Sepal Width                    -0.223   0.432***   0.516***
                              (0.155)    (0.081)    (0.104)
Petal Length                            0.776***   0.723***
                                         (0.064)    (0.129)
Petal Width                                          -0.625
                                                    (0.354)
Petal Length & Petal Width                            0.066
                                                    (0.067)
-----------------------------------------------------------
Species Fixed Effects                        Yes        Yes
isSmall Fixed Effects                                   Yes
-----------------------------------------------------------
N                                 150        150        150
R2                              0.014      0.863      0.868
Within-R2                                  0.642      0.598
-----------------------------------------------------------
```

## Grouping Regressions

Groups are placed above the dependent variable names, allowing you to specify splits or some other group information. Repeated group names are automatically combined.

```jldoctest
regtable(rr1,rr2,rr4,rr3; groups = ["grp1", "grp1", "grp2", "grp2"])

# output

 
-------------------------------------------------------------------------
                                   grp1                    grp2
                           -------------------   ------------------------
                               SepalLength       SepalWidth   SepalLength
                           -------------------   ----------   -----------
                                (1)        (2)          (3)           (4)
-------------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***                   0.516***
                            (0.155)    (0.081)                    (0.104)
PetalLength                           0.776***      -0.188*      0.723***
                                       (0.064)      (0.083)       (0.129)
SepalLength                                        0.378***
                                                    (0.066)
PetalWidth                                         0.626***        -0.625
                                                    (0.123)       (0.354)
PetalLength & PetalWidth                                            0.066
                                                                  (0.067)
-------------------------------------------------------------------------
Species Fixed Effects                      Yes          Yes           Yes
isSmall Fixed Effects                                                 Yes
-------------------------------------------------------------------------
N                               150        150          150           150
R2                            0.014      0.863        0.635         0.868
Within-R2                                0.642        0.391         0.598
-------------------------------------------------------------------------
```

If the length of `groups` is one more than the number of regressions, the first element is placed in the column above the coefficient names:

```jldoctest
regtable(rr1,rr2,rr4,rr3; groups = ["My Group:", "grp1", "grp1", "grp2", "grp2"])

# output

 
-------------------------------------------------------------------------
My Group:                          grp1                    grp2
                           -------------------   ------------------------
                               SepalLength       SepalWidth   SepalLength
                           -------------------   ----------   -----------
                                (1)        (2)          (3)           (4)
-------------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***                   0.516***
                            (0.155)    (0.081)                    (0.104)
PetalLength                           0.776***      -0.188*      0.723***
                                       (0.064)      (0.083)       (0.129)
SepalLength                                        0.378***
                                                    (0.066)
PetalWidth                                         0.626***        -0.625
                                                    (0.123)       (0.354)
PetalLength & PetalWidth                                            0.066
                                                                  (0.067)
-------------------------------------------------------------------------
Species Fixed Effects                      Yes          Yes           Yes
isSmall Fixed Effects                                                 Yes
-------------------------------------------------------------------------
N                               150        150          150           150
R2                            0.014      0.863        0.635         0.868
Within-R2                                0.642        0.391         0.598
-------------------------------------------------------------------------
```

You can also specify groups with integer ranges, just note that column 1 is the column with the coefficient names:

```jldoctest
regtable(rr1,rr2,rr4,rr3; groups = ["My Group:", "grp1" => 2:3, "grp2" => 4:5])

# output

 
-------------------------------------------------------------------------
My Group:                          grp1                    grp2
                           -------------------   ------------------------
                               SepalLength       SepalWidth   SepalLength
                           -------------------   ----------   -----------
                                (1)        (2)          (3)           (4)
-------------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***                   0.516***
                            (0.155)    (0.081)                    (0.104)
PetalLength                           0.776***      -0.188*      0.723***
                                       (0.064)      (0.083)       (0.129)
SepalLength                                        0.378***
                                                    (0.066)
PetalWidth                                         0.626***        -0.625
                                                    (0.123)       (0.354)
PetalLength & PetalWidth                                            0.066
                                                                  (0.067)
-------------------------------------------------------------------------
Species Fixed Effects                      Yes          Yes           Yes
isSmall Fixed Effects                                                 Yes
-------------------------------------------------------------------------
N                               150        150          150           150
R2                            0.014      0.863        0.635         0.868
Within-R2                                0.642        0.391         0.598
-------------------------------------------------------------------------
```

### Multi-Level Groups

Specify multiple group levels by passing a matrix or a vector of vectors:

```jldoctest
regtable(rr1,rr2,rr4,rr3; groups = ["grp parent" "grp parent" "grp parent" "other group"; "grp1" "grp1" "grp2" "grp2"])

# output

 
-------------------------------------------------------------------------
                                      grp parent              other group
                           --------------------------------   -----------
                                   grp1                    grp2
                           -------------------   ------------------------
                               SepalLength       SepalWidth   SepalLength
                           -------------------   ----------   -----------
                                (1)        (2)          (3)           (4)
-------------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***                   0.516***
                            (0.155)    (0.081)                    (0.104)
PetalLength                           0.776***      -0.188*      0.723***
                                       (0.064)      (0.083)       (0.129)
SepalLength                                        0.378***
                                                    (0.066)
PetalWidth                                         0.626***        -0.625
                                                    (0.123)       (0.354)
PetalLength & PetalWidth                                            0.066
                                                                  (0.067)
-------------------------------------------------------------------------
Species Fixed Effects                      Yes          Yes           Yes
isSmall Fixed Effects                                                 Yes
-------------------------------------------------------------------------
N                               150        150          150           150
R2                            0.014      0.863        0.635         0.868
Within-R2                                0.642        0.391         0.598
-------------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr4,rr3; groups = [
    ["Parent Group:", "grp parent" => 2:4, "other group"],
    ["grp1", "grp1", "grp2", "grp2"]
])

# output

 
----------------------------------------------------------------------------
Parent Group:                           grp parent               other group
                           -----------------------------------   -----------
                                    grp1                      grp2
                           ----------------------   ------------------------
                                 SepalLength        SepalWidth   SepalLength
                           ----------------------   ----------   -----------
                                (1)           (2)          (3)           (4)
----------------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223      0.432***                   0.516***
                            (0.155)       (0.081)                    (0.104)
PetalLength                              0.776***      -0.188*      0.723***
                                          (0.064)      (0.083)       (0.129)
SepalLength                                           0.378***
                                                       (0.066)
PetalWidth                                            0.626***        -0.625
                                                       (0.123)       (0.354)
PetalLength & PetalWidth                                               0.066
                                                                     (0.067)
----------------------------------------------------------------------------
Species Fixed Effects                         Yes          Yes           Yes
isSmall Fixed Effects                                                    Yes
----------------------------------------------------------------------------
N                               150           150          150           150
R2                            0.014         0.863        0.635         0.868
Within-R2                                   0.642        0.391         0.598
----------------------------------------------------------------------------
```

## Do not print \$X block

```jldoctest
regtable(rr1,rr2,rr3,rr4; print_fe_section = false)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; print_depvar = false)

# output

 
--------------------------------------------------------------------
                                (1)        (2)        (3)        (4)
--------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    -0.188*
                                       (0.064)    (0.129)    (0.083)
PetalWidth                                         -0.625   0.626***
                                                  (0.354)    (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 0.378***
                                                             (0.066)
--------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes        Yes
isSmall Fixed Effects                                 Yes
--------------------------------------------------------------------
N                               150        150        150        150
R2                            0.014      0.863      0.868      0.635
Within-R2                                0.642      0.598      0.391
--------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; print_estimator_section = false)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr4; number_regressions = false)

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

## Re-order Fixed Effects

Similar arguments to [Keep Drop and Order Arguments](@ref) (equivalent to `keep` before the `fe_suffix` is applied)

```jldoctest
regtable(rr1,rr2,rr3,rr4; fixedeffects = [r"isSmall", "SpeciesDummy"])

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
----------------------------------------------------------------------
```

## Change Labels for Regression Statistics

Also see [Customization of Defaults](@ref)

```jldoctest
regtable(rr1,rr2,rr3,rr4; regression_statistics=[Nobs => "Number of Observations", R2, AdjR2 => "Adj. R2"])

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
Number of Observations          150        150        150          150
R2                            0.014      0.863      0.868        0.635
Adj. R2                       0.007      0.860      0.861        0.622
----------------------------------------------------------------------
```

## All Available Statistics

```jldoctest
regtable(rr1,rr2,rr3,rr5; regression_statistics = [Nobs, R2, PseudoR2, R2CoxSnell, R2Nagelkerke, R2Deviance, AdjR2, AdjPseudoR2, AdjR2Deviance, DOF, LogLikelihood, AIC, AICC, BIC, FStat, FStatPValue, FStatIV, FStatIVPValue, R2Within])

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      1.048**
                                       (0.064)    (0.129)      (0.362)
PetalWidth                                         -0.625
                                                  (0.354)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                     -0.313
                                                               (0.239)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
Estimator                       OLS        OLS        OLS           IV
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.080
Pseudo R2                     0.006      0.811      0.826        0.072
Cox-Snell R2                  0.014      0.863      0.868        0.080
Nagelkerke R2                 0.015      0.944      0.950        0.116
Deviance R2                   0.014      0.863      0.868        0.080
Adjusted R2                   0.007      0.860      0.861        0.055
Pseudo Adjusted R2            0.000      0.789      0.782        0.026
Deviance Adjusted R2          0.007      0.860      0.861        0.055
Degrees of Freedom              147        145        141          145
Log Likelihood             -182.996    -34.787    -32.031      -81.497
AIC                         367.992     73.575     72.062      166.995
AICC                        368.019     73.657     72.338      167.076
BIC                         368.019     73.657     72.338      167.076
F                             2.074    129.736     52.402       17.468
F-test p value                0.152      0.000      0.000        0.000
First-stage F statistic                                         19.962
First-stage p value                                              0.000
Within-R2                                0.642      0.598       -0.535
----------------------------------------------------------------------
```

## LaTeX Output

```jldoctest
regtable(rr1,rr2,rr3,rr4; rndr = LatexTable())

# output

\begin{tabular}{lrrrr}
\toprule
                                & \multicolumn{3}{c}{SepalLength} & \multicolumn{1}{c}{SepalWidth} \\
\cmidrule(lr){2-4} \cmidrule(lr){5-5}
                                &      (1) &      (2) &       (3) &                            (4) \\
\midrule
(Intercept)                     & 6.526*** &          &           &                                \\
                                &  (0.479) &          &           &                                \\
SepalWidth                      &   -0.223 & 0.432*** &  0.516*** &                                \\
                                &  (0.155) &  (0.081) &   (0.104) &                                \\
PetalLength                     &          & 0.776*** &  0.723*** &                        -0.188* \\
                                &          &  (0.064) &   (0.129) &                        (0.083) \\
PetalWidth                      &          &          &    -0.625 &                       0.626*** \\
                                &          &          &   (0.354) &                        (0.123) \\
PetalLength $\times$ PetalWidth &          &          &     0.066 &                                \\
                                &          &          &   (0.067) &                                \\
SepalLength                     &          &          &           &                       0.378*** \\
                                &          &          &           &                        (0.066) \\
\midrule
Species Fixed Effects           &          &      Yes &       Yes &                            Yes \\
isSmall Fixed Effects           &          &          &       Yes &                                \\
\midrule
$N$                             &      150 &      150 &       150 &                            150 \\
$R^2$                           &    0.014 &    0.863 &     0.868 &                          0.635 \\
Within-$R^2$                    &          &    0.642 &     0.598 &                          0.391 \\
\bottomrule
\end{tabular}
```

## Extralines

Extralines are added to the end of a regression table

```jldoctest
regtable(rr1,rr2,rr3,rr4; extralines=["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"])

# output

 
----------------------------------------------------------------------
                                     SepalLength            SepalWidth
                           ------------------------------   ----------
                                (1)        (2)        (3)          (4)
----------------------------------------------------------------------
(Intercept)                6.526***
                            (0.479)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***      -0.188*
                                       (0.064)    (0.129)      (0.083)
PetalWidth                                         -0.625     0.626***
                                                  (0.354)      (0.123)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                   0.378***
                                                               (0.066)
----------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes          Yes
isSmall Fixed Effects                                 Yes
----------------------------------------------------------------------
N                               150        150        150          150
R2                            0.014      0.863      0.868        0.635
Within-R2                                0.642      0.598        0.391
Specification:             Option 1   Option 2   Option 3     Option 4
----------------------------------------------------------------------
```

You can specify that a single value should fill two columns, note that these will inherit the alignment from their section (so with the default `align=:r`, the below example would have items below the second and fourth regression):

```jldoctest
regtable(rr1,rr2,rr3,rr4; extralines=[
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
    ["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]
], align=:c)

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                (1)        (2)        (3)         (4)
------------------------------------------------------------------------
(Intercept)                  6.526***
                              (0.479)
SepalWidth                    -0.223    0.432***   0.516***
                              (0.155)    (0.081)    (0.104)
PetalLength                             0.776***   0.723***     -0.188*
                                         (0.064)    (0.129)     (0.083)
PetalWidth                                          -0.625     0.626***
                                                    (0.354)     (0.123)
PetalLength & PetalWidth                             0.066
                                                    (0.067)
SepalLength                                                    0.378***
                                                                (0.066)
------------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes         Yes
isSmall Fixed Effects                                 Yes
------------------------------------------------------------------------
N                               150        150        150         150
R2                             0.014      0.863      0.868       0.635
Within-R2                                 0.642      0.598       0.391
Specification:               Option 1   Option 2   Option 3    Option 4
Difference in coefficients          1.503                  3.515
------------------------------------------------------------------------
```

You can use the [DataRow](@ref) function to allow for more control, such as underlines and alignment

```jldoctest
regtable(rr1,rr2,rr3,rr4; extralines=[
    DataRow(["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]; align = "lcc", print_underlines=[false, true, true]),
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
(Intercept)                  6.526***
                              (0.479)
SepalWidth                     -0.223   0.432***   0.516***
                              (0.155)    (0.081)    (0.104)
PetalLength                             0.776***   0.723***      -0.188*
                                         (0.064)    (0.129)      (0.083)
PetalWidth                                           -0.625     0.626***
                                                    (0.354)      (0.123)
PetalLength & PetalWidth                              0.066
                                                    (0.067)
SepalLength                                                     0.378***
                                                                 (0.066)
------------------------------------------------------------------------
Species Fixed Effects                        Yes        Yes          Yes
isSmall Fixed Effects                                   Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.014      0.863      0.868        0.635
Within-R2                                  0.642      0.598        0.391
Difference in coefficients          1.503                  3.515
                             -------------------   ---------------------
Specification:               Option 1   Option 2   Option 3     Option 4
------------------------------------------------------------------------
```

Works similarly with HTML or Latex:

```jldoctest
regtable(rr1,rr2,rr3,rr4; rndr=LatexTable(), extralines=[
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
    DataRow(["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]; align = "lcc", print_underlines=[false, true, true])
]) # use DataRow to customize alignment

# output
\begin{tabular}{lrrrr}
\toprule
                                &    \multicolumn{3}{c}{SepalLength}    & \multicolumn{1}{c}{SepalWidth} \\
\cmidrule(lr){2-4} \cmidrule(lr){5-5}
                                &         (1) &         (2) &       (3) &                            (4) \\
\midrule
(Intercept)                     &    6.526*** &             &           &                                \\
                                &     (0.479) &             &           &                                \\
SepalWidth                      &      -0.223 &    0.432*** &  0.516*** &                                \\
                                &     (0.155) &     (0.081) &   (0.104) &                                \\
PetalLength                     &             &    0.776*** &  0.723*** &                        -0.188* \\
                                &             &     (0.064) &   (0.129) &                        (0.083) \\
PetalWidth                      &             &             &    -0.625 &                       0.626*** \\
                                &             &             &   (0.354) &                        (0.123) \\
PetalLength $\times$ PetalWidth &             &             &     0.066 &                                \\
                                &             &             &   (0.067) &                                \\
SepalLength                     &             &             &           &                       0.378*** \\
                                &             &             &           &                        (0.066) \\
\midrule
Species Fixed Effects           &             &         Yes &       Yes &                            Yes \\
isSmall Fixed Effects           &             &             &       Yes &                                \\
\midrule
$N$                             &         150 &         150 &       150 &                            150 \\
$R^2$                           &       0.014 &       0.863 &     0.868 &                          0.635 \\
Within-$R^2$                    &             &       0.642 &     0.598 &                          0.391 \\
Specification:                  &    Option 1 &    Option 2 &  Option 3 &                       Option 4 \\
Difference in coefficients      & \multicolumn{2}{c}{1.503} &          \multicolumn{2}{c}{3.515}         \\
\cmidrule(lr){2-3} \cmidrule(lr){4-5}
\bottomrule
\end{tabular}
```