[![DOI](https://zenodo.org/badge/746861962.svg)](https://zenodo.org/doi/10.5281/zenodo.10553129)

# yan-etal\_2024\_james

**Ensemble-based Spatially Distributed CLM5 Hydrological Parameter Estimation for the Continental United States**

Hongxiang Yan<sup>1*</sup>, Ning Sun<sup>1</sup>, Hisham Eldardiry<sup>1</sup>, Travis Thurber<sup>1</sup>, Patrick Reed<sup>2</sup>, Daniel Kennedy<sup>3</sup>, Sean Swenson<sup>3</sup>, and Jennie Rice<sup>1</sup>

<sup>1 </sup> Pacific Northwest National Laboratory, Richland, WA, USA
<br/>
<sup>2 </sup> Department of Civil and Environmental Engineering, Cornell University, Ithaca, NY, USA
<br/>
<sup>3 </sup> National Center for Atmospheric Research, Boulder, CO, USA

\* Correspondence: Hongxiang Yan, [hongxiang.yan@pnnl.gov](mailto:hongxiang.yan@pnnl.gov)

## Abstract
One of the major challenges in large-domain hydrological modeling efforts lies in the estimation of spatially distributed hydrological parameters while simultaneously accounting for their associated uncertainties. Addressing this challenge is particularly difficult in ungauged locations. With growing societal demands for large-scale streamflow projections to inform water resource management and long-term planning, evaluating and constraining hydrological parameter uncertainty is increasingly vital. This study introduces a hybrid regionalization approach to enhance hydrological predictions of the Community Land Model version 5 (CLM5) across the Continental United States (CONUS), with a total of 50,629 1/8° grid cells. This hybrid method combines the strengths of two existing techniques: parameter regionalization and streamflow signature regionalization. It identifies ensemble behavioral parameters for each 1/8° grid cell across the CONUS domain, tailored to three distinct streamflow signatures focused on low flows, high flows, and annual water balance. Evaluating this hybrid method for 464 CAMELS (Catchment Attributes and Meteorology for Large-sample Studies) basins demonstrates a significant improvement in CLM5 hydrological predictions, even in challenging arid regions. In CONUS applications, the derived spatially distributed parameter sets capture both spatial continuity and variation of parameters, highlighting their heterogeneous nature within specific regions. Overall, this hybrid regionalization approach offers a promising solution to the complex task of improving hydrological modeling over large domains for important hydrological applications.

## Journal Reference
Yan, H., Sun, N., Eldardiry, H., Thurber, T., Reed, P., Kennedy, D., Swenson, S., and Rice, J. (2024). Ensemble-based Spatially Distributed CLM5 Hydrological Parameter Estimation for the Continental United States. Submitted to Journal of Advances in Modeling Earth Systems – January 2024.

## Data Reference
### Input Data
|       Dataset       |               URL                |               DOI                |
|:-------------------:|:--------------------------------------------:|:--------------------------------:|
|   CAMELS dataset    | https://gdex.ucar.edu/dataset/camels.html | https://dx.doi.org/10.5065/D6MW2F4D, https://doi.org/10.5065/D6G73C3Q |
|   NLDAS-2 dataset   | https://disc.gsfc.nasa.gov/datasets?keywords=NLDAS | various |
|   GSCD datasets     | https://www.gloh2o.org/gscd/ | N/A |

### Output Data
| Dataset | URL | DOI |
|:-------:|:---:|:---:|
| CLM5 CAMELS basin ensemble simulations | https://data.msdlive.org/records/5rpkv-h8n12 | https://doi.org/10.57931/1922953 |
| CLM5 CONUS ensemble simulations | https://app.globus.org/file-manager?origin_id=61db3a79-29fd-407d-98bd-4654422f54d0 | N/A (very large data) |
| Behavioral ensemble CLM5 parameters | https://data.msdlive.org/records/41bw1-3q739 | https://doi.org/10.57931/2274938 |

### Contributing Modeling Software
| Model | Version | URL | DOI |
|:-----:|:-------:|:---:|:---:|
| CLM5  |  im3v1.0.0 | https://github.com/IMMM-SFA/im3-clm | https://zenodo.org/records/6653705 |

## Reproduce My Experiment
Clone the CLM5 repository to set up the CLM5 model, you will need to download the NLDAS-2 forcing data and convert them into netcdf format. You will also need to generate ensemble hydrological parameter value files using the [parameter values](https://data.msdlive.org/records/41bw1-3q739). Once you have finished all CLM5 ensemble runs, you can use the regression data files included in this repository to constrain the behavioral ensemble parameters. The output data [Globus endpoint](https://app.globus.org/file-manager?origin_id=61db3a79-29fd-407d-98bd-4654422f54d0) already contains the ensemble output from the CLM5 model so you can skip rerunning the CLM5 model if you want to save time.

## Reproduce My Figures
| Figure Numbers | Script Name | Description | Figure |
|:--------------:|:-----------:|:-----------:|:------:|
| 1  |   | Regionalization strategy | <a href="./Fig 1.jpg"><img width="100" src="./Fig 1.jpg"/></a> |
| 2  |   | CAMELS basin and grid cell clustering | <a href="./Fig 2.png"><img width="100" src="./Fig 2.png"/></a> |
| 3  | Figure_3.m  | Describe the regional mean daily FDC | <a href="./Fig 3.png"><img width="100" src="./Fig 3.png"/></a> |
| 4  | Figure_4.m  | Describe the relative bias using 3 regionalization methods | <a href="./Fig 4.png"><img width="100" src="./Fig 4.png"/></a> |
| 5  | Figure_5.m  | Describe the Qmean PDF of the behavioral parameter for 7 sites | <a href="./Fig 5.png"><img width="100" src="./Fig 5.png"/></a> |
| 6  | Figure_6.m  | Describe the default and behavior parameters over the CONUS | <a href="./Fig 6.png"><img width="100" src="./Fig 6.png"/></a> |
| 7  | Figure_7.m  | Describe the behavioral parameters for 7 sites | <a href="./Fig 7.png"><img width="100" src="./Fig 7.png"/></a> |
| 8  | figure\_8\_plot\_james\_params.py, figure\_8\_plot\_parallel.py  | Describe the 15 behavioral parameters for one site | <a href="./Fig 8.png"><img width="100" src="./Fig 8.png"/></a> |
| 9  | Figure_9.m  | Describe the ensemble daily FDC for one site using one, two, three constraints | <a href="./Fig 9.png"><img width="100" src="./Fig 9.png"/></a> |
| 10 | Figure_10.m | Describe the Qmean prediction over the CONUS | <a href="./Fig 10.png"><img width="100" src="./Fig 10.png"/></a> |
| 11 | Figure_11.m | Describe the Q10 prediction over the CONUS | <a href="./Fig 11.png"><img width="100" src="./Fig 11.png"/></a> |
| 12 | Figure_12.m | Describe the Q90 prediction over the CONUS | <a href="./Fig 12.png"><img width="100" src="./Fig 12.png"/></a> |
| S1 | Figure_S1.m | Describe the Q10 PDF of the behavioral parameter for 7 sites | <a href="./Fig S1.png"><img width="100" src="./Fig S1.png"/></a> |
| S2 | Figure_S2.m | Describe the Q90 PDF of the behavioral parameter for 7 sites |  <a href="./Fig S2.png"><img width="100" src="./Fig S2.png"/></a> |
