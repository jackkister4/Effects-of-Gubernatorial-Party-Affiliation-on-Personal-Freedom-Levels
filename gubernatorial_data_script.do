//do file for governor election data set

//download statastates for state name to abbreviation conversion
ssc install statastates

//set directory
cd "C:\Users\jackk\OneDrive\Desktop\Professional Project\Data\Data Process"

//load in governor data set
use "governor_elections.dta"

//drop all year before 2000
drop if election_year < 2000

//combine county totals to state total
collapse (sum) raw_county_vote_totals vote_totals_two_party republican_raw_votes democratic_raw_votes , by(state sfips election_year)

//rename variables
rename raw_county_vote_totals total_votes
rename vote_totals_two_party two_party_votes
rename republican_raw_votes republican_votes
rename democratic_raw_votes democratic_votes

//destring sfips to allow for merging
destring sfips, replace

//save and close governor elections data
save "governor_elections_working.dta", replace
clear

//turn missing observations excel file into stata data set
import excel using "governor_elections_missing.xlsx", sheet("Missing Results") firstrow
save "governor_elections_missing.dta", replace
clear

//load in governor data set
use "governor_elections_working.dta"

//add missing observations by merging data set
append using "governor_elections_missing.dta"

//generate election year dummy
gen election_year_dummy = 1

//generate year variable
gen year = election_year
order state year sfips election_year

//generate between years
fillin state year

//generate election year dummy
replace _fillin = 0 if _fillin == 1
replace _fillin = 1 if election_year_dummy == 1
rename _fillin election_dummy
drop election_year_dummy


//remove early years where there is no previous election data
//remove years for 2000 with no previous election data
drop if year == 2000 & election_dummy == 0

//remove years for 2001 with no previous election data
bysort state: egen flag = max((year == 2000 & election_dummy == 1) | (year == 2001 & election_dummy == 1))
gen indicator = (year == 2001 & flag == 1)
drop flag
drop if year == 2001 & indicator == 0
drop indicator

//remove years for 2002 with no previous election data
bysort state: egen flag = max((year == 2000 & election_dummy == 1) | (year == 2001 & election_dummy == 1) | (year == 2002 & election_dummy == 1))
gen indicator = (year == 2002 & flag == 1)
drop flag
drop if year == 2002 & indicator == 0
drop indicator

//save to allow for different cleaning of 4 year and 2 year election cycles
save "governor_elections_working.dta", replace

//create two year election cycle file
drop if !(state == "NH" | state == "VT")

//fill observations with vote info from previous elections
//generate dummies for each year after election
bysort state (year): gen one_year_after = election_dummy[_n-1]
replace one_year_after = 0 if missing(one_year_after)

//lagged variables for previous election for each year and each variable
bysort state (year): gen lag_total_votes1 = total_votes[_n-1]
bysort state (year): gen lag_two_party_votes1 = two_party_votes[_n-1]
bysort state (year): gen lag_republican_votes1 = republican_votes[_n-1]
bysort state (year): gen lag_democratic_votes1 = democratic_votes[_n-1]
bysort state (year): gen lag_sfips1 = sfips[_n-1]
bysort state (year): gen lag_election_year1 = election_year[_n-1]

//replace values with lagged values
replace total_votes = lag_total_votes1 if one_year_after == 1
replace two_party_votes = lag_two_party_votes1 if one_year_after == 1
replace republican_votes = lag_republican_votes1 if one_year_after == 1
replace democratic_votes = lag_democratic_votes1 if one_year_after == 1
replace sfips = lag_sfips1 if one_year_after == 1
replace election_year = lag_election_year1 if one_year_after == 1

//drop lagged values
drop lag_total_votes1 lag_two_party_votes1 lag_republican_votes1 lag_democratic_votes1 lag_sfips1 lag_election_year1

//save and move on to four year cycles
save "governor_elections_2_years.dta", replace
clear


//open governor elections data set
use "governor_elections_working.dta"

//drop 2 year election cycles
drop if state == "NH" | state == "VT"

//fill observations with vote info from previous elections
//generate dummies for each year after election
bysort state (year): gen one_year_after = election_dummy[_n-1]
replace one_year_after = 0 if missing(one_year_after)

bysort state (year): gen two_years_after = election_dummy[_n-2]
replace two_years_after = 0 if missing(two_years_after)

bysort state (year): gen three_years_after = election_dummy[_n-3]
replace three_years_after = 0 if missing(three_years_after)

//lagged variables for previous election for each year and each variable
bysort state (year): gen lag_total_votes1 = total_votes[_n-1]
bysort state (year): gen lag_two_party_votes1 = two_party_votes[_n-1]
bysort state (year): gen lag_republican_votes1 = republican_votes[_n-1]
bysort state (year): gen lag_democratic_votes1 = democratic_votes[_n-1]
bysort state (year): gen lag_sfips1 = sfips[_n-1]
bysort state (year): gen lag_election_year1 = election_year[_n-1]
bysort state (year): gen lag_total_votes2 = total_votes[_n-2]
bysort state (year): gen lag_two_party_votes2 = two_party_votes[_n-2]
bysort state (year): gen lag_republican_votes2 = republican_votes[_n-2]
bysort state (year): gen lag_democratic_votes2 = democratic_votes[_n-2]
bysort state (year): gen lag_sfips2 = sfips[_n-2]
bysort state (year): gen lag_election_year2 = election_year[_n-2]
bysort state (year): gen lag_total_votes3 = total_votes[_n-3]
bysort state (year): gen lag_two_party_votes3 = two_party_votes[_n-3]
bysort state (year): gen lag_republican_votes3 = republican_votes[_n-3]
bysort state (year): gen lag_democratic_votes3 = democratic_votes[_n-3]
bysort state (year): gen lag_sfips3 = sfips[_n-3]
bysort state (year): gen lag_election_year3 = election_year[_n-3]

//replace values with lagged values
replace total_votes = lag_total_votes1 if one_year_after == 1
replace two_party_votes = lag_two_party_votes1 if one_year_after == 1
replace republican_votes = lag_republican_votes1 if one_year_after == 1
replace democratic_votes = lag_democratic_votes1 if one_year_after == 1
replace sfips = lag_sfips1 if one_year_after == 1
replace election_year = lag_election_year1 if one_year_after == 1
replace total_votes = lag_total_votes2 if two_years_after == 1
replace two_party_votes = lag_two_party_votes2 if two_years_after == 1
replace republican_votes = lag_republican_votes2 if two_years_after == 1
replace democratic_votes = lag_democratic_votes2 if two_years_after == 1
replace sfips = lag_sfips2 if two_years_after == 1
replace election_year = lag_election_year2 if two_years_after == 1
replace total_votes = lag_total_votes3 if three_years_after == 1
replace two_party_votes = lag_two_party_votes3 if three_years_after == 1
replace republican_votes = lag_republican_votes3 if three_years_after == 1
replace democratic_votes = lag_democratic_votes3 if three_years_after == 1
replace sfips = lag_sfips3 if three_years_after == 1
replace election_year = lag_election_year3 if three_years_after == 1

//drop lagged values
drop lag_total_votes1 lag_two_party_votes1 lag_republican_votes1 lag_democratic_votes1 lag_sfips1 lag_election_year1 lag_total_votes2 lag_two_party_votes2 lag_republican_votes2 lag_democratic_votes2 lag_sfips2 lag_election_year2 lag_total_votes3 lag_two_party_votes3 lag_republican_votes3 lag_democratic_votes3 lag_sfips3 lag_election_year3

//append 2 year to 4 year elections
append using "governor_elections_2_years.dta"

//drop year indicator variables
drop one_year_after two_years_after three_years_after

//generate key
egen key = concat(state year), p(" ")
sort key year state sfips

//generate vote share variable (using total between the two parties)
gen d_vote_share = (democratic_votes/two_party_votes)*100

//generate margin of victory variable
gen r_vote_share = 100 - d_vote_share
gen margin_of_victory = (d_vote_share - r_vote_share)

//sort by election year and state
sort election_year sfips

//save and clear the data set for personal freedom values cleaning
save "governor_elections_working.dta", replace
clear


//clean personal freedom index variable
//upload personal freedom index variable
import excel using "Freedom_In_The_50_States_2023.xlsx", sheet("Overall") cellrange(A1:G1151) firstrow

//rename variables
rename PersonalFreedom personal_freedom
rename State state
rename Year year

//drop unecessary variables
drop FiscalPolicy fprank RegulatoryPolicy rprank

//create abbreviations and fips
statastates, name(state)
drop if _merge == 2
drop _merge state
rename state_abbrev state
rename state_fips sfips

//generate key
egen key = concat(state year), p(" ")
order key year state sfips

save "pfi_working.dta", replace
clear


//clean personal freedom category variables
//upload personal freedom index category variables
import excel using "Freedom_In_The_50_States_2023.xlsx", sheet("Personal") cellrange(A7:HH1156)

//keep columns
keep A B BA CK HH

//rename variables
rename A state
rename B year
rename BA gun_freedom
rename CK cannabis_freedom
rename HH tobacco_freedom

//create abbreviations and fips
statastates, name(state)
drop if _merge == 2
drop _merge state
rename state_abbrev state
rename state_fips sfips

//generate key
egen key = concat(state year), p(" ")
order key year state sfips

save "pfi_categories_working.dta", replace
clear

//use governor election data set to begin merging
use "governor_elections_working.dta"

//merge with pfi
merge 1:1 key using "pfi_working.dta"
drop if _merge == 2
drop _merge

//merge with pfi categories
merge 1:1 key using "pfi_categories_working.dta"
drop if _merge == 2
drop _merge

//gen dem_gov
gen dem_gov = (democratic_votes > republican_votes)

//gen delayed election year variable
gen delay_election = election_year
replace delay_election = election_year - 4 if election_year == year


//shift election data back one year
gen total_votes_shift = total_votes[_n-1]
gen dem_gov_shift = dem_gov[_n-1]
gen d_vote_share_shift = d_vote_share[_n-1]
gen r_vote_share_shift = r_vote_share[_n-1]
gen margin_of_victory_shift = margin_of_victory[_n-1]
gen two_party_votes_shift = two_party_votes[_n-1]
gen republican_votes_shift = republican_votes[_n-1]
gen democratic_votes_shift = democratic_votes[_n-1]

//remove first year for each state
sort state year
bysort state (year): gen first_year = (_n == 1)

replace total_votes_shift = . if first_year == 1
replace dem_gov_shift = . if first_year == 1
replace d_vote_share_shift = . if first_year == 1
replace r_vote_share_shift = . if first_year == 1
replace margin_of_victory_shift = . if first_year == 1
replace two_party_votes_shift = . if first_year == 1
replace republican_votes_shift = . if first_year == 1
replace democratic_votes_shift = . if first_year == 1

drop first_year

//drop old vars
drop total_votes dem_gov d_vote_share r_vote_share margin_of_victory two_party_votes republican_votes democratic_votes

//rename vars
rename total_votes_shift total_votes
rename dem_gov_shift dem_gov
rename d_vote_share_shift d_vote_share
rename r_vote_share_shift r_vote_share
rename margin_of_victory_shift margin_of_victory
rename two_party_votes_shift two_party_votes
rename republican_votes_shift republican_votes
rename democratic_votes_shift democratic_votes


//order and sort
order key state year sfips election_year delay_election election_dummy dem_gov d_vote_share r_vote_share margin_of_victory personal_freedom gun_freedom cannabis_freedom tobacco_freedom 
sort state year
drop sfips

//save and clear the data set for previous election year values
save "governor_elections_working.dta", replace
clear

//load previous election year values to convert to stata data set for easy merging
import excel using "governor_elections_missing.xlsx", sheet("Previous Elections") firstrow
destring dem_gov, replace
save "governor_elections_previous.dta", replace
clear

//use governor election data set to begin merging
use "governor_elections_working.dta"

//merge with missing values
merge 1:1 key using "governor_elections_previous.dta"

//replace with missing values
replace dem_gov = dem_gov_ if missing(dem_gov)
replace margin_of_victory = margin_of_victory_ if missing(margin_of_victory)
replace d_vote_share = d_vote_share_ if missing(d_vote_share)
replace r_vote_share = r_vote_share_ if missing(r_vote_share)
replace total_votes = total_votes_ if missing(total_votes)
replace two_party_votes = two_party_votes_ if missing(two_party_votes)
replace republican_votes = republican_votes_ if missing(republican_votes)
replace democratic_votes = democratic_votes_ if missing(democratic_votes)

//drop merging variables
drop d_vote_share_ r_vote_share_ margin_of_victory_ dem_gov_ total_votes_ two_party_votes_ republican_votes_ democratic_votes_ _merge

//change observations where governor is independent to missing
//independent elections include rhode island 2010, alaska 2014
//Alaska
replace dem_gov = . if state == "AK" & inrange(year, 2015, 2018)

//Rhode Island
replace dem_gov = . if state == "RI" & inrange(year, 2011, 2014)

//gen state id
encode state, gen(stateid)

//final data set saved as: "gubernatorial_final_data_set.dta"
save "gubernatorial_final_data_set.dta", replace

//remove working files
erase "pfi_categories_working.dta"
erase "pfi_working.dta"
erase "governor_elections_missing.dta"
erase "governor_elections_working.dta"
erase "governor_elections_previous.dta"
erase "governor_elections_2_years.dta"