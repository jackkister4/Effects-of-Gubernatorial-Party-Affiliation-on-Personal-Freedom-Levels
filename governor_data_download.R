##download script for R file to turn into stata data set

##install and load necessary libraries
install.packages("curl")
install.packages("haven")

library(curl)
library(haven)

##load in r file and load in data set
url <- "https://dataverse.harvard.edu/api/access/datafile/5028535"
con <- curl(url)
load(con)

##shorten the name of variable that is too long
colnames(gov_elections_release)[colnames(gov_elections_release) == "gov_raw_county_vote_totals_two_party"] <- "vote_totals_two_party"

##download governor election data set as stata dataset
write_dta(gov_elections_release, "governor_elections.dta")

##check file location of download
getwd()