## RegressionTables.jl

This package provides publication-quality regression tables for use with [FixedEffectModels.jl](https://github.com/matthieugomez/FixedEffectModels.jl).

In its objective it is similar to  (and heavily inspired by) the Stata command [`esttab`](http://repec.sowi.unibe.ch/stata/estout/esttab.html) and the R package [`stargazer`](https://cran.r-project.org/web/packages/stargazer/). 

To install the package, type in the Julia command prompt

```julia
Pkg.clone("http://github.com/jmboehm/RegressionTables.jl.git")
```

## A brief demonstration

```julia
using RegressionTables, FixedEffectModels, RDatasets

df = dataset("datasets", "iris")
df[:SpeciesDummy] = pool(df[:Species])

rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy))
rr4 = reg(df, @model(SepalWidth ~ SepalLength + PetalLength + PetalWidth  , fe = SpeciesDummy))

RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput())
```
yields 
```
---------------------------------------------------------
                        SepalLength            SepalWidth
              ------------------------------   ----------
                   (1)        (2)        (3)          (4)
---------------------------------------------------------
SepalWidth    0.804***   0.432***   0.496***             
               (0.106)    (0.081)    (0.086)             
PetalLength              0.776***   0.829***      -0.188*
                          (0.064)    (0.069)      (0.083)
PetalWidth                           -0.315*     0.626***
                                     (0.151)      (0.123)
SepalLength                                      0.378***
                                                  (0.066)
---------------------------------------------------------
N                  150        150        150          150
R2               0.726      0.863      0.867        0.635
---------------------------------------------------------
```
LaTeX output can be produced by using 
```julia
RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput())
```
which yields
```
\begin{tabular}{lrrrr}
\toprule
            & \multicolumn{3}{c}{SepalLength} & \multicolumn{1}{c}{SepalWidth} \\ 
\cmidrule(lr){2-4} \cmidrule(lr){5-5} 
            &      (1) &      (2) &       (3) &                            (4) \\ 
\midrule
SepalWidth  & 0.804*** & 0.432*** &  0.496*** &                                \\ 
            &  (0.106) &  (0.081) &   (0.086) &                                \\ 
PetalLength &          & 0.776*** &  0.829*** &                        -0.188* \\ 
            &          &  (0.064) &   (0.069) &                        (0.083) \\ 
PetalWidth  &          &          &   -0.315* &                       0.626*** \\ 
            &          &          &   (0.151) &                        (0.123) \\ 
SepalLength &          &          &           &                       0.378*** \\ 
            &          &          &           &                        (0.066) \\ 
\midrule
N           &      150 &      150 &       150 &                            150 \\ 
R2          &    0.726 &    0.863 &     0.867 &                          0.635 \\ 
\bottomrule
\end{tabular}
```

## Options

(to be documented)

