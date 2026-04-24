program war_dummies

args war_type

gen `war_type' = 1

gen `war_type'_near = area == wherefought
replace `war_type'_near = 1 if wherefought == 11 & area == 2
replace `war_type'_near = 1 if wherefought == 11 & area == 6

replace `war_type'_near = 1 if wherefought == 12 & area == 2
replace `war_type'_near = 1 if wherefought == 12 & area == 7

replace `war_type'_near = 1 if wherefought == 13 & area == 1
replace `war_type'_near = 1 if wherefought == 13 & area == 7

replace `war_type'_near = 1 if wherefought == 14 & area == 2
replace `war_type'_near = 1 if wherefought == 14 & area == 4
replace `war_type'_near = 1 if wherefought == 14 & area == 6

replace `war_type'_near = 1 if wherefought == 15 & area == 2
replace `war_type'_near = 1 if wherefought == 15 & area == 4
replace `war_type'_near = 1 if wherefought == 15 & area == 6
replace `war_type'_near = 1 if wherefought == 15 & area == 7

replace `war_type'_near = 1 if wherefought == 16 & area == 4
replace `war_type'_near = 1 if wherefought == 16 & area == 6
replace `war_type'_near = 1 if wherefought == 16 & area == 7
replace `war_type'_near = 1 if wherefought == 16 & area == 9

replace `war_type'_near = 1 if wherefought == 17 & area == 7
replace `war_type'_near = 1 if wherefought == 17 & area == 9

replace `war_type'_near = 1 if wherefought == 18 & area == 4
replace `war_type'_near = 1 if wherefought == 18 & area == 6

replace `war_type'_near = 1 if wherefought == 19 & area == 2
replace `war_type'_near = 1 if wherefought == 19 & area == 4
replace `war_type'_near = 1 if wherefought == 19 & area == 6
replace `war_type'_near = 1 if wherefought == 19 & area == 7
replace `war_type'_near = 1 if wherefought == 19 & area == 9

gen `war_type'_far = area != wherefought

end
