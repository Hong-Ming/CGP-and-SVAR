# Graph Learning: Causal Graph Process (CGP) & Sparse Vector Autoregressive model (SVAR)

## Table of Contents
- [Intorduction](#intorduction)
- [Directory Tree](#directory-tree)
- [Requirements](#requirements)
- [Description](#description)
- [Reference](#reference)
- [Contributor](#contributor)

## Intorduction
This work contains the impelmentation and comparison of two graph learning algorithms, Causal Graph Process (CGP) [1] and Sparse Vector Autoregressive model (SVAR) [2]. These two graph learning methods can be used to derive the graph representation among a large number of unstructured time series data, and then make predictions on the future data.

## Directory Tree
<pre>
CGP_and_SVAR/
├─ CGP.m ............... Main function for CGP graph learning
├─ CGP_plotgraph.m ..... Plot CGP graph learning result
├─ CGP_prediction.m .... Predict future data using CGP
├─ CGP_MSE_compare.m ... Plot MSE Comparison for different orders of CGP
├─ SVAR.m .............. Main function for SVAR graph learning
├─ SVAR_plotgraph.m .... Plot SVAR graph learning result
├─ SVAR_prediction.m ... Predict future data using SVAR
├─ SVAR_MSE_compare.m .. Plot MSE Comparison for different orders of SVAR
├─ CGP/ ................ Directory for storing CGP graph learning data
├─ SVAR/ ............... Directory for storing SVAR graph learning data
└─ Slides/ ............. 
</pre>

## Requirements
- **MATLAB**: [2019a or later](https://www.mathworks.com/products/matlab.html)
- **CVX**: [Version 2.2 or later](http://cvxr.com/cvx/)

## Description
**For more details, please refer to this [slides](https://github.com/Hong-Ming/CGP_and_SVAR/blob/main/Slides/cgp_and_svar.pdf).**

## Reference
[1] J. Mei and J.M.F. Moura, “Signal processing on graphs: Causal modeling of unstructured data” IEEE Trans. on
Signal Processing, vol. 65(8), pp. 2077−2092, 2017.

[2] A. Davis, Richard & Zang, Pengfei & Zheng, Tian. (2012). “Sparse Vector Autoregressive Modeling.” Journal of
ComputaIonal and Graphical StaIsIcs.

## Contributor
- [Hong-Ming Chiu](https://hong-ming.github.io/)