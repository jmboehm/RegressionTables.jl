# Examples
```@contents
Pages=["examples.md"]
```
Setup for the following examples:
```@meta
DocTestSetup = quote # hide
    using RegressionTables, DataFrames, RDatasets, FixedEffectModels, GLM, MixedModels;
    df = RDatasets.dataset("datasets", "iris");
    df[!,:isSmall] = df[!,:SepalWidth] .< 2.9;
    rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
    rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)));
    rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength * PetalWidth + fe(Species) + fe(isSmall)));
    rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)));
    rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(Species)));
    rr6 = glm(@formula(isSmall ~ PetalLength + PetalWidth + Species), df, Binomial());
    rr7 = glm(@formula(isSmall ~ SepalLength + PetalLength + PetalWidth), df, Binomial());
    lm1 = lm(@formula(SepalLength ~ SepalWidth), df);
    lm2 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + Species), df);
end # hide
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
rr7 = glm(@formula(isSmall ~ SepalLength + PetalLength + PetalWidth), df, Binomial());
lm1 = lm(@formula(SepalLength ~ SepalWidth), df);
lm2 = lm(@formula(SepalLength ~ SepalWidth + PetalLength + Species), df);
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

### StdError (default)

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = StdError)

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

Confidence level defaults to the 95th percentile:

```jldoctest
regtable(rr1,rr2,rr3,rr4,lm1,rr7; below_statistic = ConfInt)

# output

 
-------------------------------------------------------------------------------------------------------------------------------------
                                               SepalLength                         SepalWidth        SepalLength          isSmall    
                           --------------------------------------------------   ----------------   ---------------   ----------------
                                       (1)              (2)               (3)                (4)               (5)                (6)
-------------------------------------------------------------------------------------------------------------------------------------
(Intercept)                       6.526***                                                                6.526***          10.189***
                            (5.580, 7.473)                                                          (5.580, 7.473)    (5.080, 15.298)
SepalWidth                          -0.223         0.432***          0.516***                               -0.223
                           (-0.530, 0.083)   (0.271, 0.593)    (0.311, 0.721)                      (-0.530, 0.083)
PetalLength                                        0.776***          0.723***            -0.188*                             3.580***
                                             (0.649, 0.903)    (0.469, 0.978)   (-0.353, -0.023)                       (2.192, 4.968)
PetalWidth                                                             -0.625           0.626***                             -3.637**
                                                              (-1.325, 0.076)     (0.382, 0.870)                     (-5.847, -1.428)
PetalLength & PetalWidth                                                0.066
                                                              (-0.067, 0.199)
SepalLength                                                                             0.378***                            -3.519***
                                                                                  (0.248, 0.507)                     (-4.884, -2.153)
-------------------------------------------------------------------------------------------------------------------------------------
Species Fixed Effects                                   Yes               Yes                Yes
isSmall Fixed Effects                                                     Yes
-------------------------------------------------------------------------------------------------------------------------------------
Estimator                              OLS              OLS               OLS                OLS               OLS           Binomial
-------------------------------------------------------------------------------------------------------------------------------------
N                                      150              150               150                150               150                150
R2                                   0.014            0.863             0.868              0.635             0.014
Within-R2                                             0.642             0.598              0.391
Pseudo R2                            0.006            0.811             0.826              0.862             0.006              0.297
-------------------------------------------------------------------------------------------------------------------------------------
```

Set the Confidence Interval level either by setting [`RegressionTables.default_confint_level`](@ref) or by adjusting the `confint_level` keyword argument

```jldoctest
regtable(rr1,rr2,rr3,rr4; below_statistic = ConfInt, confint_level=0.9, align=:c)

# output

 
-------------------------------------------------------------------------------------------------
                                               SepalLength                          SepalWidth
                           ---------------------------------------------------   ----------------
                                 (1)               (2)               (3)                (4)
-------------------------------------------------------------------------------------------------
(Intercept)                    6.526***
                            (5.734, 7.319)
SepalWidth                      -0.223          0.432***          0.516***
                           (-0.480, 0.033)   (0.297, 0.567)    (0.345, 0.688)
PetalLength                                     0.776***          0.723***            -0.188*
                                             (0.669, 0.882)    (0.510, 0.937)    (-0.326, -0.049)
PetalWidth                                                         -0.625            0.626***
                                                              (-1.211, -0.038)    (0.421, 0.830)
PetalLength & PetalWidth                                            0.066
                                                               (-0.045, 0.177)
SepalLength                                                                          0.378***
                                                                                  (0.269, 0.486)
-------------------------------------------------------------------------------------------------
Species Fixed Effects                              Yes               Yes                Yes
isSmall Fixed Effects                                                Yes
-------------------------------------------------------------------------------------------------
N                                150               150               150                150
R2                              0.014             0.863             0.868              0.635
Within-R2                                         0.642             0.598              0.391
-------------------------------------------------------------------------------------------------
```

Below statistics (including confidence intervals) are impacted by standardizing the coefficients:


```jldoctest
regtable(lm1,lm2,rr6,rr7; below_statistic = ConfInt, standardize_coef=true)

# output

 
-----------------------------------------------------------------------------------------------
                                  SepalLength                             isSmall
                      ----------------------------------   ------------------------------------
                                  (1)                (2)                 (3)                (4)
-----------------------------------------------------------------------------------------------
(Intercept)                  7.881***           2.887***              -4.119          21.894***
                       (6.738, 9.024)     (2.261, 3.513)     (-9.350, 1.112)   (10.916, 32.871)
SepalWidth                     -0.118           0.228***
                      (-0.279, 0.044)     (0.143, 0.312)
PetalLength                                     1.654***              -2.934          13.578***
                                          (1.383, 1.924)     (-7.053, 1.185)    (8.313, 18.842)
Species: versicolor                            -0.546***           10.611***
                                        (-0.789, -0.303)     (6.713, 14.509)
Species: virginica                             -0.796***           13.445***
                                        (-1.119, -0.474)     (8.195, 18.696)
PetalWidth                                                          -6.193**           -5.957**
                                                           (-10.225, -2.162)   (-9.576, -2.339)
SepalLength                                                                           -6.260***
                                                                               (-8.690, -3.831)
-----------------------------------------------------------------------------------------------
Estimator                         OLS                OLS            Binomial           Binomial
-----------------------------------------------------------------------------------------------
N                                 150                150                 150                150
R2                              0.014              0.863
Pseudo R2                       0.006              0.811               0.347              0.297
-----------------------------------------------------------------------------------------------
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
regtable(rr1,rr2,rr4,rr3; groups = [
     "grp parent" "grp parent" "grp parent" "other group";
     "grp1" "grp1" "grp2" "grp2"
])

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
regtable(rr1,rr2,rr3,rr7; print_fe_section = false)

# output

 
---------------------------------------------------------------------
                                     SepalLength             isSmall
                           ------------------------------   ---------
                                (1)        (2)        (3)         (4)
---------------------------------------------------------------------
(Intercept)                6.526***                         10.189***
                            (0.479)                           (2.607)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    3.580***
                                       (0.064)    (0.129)     (0.708)
PetalWidth                                         -0.625    -3.637**
                                                  (0.354)     (1.127)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 -3.519***
                                                              (0.697)
---------------------------------------------------------------------
Estimator                       OLS        OLS        OLS    Binomial
---------------------------------------------------------------------
N                               150        150        150         150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
Pseudo R2                     0.006      0.811      0.826       0.297
---------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr7; print_depvar = false)

# output

 
---------------------------------------------------------------------
                                (1)        (2)        (3)         (4)
---------------------------------------------------------------------
(Intercept)                6.526***                         10.189***
                            (0.479)                           (2.607)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    3.580***
                                       (0.064)    (0.129)     (0.708)
PetalWidth                                         -0.625    -3.637**
                                                  (0.354)     (1.127)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 -3.519***
                                                              (0.697)
---------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes
isSmall Fixed Effects                                 Yes
---------------------------------------------------------------------
Estimator                       OLS        OLS        OLS    Binomial
---------------------------------------------------------------------
N                               150        150        150         150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
Pseudo R2                     0.006      0.811      0.826       0.297
---------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr7; print_estimator_section = false)

# output

 
---------------------------------------------------------------------
                                     SepalLength             isSmall
                           ------------------------------   ---------
                                (1)        (2)        (3)         (4)
---------------------------------------------------------------------
(Intercept)                6.526***                         10.189***
                            (0.479)                           (2.607)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    3.580***
                                       (0.064)    (0.129)     (0.708)
PetalWidth                                         -0.625    -3.637**
                                                  (0.354)     (1.127)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 -3.519***
                                                              (0.697)
---------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes
isSmall Fixed Effects                                 Yes
---------------------------------------------------------------------
N                               150        150        150         150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
Pseudo R2                     0.006      0.811      0.826       0.297
---------------------------------------------------------------------
```

```jldoctest
regtable(rr1,rr2,rr3,rr7; number_regressions = false)

# output

 
---------------------------------------------------------------------
                                     SepalLength             isSmall
---------------------------------------------------------------------
(Intercept)                6.526***                         10.189***
                            (0.479)                           (2.607)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    3.580***
                                       (0.064)    (0.129)     (0.708)
PetalWidth                                         -0.625    -3.637**
                                                  (0.354)     (1.127)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 -3.519***
                                                              (0.697)
---------------------------------------------------------------------
Species Fixed Effects                      Yes        Yes
isSmall Fixed Effects                                 Yes
---------------------------------------------------------------------
Estimator                       OLS        OLS        OLS    Binomial
---------------------------------------------------------------------
N                               150        150        150         150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
Pseudo R2                     0.006      0.811      0.826       0.297
---------------------------------------------------------------------
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
regtable(rr1,rr2,rr3,rr4; regression_statistics=[
     Nobs => "Number of Observations",
     R2,
     AdjR2 => "Adj. R2"
])

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

## Adding an extra row between coefficients

Using the `extra_space` option allows for a default more like the Stargazer R package. This option adds an extra row after the below statistic and before the next coefficient (or simply between coefficients if there is no below statistic or the below statistic is on the same line as the coefficient).

```jldoctest
regtable(rr1,rr2,rr3,rr4; extra_space = true)

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
regtable(rr1,rr2,rr3,rr4; below_statistic = nothing, extra_space=true)

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

```jldoctest
regtable(rr1,rr2,rr3,rr4; stat_below=false, extra_space=true)

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

```jldoctest

regtable(rr1,rr2,rr3,rr4; render = LatexTable(), extra_space=true)

# output

\begin{tabular}{lrrrr}
\toprule
                                & \multicolumn{3}{c}{SepalLength} & \multicolumn{1}{c}{SepalWidth} \\
\cmidrule(lr){2-4} \cmidrule(lr){5-5}
                                &      (1) &      (2) &       (3) &                            (4) \\
\midrule
(Intercept)                     & 6.526*** &          &           &                                \\
                                &  (0.479) &          &           &                                \\
                                &          &          &           &                                \\
SepalWidth                      &   -0.223 & 0.432*** &  0.516*** &                                \\
                                &  (0.155) &  (0.081) &   (0.104) &                                \\
                                &          &          &           &                                \\
PetalLength                     &          & 0.776*** &  0.723*** &                        -0.188* \\
                                &          &  (0.064) &   (0.129) &                        (0.083) \\
                                &          &          &           &                                \\
PetalWidth                      &          &          &    -0.625 &                       0.626*** \\
                                &          &          &   (0.354) &                        (0.123) \\
                                &          &          &           &                                \\
PetalLength $\times$ PetalWidth &          &          &     0.066 &                                \\
                                &          &          &   (0.067) &                                \\
                                &          &          &           &                                \\
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


## All Available Statistics

```jldoctest
regtable(rr1,rr2,rr3,rr5; regression_statistics = [
     Nobs,
     R2,
     PseudoR2,
     R2CoxSnell,
     R2Nagelkerke,
     R2Deviance,
     AdjR2,
     AdjPseudoR2,
     AdjR2Deviance,
     DOF,
     LogLikelihood,
     AIC,
     AICC,
     BIC,
     FStat,
     FStatPValue,
     FStatIV,
     FStatIVPValue,
     R2Within
])

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
BIC                         371.002     79.596     84.105      173.016
F                             2.074    129.736     52.402       17.468
F-test p value                0.152      0.000      0.000        0.000
First-stage F statistic                                         19.962
First-stage p value                                              0.000
Within-R2                                0.642      0.598       -0.535
----------------------------------------------------------------------
```

## LaTeX Output

```jldoctest
regtable(rr1,rr2,rr3,rr4; render = LatexTable())

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
regtable(rr1,rr2,rr3,rr4;
     extralines=["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"]
)

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
    DataRow(["Difference in coefficients", 1.5032 => 2:3, 3.5152 => 4:5]; align = "lcc", print_underlines=[false, true, true]),
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
regtable(rr1,rr2,rr3,rr4; render=LatexTable(), extralines=[
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

## Do Not Print Fixed Effect Suffix

```jldoctest
regtable(rr1, rr2, rr3, rr7; print_fe_suffix=false)

# output

 
---------------------------------------------------------------------
                                     SepalLength             isSmall
                           ------------------------------   ---------
                                (1)        (2)        (3)         (4)
---------------------------------------------------------------------
(Intercept)                6.526***                         10.189***
                            (0.479)                           (2.607)
SepalWidth                   -0.223   0.432***   0.516***
                            (0.155)    (0.081)    (0.104)
PetalLength                           0.776***   0.723***    3.580***
                                       (0.064)    (0.129)     (0.708)
PetalWidth                                         -0.625    -3.637**
                                                  (0.354)     (1.127)
PetalLength & PetalWidth                            0.066
                                                  (0.067)
SepalLength                                                 -3.519***
                                                              (0.697)
---------------------------------------------------------------------
Species                                    Yes        Yes
isSmall                                               Yes
---------------------------------------------------------------------
Estimator                       OLS        OLS        OLS    Binomial
---------------------------------------------------------------------
N                               150        150        150         150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
Pseudo R2                     0.006      0.811      0.826       0.297
---------------------------------------------------------------------
```

## Standardize Coefficients

Standardizing coefficients adjusts each coefficient by its standard deviation and the standard deviation of the $Y$ variable, making the coefficients equivalent to a 1 standard deviation in $X$ leads to a (result) standard deviation change in $Y$. This is only possible for regressions that store enough information to calculate these standard deviations, currently [GLM.jl](https://github.com/JuliaStats/GLM.jl) and [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl). The intercept, lacking a standard deviation, is simply the number of standard deviations of $Y$.

```jldoctest
regtable(lm1, lm2, rr6, rr7; standardize_coef=true)

# output

 
------------------------------------------------------------------
                           SepalLength              isSmall
                      --------------------   ---------------------
                           (1)         (2)         (3)         (4)
------------------------------------------------------------------
(Intercept)           7.881***    2.887***      -4.119   21.894***
                       (0.578)     (0.317)     (2.669)     (5.601)
SepalWidth              -0.118    0.228***
                       (0.082)     (0.043)
PetalLength                       1.654***      -2.934   13.578***
                                   (0.137)     (2.102)     (2.686)
Species: versicolor              -0.546***   10.611***
                                   (0.123)     (1.989)
Species: virginica               -0.796***   13.445***
                                   (0.163)     (2.679)
PetalWidth                                    -6.193**    -5.957**
                                               (2.057)     (1.846)
SepalLength                                              -6.260***
                                                           (1.240)
------------------------------------------------------------------
Estimator                  OLS         OLS    Binomial    Binomial
------------------------------------------------------------------
N                          150         150         150         150
R2                       0.014       0.863
Pseudo R2                0.006       0.811       0.347       0.297
------------------------------------------------------------------
```

It is also possible to standardize some coefficients and not others

```jldoctest
lm1 = lm(@formula(SepalLength ~ SepalWidth), df);
regtable(lm1, lm1, rr7, rr7; standardize_coef=[false, true, false, true])

# output

 
---------------------------------------------------------
                  SepalLength              isSmall
              -------------------   ---------------------
                   (1)        (2)         (3)         (4)
---------------------------------------------------------
(Intercept)   6.526***   7.881***   10.189***   21.894***
               (0.479)    (0.578)     (2.607)     (5.601)
SepalWidth      -0.223     -0.118
               (0.155)    (0.082)
SepalLength                         -3.519***   -6.260***
                                      (0.697)     (1.240)
PetalLength                          3.580***   13.578***
                                      (0.708)     (2.686)
PetalWidth                           -3.637**    -5.957**
                                      (1.127)     (1.846)
---------------------------------------------------------
Estimator          OLS        OLS    Binomial    Binomial
---------------------------------------------------------
N                  150        150         150         150
R2               0.014      0.014
Pseudo R2        0.006      0.006       0.297       0.297
---------------------------------------------------------
```

## Show Clustered Standard Errors

Displays whether or not the standard errors are clustered and in what ways.

```jldoctest
df_cigar = RDatasets.dataset("plm", "Cigar");

rr_c1 = reg(df_cigar, @formula(Sales ~ NDI + fe(State) + fe(Year)), Vcov.cluster(:State));
rr_c2 = reg(df_cigar, @formula(Sales ~ NDI + Price + fe(State) + fe(Year)), Vcov.cluster(:State, :Year));
rr_c3 = reg(df_cigar, @formula(Sales ~ NDI + Price + fe(State)), Vcov.cluster(:Year));
regtable(rr_c1, rr_c2, rr_c3; print_clusters=true, labels=Dict("Year" => "Sales Year"))

# output

 
----------------------------------------------------------
                                        Sales
                           -------------------------------
                                (1)        (2)         (3)
----------------------------------------------------------
NDI                        -0.007**    -0.005*      0.002*
                            (0.003)    (0.003)     (0.001)
Price                                 -0.823**   -0.413***
                                       (0.230)     (0.084)
----------------------------------------------------------
State Fixed Effects             Yes        Yes         Yes
Sales Year Fixed Effects        Yes        Yes
----------------------------------------------------------
State Clustering                Yes        Yes
Sales Year Clustering                      Yes         Yes
----------------------------------------------------------
N                             1,380      1,380       1,380
R2                            0.832      0.846       0.774
Within-R2                     0.154      0.227       0.273
----------------------------------------------------------
```

## MixedModels Support

This package does support [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl), but instead of displaying fixed effects it will display the variation from the random effects.

```jldoctest
form1 = @formula(rt_trunc ~ 1 + spkr + prec + load +
                          (1 + load | item) +
                          (1 + spkr + prec + load | subj))
contr = Dict(:spkr => EffectsCoding(),
             :prec => EffectsCoding(),
             :load => EffectsCoding(),
             :item => Grouping(),
             :subj => Grouping())
# to make sure the results are always the same, these values help fix the model into one result
fmreθ = [
    0.8648075226444749, 0.43344406279292136, 0.532698219245229,
    0.03139575786126669, 0.269825335511795, 0.5307313041693793,
    0.23438217856147925, 0.0349964462168697, 0.948766814931185,
    0.40866263683286375, 0.6055999220729944, 0.9928229644500718,
    0.05342261972167761,
]
kbm1 = updateL!(setθ!(LinearMixedModel(form1, MixedModels.dataset(:kb07); contrasts=contr), fmreθ))
form2 = @formula(rt_trunc ~ 1 + spkr + prec + load +
                          (1 + spkr + prec + load | subj))

fmreθ = [
    0.27115451643185495, 0.02114691520013967, 0.8794734878503344,
    0.7343424423913391, 0.6603201740011742, 0.8497808579576883,
    0.6355311618411573, 0.7807843933484198, 0.9669197738773895,
    0.03814101806846881,
]
kbm2 = updateL!(setθ!(LinearMixedModel(form2, MixedModels.dataset(:kb07); contrasts=contr), fmreθ))
form3 = @formula(rt_trunc ~ 1 + spkr + prec + load +
                          (1 + load | item) +
                          (1 + spkr + prec * load | subj))

fmreθ = [
    0.7221403658923715, 0.3078425012729602, 0.2917886795704724,
    0.5000142926713435, 0.7426865162047754, 0.1731367021580622,
    0.020327890985133656, 0.7595447732279332, 0.48724482279872006,
    0.6205745741154292, 0.3954285463498247, 0.09594315730251379,
    0.13946651488431383, 0.6672989094861689, 0.2341117878022333,
    0.053650218835408436, 0.143772505670828, 0.027822254707002392,
]
kbm3 = updateL!(setθ!(LinearMixedModel(form3, MixedModels.dataset(:kb07); contrasts=contr), fmreθ))
regtable(kbm1, kbm2, kbm3; labels=Dict(
     "subj" => "Subject",
     "item" => "Item",
     "load: yes" => "Load",
     "prec: maintain" => "Prec",
     "spkr: old" => "Old Speaker"
     )
)

# output

 
---------------------------------------------------------------
                                        rt_trunc
                        ---------------------------------------
                                (1)           (2)           (3)
---------------------------------------------------------------
(Intercept)             2181.911***   2182.017***   2180.342***
                          (117.772)      (35.214)      (58.616)
Old Speaker                  68.034        67.884       67.225*
                           (53.386)      (74.384)      (28.793)
Prec                    -333.636***     -333.785*   -334.362***
                           (76.398)     (158.971)      (66.565)
Load                         78.532        78.426        75.764
                          (167.790)     (150.341)      (70.860)
---------------------------------------------------------------
Item | (Intercept)          447.735                      40.270
Item | Load                 735.081                     109.918
Subject | (Intercept)       639.374       220.685       542.038
Subject | Old Speaker       377.476       537.692       265.104
Subject | Prec              556.544     1,180.880       514.950
Subject | Load              783.505     1,115.791       751.626
Subject | Prec & Load                                   855.252
---------------------------------------------------------------
N                             1,789         1,789         1,789
Log Likelihood          -14,685.198   -14,765.033   -14,711.866
---------------------------------------------------------------
```

## Typst Support

Similar to Latex, this package can produce Typst Tables. This requires Typst v0.11.


```jldoctest
regtable(rr1,rr2,rr3,rr4; render = TypstTable())

# output

#table( 
  columns: (auto, auto, auto, auto, auto),
  align: (left, right, right, right, right),
  column-gutter: 1fr,
  stroke: none,

  table.hline(), 
  []                              ,    table.cell(colspan: 3, align: center)[SepalLength]  , table.cell(colspan: 1, align: center)[SepalWidth],
  table.hline(start: 1, end: 4, stroke: 0.5pt), table.hline(start: 4, end: 5, stroke: 0.5pt),
  []                              ,             [(1)],             [(2)],             [(3)],                                             [(4)],
  table.hline(stroke: 0.7pt),
  [(Intercept)]                   , [6.526$""^(***)$],                [],                [],                                                [],
  []                              ,         [(0.479)],                [],                [],                                                [],
  [SepalWidth]                    ,          [-0.223], [0.432$""^(***)$], [0.516$""^(***)$],                                                [],
  []                              ,         [(0.155)],         [(0.081)],         [(0.104)],                                                [],
  [PetalLength]                   ,                [], [0.776$""^(***)$], [0.723$""^(***)$],                                  [-0.188$""^(*)$],
  []                              ,                [],         [(0.064)],         [(0.129)],                                         [(0.083)],
  [PetalWidth]                    ,                [],                [],          [-0.625],                                 [0.626$""^(***)$],
  []                              ,                [],                [],         [(0.354)],                                         [(0.123)],
  [PetalLength $times$ PetalWidth],                [],                [],           [0.066],                                                [],
  []                              ,                [],                [],         [(0.067)],                                                [],
  [SepalLength]                   ,                [],                [],                [],                                 [0.378$""^(***)$],
  []                              ,                [],                [],                [],                                         [(0.066)],
  table.hline(stroke: 0.7pt),
  [Species Fixed Effects]         ,                [],             [Yes],             [Yes],                                             [Yes],
  [isSmall Fixed Effects]         ,                [],                [],             [Yes],                                                [],
  table.hline(stroke: 0.7pt),
  [_N_]                           ,             [150],             [150],             [150],                                             [150],
  [_R_$""^2$]                     ,           [0.014],           [0.863],           [0.868],                                           [0.635],
  [Within-_R_$""^2$]              ,                [],           [0.642],           [0.598],                                           [0.391],
  table.hline(),
)
```

```jldoctest
regtable(rr1, rr6, rr7; render = TypstTable())

# output

#table( 
  columns: (auto, auto, auto, auto),
  align: (left, right, right, right),
  column-gutter: 1fr,
  stroke: none,

  table.hline(),
  []                   , table.cell(colspan: 1, align: center)[SepalLength], table.cell(colspan: 2, align: center)[isSmall],
  table.hline(start: 1, end: 2, stroke: 0.5pt), table.hline(start: 2, end: 4, stroke: 0.5pt),
  []                   ,                                              [(1)],                  [(2)],                  [(3)],
  table.hline(stroke: 0.7pt),
  [(Intercept)]        ,                                  [6.526$""^(***)$],               [-1.917],     [10.189$""^(***)$],
  []                   ,                                          [(0.479)],              [(1.242)],              [(2.607)],
  [SepalWidth]         ,                                           [-0.223],                     [],                     [],
  []                   ,                                          [(0.155)],                     [],                     [],
  [PetalLength]        ,                                                 [],               [-0.773],      [3.580$""^(***)$],
  []                   ,                                                 [],              [(0.554)],              [(0.708)],
  [PetalWidth]         ,                                                 [],      [-3.782$""^(**)$],      [-3.637$""^(**)$],
  []                   ,                                                 [],              [(1.256)],              [(1.127)],
  [Species: versicolor],                                                 [],     [10.441$""^(***)$],                     [],
  []                   ,                                                 [],              [(1.957)],                     [],
  [Species: virginica] ,                                                 [],     [13.230$""^(***)$],                     [],
  []                   ,                                                 [],              [(2.636)],                     [],
  [SepalLength]        ,                                                 [],                     [],     [-3.519$""^(***)$],
  []                   ,                                                 [],                     [],              [(0.697)],
  table.hline(stroke: 0.7pt),
  [Estimator]          ,                                              [OLS],             [Binomial],             [Binomial],
  table.hline(stroke: 0.7pt),
  [_N_]                ,                                              [150],                  [150],                  [150],
  [_R_$""^2$]          ,                                            [0.014],                     [],                     [],
  [Pseudo _R_$""^2$]   ,                                            [0.006],                [0.347],                [0.297],
  table.hline(),
)
```