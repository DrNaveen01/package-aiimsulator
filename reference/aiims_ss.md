# Print, summarize and tabulate aiims_ss results

Default console display and structured summary methods for sample-size
calculations.

## Usage

``` r
# S3 method for class 'aiims_ss'
print(x, ...)
# S3 method for class 'aiims_ss'
summary(object, ...)
# S3 method for class 'summary.aiims_ss'
print(x, ...)
# S3 method for class 'aiims_ss'
as.data.frame(x, row.names = NULL, optional = FALSE, ...)
```

## Arguments

- x:

  An aiims_ss result object or a summary.aiims_ss summary.

- object:

  An aiims_ss object.

- row.names:

  Unused; retained for method compatibility.

- optional:

  Unused; retained for method compatibility.

- ...:

  Additional arguments, currently ignored.

## Value

Print methods invisibly return their input. The summary method returns a
structured list with an aiims_ss summary class, and as.data.frame
returns a two-column numeric data frame.
