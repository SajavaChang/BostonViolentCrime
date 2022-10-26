# BostonViolentCrime
Using spatial statistical methods to identify influencing factors affecting the number of violent crimes in Boston <br> 
* Please refer to my thesis for details : [Using Spatial Statistical Methods to Explore the Influencing Factors of Assault and Robbery in Boston](https://hdl.handle.net/11296/qc8uzq)


## Research Methods
* Spatial Autocorrelation Analysis : Moran's I & LISA
* Poisson Regression Model
* Spatial Autoregressive Model, SAR
* Conditional Autocorrelation Model, CAR


## Research Result
1. Research has confirmed that crime events are affected by the spatial spillover between adjacent areas, and crime events are clustered in space.
2. The model incorporates the influence of spatial autocorrelation and has better explanatory power.

|  |Poisson Regression |SAR |CAR |
| ------------- |:-------------:|:-------------:|:-------------:|
|	MSE	|	12145.56	|	1552.96	|	1539.348	|

3. 18 significant factors were identified by at least one model. (see the table below)

| No.  | Variable Name |Poisson Regression |SAR |CAR |
| ------------- |:-------------:|:-------------:|:-------------:|:-------------:|
|	X1 	|	Population density	|	V	|	V	|	V	|
|	X2 	|	Sex ratio	|		|		|		|
|	X3 	|	Percentage of prime-age population (18 to 64)	|		|		|	V	|
|	X4 	|	Median age	|		|		|		|
|	X7 	|	Percentage of Asians	|	V	|		|		|
|	X8 	|	Percentage of non-citizens	|	V	|	V	|	V	|
|	X9 	|	Percentage of English proficiency below "very good"	|		|		|		|
|	X13 	|	Median earnings for workers / per capita income	|		|	V	|	V	|
|	X14 	|	Unemployed rate	|		|		|		|
|	X15 	|	Percentage of broadband internet at home	|	V	|	V	|		|
|	X16 	|	Housing density	|		|		|		|
|	X17 	|	Median owner-occupied home price	|		|		|		|
|	X18 	|	Occupancy rate	|	V	|	V	|	V	|
|	X19 	|	Median occupied units paying rent	|	V	|		|		|
|	X20 	|	Vacancy rate	|	V	|	V	|	V	|
|	X21 	|	The percentage of open space	|		|		|		|
|	X22 	|	Street light density	|	V	|	V	|	V	|
|	X23 	|	Percentage of building and property violations	|		|		|		|
|	X24 	|	Number of Blue Bike stations	|	V	|	V	|	V	|
|	X25 	|	Number of cultural and educational institutions (schools and libraries)	|	V	|	V	|	V	|
|	X26 	|	Is there a hospital	|	V	|	V	|		|
|	X27 	|	Is there a police station	|	V	|	V	|	V	|
|	X28 	|	Number of free wifi	|	V	|	V	|	V	|
|	X29 	|	The amount of water in the census area	|	V	|	V	|	V	|
|	X30	|	Factors of a Socially Advantageous Population	|	V	|	V	|	V	|
|	X31	|	High-paying and multi-ethnic areas	|	V	|	V	|	V	|

4. Extracting the hidden elements of these factors can be summarized as :
    1. Densely populated area
    2. More adolescents
    3. Unstable or heterogeneous community population composition
    4. Communities that lack of neighborhood mutual aid or the power of mutual supervision
    5. A suitable environment to start
5. Among them, the vacancy rate was shown to be the most influential positive factor. Therefore, lowing the vacancy rate of areas may effectively reduce the incidence of crimes.
