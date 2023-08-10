```@setup main_data
using RegressionTables, DataFrames, FixedEffectModels, RDatasets, CategoricalArrays

df = dataset("datasets", "iris")
df[!,:SpeciesDummy] = categorical(df[!,:Species])

rr1 = reg(df, @formula(SepalLength ~ SepalWidth + fe(SpeciesDummy)))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + PetalWidth + fe(SpeciesDummy)))
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)))
```
# Keep Drop and Order Arguments

```@contents
Pages=["keep_order_drop.md"]
```

the `keep`, `drop` and `order` keyword arguments act similarly and allow for quick selection of coefficients to keep and change. The sequence these coefficients are applied in is `keep` -> `drop` -> `order`, so coefficients kept can then be reordered. There are four fundamental ways to select arguments:
- By string
- By Regex
- By index number
- By range

!!! note
    `keep` also adjusts the order of the coefficients, so specifying `keep` and then `order` would allow `order` to adjust the coefficients kept. `drop` does not change order of coefficients.

## By String

Selecting coefficients by string is the most straightforward. Specify arguments by exactly matching the *output* string (if labels are not used, these are the same as the input string). For example, starting with the original example:
```@example main_data
regtable(rr1,rr2,rr3,rr4)
```

To select the first two coefficients, specify `keep=["SepalWidth", "PetalLength"]`:
```@example main_data
regtable(rr1,rr2,rr3,rr4; keep=["SepalWidth", "PetalLength"])
```

Note, if labels change the name of the arguments, then the `keep` argument would also need to change:
```@example main_data
regtable(rr1, rr2, rr3, rr4; labels=Dict("SepalWidth" => "SW", "PetalLength" => "PL"), keep=["SW", "PL"])
```

Interacted coefficients are selected using the `&` to separate the interactions, even if the settings use a different interaction. For example, in Latex, the interaction defaults to `\$times\$`, but would still be selected by using `&`:
```@example main_data
regtable(rr1, rr2, rr3, rr4; rndr=LatexTable(), keep=["SepalWidth & PetalLength"])
```

Similar to interacted coefficients, categorical coefficients are selected using a `: ` between the name and the category.

## By Regex

Regex allows the selection of multiple coefficients based on the provided information. For example, to select coefficients with "Width", specify `keep=[r"Width"]`:
```@example main_data
regtable(rr1,rr2,rr3,rr4; keep=[r"Width"])
```

Regex works similarly to the exact string argument, so if the coefficients are labeled then the regex needs to match the relabeled value. It also expects any interaction to be based on `&` and categorical variables to be `: `, for example:
```@example main_data
rr5 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + fe(SpeciesDummy)))
rr6 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + SpeciesDummy))
regtable(rr5, rr6)
```

```@example main_data
regtable(rr5, rr6; keep=[r": ", r" & "])
```

## By Integer

Specifying an integer allows the selection of specific coefficients:
```@example main_data
regtable(rr1, rr2, rr3, rr4; drop=[3])
```

In typical arrays, Julia specifies the `end` argument to access the last argument. This does not work without direct access to the array, so this package provides an `:end` symbol that is handled similarly:
```@example main_data
regtable(rr1, rr2, rr3, rr4; keep=[1, :end, (:end, 2)])
```

The `Tuple (:end, 2)` is equivalent to `end-2`.

## By Range

Specifying a range works similarly to an integer:
```@example main_data
regtable(rr1, rr2, rr3, rr4; keep=[1:3])
```

There is also a special symbol for selecting a range at the end, `:last`. By itself, `:last` works the same as `:end`, but in a Tuple `(:last, x)` selects the last `x` coefficients:
```@example main_data
regtable(rr1, rr2, rr3, rr4; keep=[1, (:last, 2)])
```

## Mixing keep, drop and order

As mentioned, `keep` is applied first, then `drop` and finally `order`. `keep` also will rearrange arguments, so integer and range arguments in `order` are applied to the resorted arguments from `keep`. It is also possible to mix the different types of selectors. For example, if you want the last coefficient and all coefficients that are interactions:
```@example main_data
regtable(rr5, rr6; keep=[:end, r" & "])
```