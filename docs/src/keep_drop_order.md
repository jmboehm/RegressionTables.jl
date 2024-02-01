```@meta
DocTestSetup = quote # hide
    using RegressionTables, DataFrames, FixedEffectModels, RDatasets

    df = dataset("datasets", "iris")
    df[!,:SpeciesDummy] = df[!,:Species]

    rr1 = reg(df, @formula(SepalLength ~ SepalWidth + fe(SpeciesDummy)))
    rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)))
    rr3 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + PetalWidth + fe(SpeciesDummy)))
    rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)))
    rr5 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + fe(SpeciesDummy)))
    rr6 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + SpeciesDummy))
end # hide
```
# Keep Drop and Order Arguments

```@contents
Pages=["keep_order_drop.md"]
```

the `keep`, `drop` and `order` keyword arguments act similarly and allow for quick selection of coefficients to keep and change. The sequence these options are applied in is `keep` -> `drop` -> `order`, so coefficients kept can then be reordered. There are four fundamental ways to select arguments:
- By string
- By Regex
- By index number
- By range

!!! note
    `keep` also adjusts the order of the coefficients, so specifying `keep` and then `order` would allow `order` to adjust the coefficients kept. `drop` does not change order of coefficients.

!!! note
     The `keep`, `drop` and `order` arguments use the relabeled versions of coefficients. If labels (or transform_labels) are used, then the `keep`, `drop` and `order` arguments should use the relabeled versions of the coefficients.

Just to setup these examples:
```julia
using RegressionTables, DataFrames, FixedEffectModels, RDatasets

df = dataset("datasets", "iris")
df[!,:SpeciesDummy] = df[!,:Species]

rr1 = reg(df, @formula(SepalLength ~ SepalWidth + fe(SpeciesDummy)))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + PetalWidth + fe(SpeciesDummy)))
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)))
rr5 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + fe(SpeciesDummy)))
rr6 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + SpeciesDummy))
```
## By String

Selecting coefficients by string is the most straightforward. Specify arguments by exactly matching the *output* string (if labels are not used, these are the same as the input string). For example, starting with the original example:
```jldoctest
regtable(rr1,rr2,rr3,rr4)

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PetalLength                             0.776***   1.047***      -0.188*
                                         (0.064)    (0.143)      (0.083)
PetalWidth                                           -0.259     0.626***
                                                    (0.154)      (0.123)
SepalWidth & PetalLength                             -0.070
                                                    (0.041)
SepalLength                                                     0.378***
                                                                 (0.066)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

To select the first two coefficients, specify `keep=["SepalWidth", "PetalLength"]`:
```jldoctest
regtable(rr1,rr2,rr3,rr4; keep=["SepalWidth", "PetalLength"])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PetalLength                             0.776***   1.047***      -0.188*
                                         (0.064)    (0.143)      (0.083)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                                Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

Interacted coefficients are selected using the `&` to separate the interactions, even if the settings use a different interaction. For example, in Latex, the interaction defaults to `\$times\$`, but would still be selected by using `&`:
```jldoctest
regtable(rr1, rr2, rr3, rr4; render=LatexTable(), keep=["SepalWidth & PetalLength"])

# output
\begin{tabular}{lrrrr}
\toprule
                                & \multicolumn{3}{c}{SepalLength} & \multicolumn{1}{c}{SepalWidth} \\ 
\cmidrule(lr){2-4} \cmidrule(lr){5-5}
                                &      (1) &      (2) &       (3) &                            (4) \\ 
\midrule
SepalWidth $\times$ PetalLength &          &          &    -0.070 &                                \\ 
                                &          &          &   (0.041) &                                \\ 
\midrule
SpeciesDummy Fixed Effects      &      Yes &      Yes &       Yes &                            Yes \\ 
\midrule
Controls                        &      Yes &      Yes &       Yes &                            Yes \\ 
\midrule
$N$                             &      150 &      150 &       150 &                            150 \\ 
$R^2$                           &    0.726 &    0.863 &     0.870 &                          0.635 \\ 
Within-$R^2$                    &    0.281 &    0.642 &     0.659 &                          0.391 \\ 
\bottomrule
\end{tabular}
```

Similar to interacted coefficients, categorical coefficients are selected using a `: ` between the name and the category.

## By Regex

Regex allows the selection of multiple coefficients based on the provided information. For example, to select coefficients with "Width", specify `keep=[r"Width"]`:
```jldoctest
regtable(rr1,rr2,rr3,rr4; keep=[r"Width"])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PetalWidth                                           -0.259     0.626***
                                                    (0.154)      (0.123)
SepalWidth & PetalLength                             -0.070
                                                    (0.041)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                     Yes        Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

Regex works similarly to the exact string argument, so if the coefficients are labeled then the regex needs to match the relabeled value. It also expects any interaction to be based on `&` and categorical variables to be `: `, for example:
```jldoctest
regtable(rr5, rr6)

# output

 
-------------------------------------------------
                                  SepalLength
                             --------------------
                                  (1)         (2)
-------------------------------------------------
SepalWidth                   0.715***    0.432***
                              (0.156)     (0.081)
PetalLength                  1.050***    0.776***
                              (0.144)     (0.064)
SepalWidth & PetalLength      -0.085*
                              (0.040)
(Intercept)                              2.390***
                                          (0.262)
SpeciesDummy: versicolor                -0.956***
                                          (0.215)
SpeciesDummy: virginica                 -1.394***
                                          (0.286)
-------------------------------------------------
SpeciesDummy Fixed Effects        Yes
-------------------------------------------------
N                                 150         150
R2                              0.867       0.863
Within-R2                       0.652
-------------------------------------------------
```

```jldoctest
regtable(rr5, rr6; keep=[r": ", r" & "])

# output

 
------------------------------------------------
                                 SepalLength
                             -------------------
                                 (1)         (2)
------------------------------------------------
SpeciesDummy: versicolor               -0.956***
                                         (0.215)
SpeciesDummy: virginica                -1.394***
                                         (0.286)
SepalWidth & PetalLength     -0.085*
                             (0.040)
------------------------------------------------
SpeciesDummy Fixed Effects       Yes
------------------------------------------------
Controls                         Yes         Yes
------------------------------------------------
N                                150         150
R2                             0.867       0.863
Within-R2                      0.652
------------------------------------------------
```

## By Integer

Specifying an integer allows the selection of specific coefficients:
```jldoctest
regtable(rr1, rr2, rr3, rr4; drop=[3])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PetalLength                             0.776***   1.047***      -0.188*
                                         (0.064)    (0.143)      (0.083)
SepalWidth & PetalLength                             -0.070
                                                    (0.041)
SepalLength                                                     0.378***
                                                                 (0.066)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                                Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

In typical arrays, Julia specifies the `end` argument to access the last argument. This does not work without direct access to the array, so this package provides an `:end` symbol that is handled similarly:
```jldoctest
regtable(rr1, rr2, rr3, rr4; keep=[1, :end, (:end, 2)])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
SepalLength                                                     0.378***
                                                                 (0.066)
PetalWidth                                           -0.259     0.626***
                                                    (0.154)      (0.123)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                     Yes        Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

The `Tuple (:end, 2)` is equivalent to `end-2`.

## By Range

Specifying a range works similarly to an integer:
```jldoctest
regtable(rr1, rr2, rr3, rr4; keep=[1:3])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PetalLength                             0.776***   1.047***      -0.188*
                                         (0.064)    (0.143)      (0.083)
PetalWidth                                           -0.259     0.626***
                                                    (0.154)      (0.123)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                                Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

There is also a special symbol for selecting a range at the end, `:last`. By itself, `:last` works the same as `:end`, but in a Tuple `(:last, x)` selects the last `x` coefficients:
```jldoctest
regtable(rr1, rr2, rr3, rr4; keep=[1, (:last, 2)])

# output

 
------------------------------------------------------------------------
                                       SepalLength            SepalWidth
                             ------------------------------   ----------
                                  (1)        (2)        (3)          (4)
------------------------------------------------------------------------
SepalWidth                   0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
SepalWidth & PetalLength                             -0.070
                                                    (0.041)
SepalLength                                                     0.378***
                                                                 (0.066)
------------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes          Yes
------------------------------------------------------------------------
Controls                                     Yes        Yes          Yes
------------------------------------------------------------------------
N                                 150        150        150          150
R2                              0.726      0.863      0.870        0.635
Within-R2                       0.281      0.642      0.659        0.391
------------------------------------------------------------------------
```

## Mixing keep, drop and order

As mentioned, `keep` is applied first, then `drop` and finally `order`. `keep` also will rearrange arguments, so integer and range arguments in `order` are applied to the resorted arguments from `keep`. It is also possible to mix the different types of selectors. For example, if you want the last coefficient and all coefficients that are interactions:
```jldoctest
regtable(rr5, rr6; keep=[:end, r" & "])

# output

 
------------------------------------------------
                                 SepalLength
                             -------------------
                                 (1)         (2)
------------------------------------------------
SpeciesDummy: virginica                -1.394***
                                         (0.286)
SepalWidth & PetalLength     -0.085*
                             (0.040)
------------------------------------------------
SpeciesDummy Fixed Effects       Yes
------------------------------------------------
Controls                         Yes         Yes
------------------------------------------------
N                                150         150
R2                             0.867       0.863
Within-R2                      0.652
------------------------------------------------
```

## Relabeled Coefficients

By default, if labels change the name of the arguments, then `keep`, `drop` and `order` should use the relabeled versions of the coefficients. For example, if the coefficients are relabeled:

```jldoctest
regtable(rr1, rr2, rr3, rr4; labels=Dict("SepalWidth" => "SW", "PetalLength" => "PL"), keep=["SW", "PL"])

# output

 
---------------------------------------------------------------------
                                       SepalLength               SW
                             ------------------------------   -------
                                  (1)        (2)        (3)       (4)
---------------------------------------------------------------------
SW                           0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PL                                      0.776***   1.047***   -0.188*
                                         (0.064)    (0.143)   (0.083)
---------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes       Yes
---------------------------------------------------------------------
Controls                                                Yes       Yes
---------------------------------------------------------------------
N                                 150        150        150       150
R2                              0.726      0.863      0.870     0.635
Within-R2                       0.281      0.642      0.659     0.391
---------------------------------------------------------------------
```

To use the original coefficient names, set `use_relabeled_values=false`:
```jldoctest
regtable(rr1, rr2, rr3, rr4; labels=Dict("SepalWidth" => "SW", "PetalLength" => "PL"), keep=["SepalWidth", "PetalLength"], use_relabeled_values=false)

# output

 
---------------------------------------------------------------------
                                       SepalLength               SW  
                             ------------------------------   -------
                                  (1)        (2)        (3)       (4)
---------------------------------------------------------------------
SW                           0.804***   0.432***   0.719***
                              (0.106)    (0.081)    (0.155)
PL                                      0.776***   1.047***   -0.188*
                                         (0.064)    (0.143)   (0.083)
---------------------------------------------------------------------
SpeciesDummy Fixed Effects        Yes        Yes        Yes       Yes
---------------------------------------------------------------------
Controls                                                Yes       Yes
---------------------------------------------------------------------
N                                 150        150        150       150
R2                              0.726      0.863      0.870     0.635
Within-R2                       0.281      0.642      0.659     0.391
---------------------------------------------------------------------
```