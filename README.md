<img src="https://img.shields.io/badge/-MATLAB-lightgrey?logo=matlab&logoColor=orange&style=plastic"> <img src="https://img.shields.io/badge/-Python-lightgrey?logo=python&logoColor=4b8bbe&style=plastic"> <img src="https://img.shields.io/badge/-R-lightgrey?logo=r&logoColor=165caa&style=plastic"><br><br>
Last stable release: 2024/09/16<br>
Author: [Martin Sielfeld](https://github.com/martinsielfeld)<br>
Contributors:<br>

# School Assignment Algorithms

The School Assignment Algorithms package (SAA) offers a flexible set of functions to perform students-to-school matching mechanisms, based on a wide range of rules, priotities and quotas specifications. General matching modeles perfomed by the ```baseSAA``` functions includes: 

* The Boston Assignment Mechanism[^1] (Abdulkadiroğlu, A., & Sönmez, T.,2003).
* The Deferred Acceptance Mechanism [^2] (Gale, D., & Shapley, L. S.,1962).
* Variations of said algorithms based on a priority criteria.

The ```baseSAA``` function  v1.0.0 allows for the following mechanism characteristics:

  * Base student-to-school matching mechanism, based on a priority order.
  * Prioritize students based on N number of different priority groups.
  * Allows for hard quotas (no soft quotas supported in this version).
  * Admission probabilites statistics.
  * Cutoffs statistics.
  * Seats statistics.

## Functions

### baseSAA

The base School Assaginment Algorithm (SAA) function performs a basic student-to-school matching procedure based on applications, capacities, and a set of parameters.

Argument | Description | Categories
-------- | ---------- | ----------
apps | Applications dataframe |
vacs | Capacities dataframe |
iters | Number of iterations |
seed | Seed for randomization |
get_wl | Get waitinglist in each iteration | True <br> False
get_assignment | Get assignment in each iteration | True <br> False
get_cutoffs | Get cutoffs in each iteration | True <br> False
get_probs | Get admission probabilities distribution | True <br> False
get_stats | Get seats statistics distribution | True <br> False
transfer_capacity | Are applicants from special quotas allowed to also compete in the regular quota? | True <br> False
tiebreak | Tiebreak level | Applicant <br> Application
rand_type | Use common library to get same results in Python and R? | local <br> py&r

### baseAMSAA

Base After-market School Assignment Algorithm (AMSAA)

Argument | Categories | Description
-------- | ---------- | ----------

## Priority Profile

### Boston Algorithm (Los Angeles, US, 2024)

### Deferred Acceptance Algorithm (Chile, 2024)

### Variation I (New Haven, US, 2018)

### Variation II (Denmark, 2024)



## Inputs

[^1]: Abdulkadiroğlu, A., & Sönmez, T. (2003). School choice: A mechanism design approach. American economic review, 93(3), 729-747. https://doi.org/10.1257/000282803322157061

[^2]: Gale, D., & Shapley, L. S. (1962). College Admissions and the Stability of Marriage. The American Mathematical Monthly, 69(1), 9–15. https://doi.org/10.1080/00029890.1962.11989827
