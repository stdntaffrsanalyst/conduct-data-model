# config.R
# Configuration file for student conduct data pipeline
# Contains all constants, mappings, and settings
# Author: Joshua L. Moermond
# Last Updated: 2026-03-30

# Academic Years ---------------------------------------------------------

ACADEMIC_YEARS <- c(
  "AY1920",
  "AY2021",
  "AY2122",
  "AY2223",
  "AY2324",
  "AY2425",
  "AY2526",
  "AY2627"
)

# Date Ranges ------------------------------------------------------------

DATE_RANGE <- list(
  start = as.Date("2019-08-01"),
  end = as.Date("2027-07-31")
)

# File Paths -------------------------------------------------------------

PATHS <- list(
  export_local = "~/GitHub/conduct-analytics/analyses/conduct-data-model/exports/REDConduct_StarSchema.xlsx",
  export_onedrive = "C:/Users/moermojl/OneDrive - University of Cincinnati/data-models/REDConduct_StarSchema.xlsx",
  pepper = "C:/Users/moermojl/conduct-secrets/pepper.bin",
  imports = list(
    import1 = "~/GitHub/conduct-analytics/data-raw/maxientExport_082019_072021.csv",
    import2 = "~/GitHub/conduct-analytics/data-raw/maxientExport_082021_072024.csv",
    import3 = "~/GitHub/conduct-analytics/data-raw/maxientExport_082024_072027.csv",
    academic_plans = "~/GitHub/conduct-analytics/shared/lookup/DimAcademicPlans.csv",
    hearing_officers = "~/GitHub/conduct-analytics/shared/lookup/hearing_officers.csv",
    dim_housing = "~/GitHub/conduct-analytics/shared/lookup/DimHousing.csv",
    dim_housing_year = "~/GitHub/conduct-analytics/shared/lookup/DimHousingYear.csv",
    dim_sanction = "~/GitHub/conduct-analytics/shared/lookup/DimSanction.csv",
    housing_census = "~/GitHub/conduct-analytics/shared/lookup/housing_census.csv",
    dim_charge = "~/GitHub/conduct-analytics/shared/lookup/DimCharge.csv",
    dim_college = "~/GitHub/conduct-analytics/shared/lookup/DimCollege.csv"
  )
)

# Residential Locations (RED) --------------------------------------------

RED_LOCATIONS <- c(
  "101 East Corry",
  "Bellevue Gardens",
  "Calhoun Hall",
  "Comfort Inn",
  "CP Cincy",
  "CRC Hall",
  "Dabney Hall",
  "Daniels Hall",
  "Fairfield Inn",
  "Gateway Lofts",
  "Hampton Inn",
  "Jefferson House",
  "Marian Spencer Hall",
  "Morgens Hall",
  "Schneider Hall",
  "Scioto Hall",
  "Senator Place",
  "Siddall Hall",
  "Stetson Square",
  "Stratford Heights",
  "The Deacon",
  "The Eden",
  "The Graduate",
  "The Union",
  "Turner Hall",
  "University Edge",
  "University Park Apartments",
  "USquare",
  "The Verge"
)

# Location Name Mappings -------------------------------------------------

LOCATION_MAP <- c(
  "101 Corry" = "101 East Corry",
  "Campus Park Apartments" = "CP Cincy",
  "Campus Rec Cen Residence Hall" = "CRC Hall",
  "Cp Cincy" = "CP Cincy",
  "Crc Hall" = "CRC Hall",
  "Deacon" = "The Deacon",
  "Fairfield Inn &Amp; Suites" = "Fairfield Inn",
  "Graduate Hotel" = "The Graduate",
  "Hampton Inn &Amp; Suites Cincinnati/Uptown University" = "Hampton Inn",
  "Hampton Inn &Amp; Suites" = "Hampton Inn",
  "Stratford Heights Bld 1" = "Stratford Heights",
  "Stratford Heights Bld 4" = "Stratford Heights",
  "Stratford Heights Bldg 5" = "Stratford Heights",
  "Stratford Heights Bldg 9" = "Stratford Heights",
  "Stratford Hts Bld 10" = "Stratford Heights",
  "Stratford Hts Bld 12 Tower Hall" = "Stratford Heights",
  "Stratford Hts Bld 2" = "Stratford Heights",
  "Stratford Hts Bld 3" = "Stratford Heights",
  "The Deacon Apartments" = "The Deacon",
  "The Eden Apartments" = "The Eden",
  "The Graduate Cincinnati" = "The Graduate",
  "University Park Apts" = "University Park Apartments",
  "University Park Apts South" = "University Park Apartments",
  "University Park Apts. (Calhoun)" = "University Park Apartments",
  "Usquare" = "USquare",
  "Verge" = "The Verge",
  "The Comfort Inn" = "Comfort Inn",
  "MainStay Suites" = "Comfort Inn",
  "All City Streets (Off Campus)" = "Off-Campus",
  "Allied Health Sciences" = "Academic Classroom Or Building",
  "Arts And Sciences" = "Academic Classroom Or Building",
  "Backstage Dr @ Corbett Dr" = "On-Campus",
  "Bookstore Tuc" = "Tangeman University Center",
  "Calhoun St Garage" = "Calhoun Garage",
  "Clermont College" = "UC Clermont College",
  "College Conservatory Of Music" = "Academic Classroom Or Building",
  "Corry Blvd @ Jefferson Ave" = "Off-Campus",
  "Delta Tau Delta" = "Student Organization",
  "Design, Architecture, Art, And Planning" = "Academic Classroom Or Building",
  "Education, Criminal Justice, And Human Services" = "Academic Classroom Or Building",
  "Edwards Four" = "Edwards Center",
  "Engineering &Amp; Applied Science" = "Academic Classroom Or Building",
  "Fifth Third Arena/Shoemaker Center" = "Shoemaker Center",
  "Kappa Delta" = "Student Organization",
  "Law" = "Academic Classroom Or Building",
  "Lindner College Of Business" = "Academic Classroom Or Building",
  "Medicine" = "Academic Classroom Or Building",
  "N/A" = "Not Reported",
  "Not Listed" = "Not Reported",
  "Nursing" = "Academic Classroom Or Building",
  "Off Campus" = "Off-Campus",
  "Other (Specify Below)" = "Other",
  "Pharmacy" = "Academic Classroom Or Building",
  "Rotc" = "Student Organization",
  "Sigma Alpha Epsilon" = "Student Organization",
  "Theta Phi Alpha" = "Student Organization",
  "Tuc" = "Tangeman University Center",
  "U Square" = "USquare",
  "Uc Blue Ash College" = "UC Blue Ash College",
  "Uc Clermont" = "UC Clermont College",
  "Uc Clermont College" = "UC Clermont College",
  "Uc Main Campus" = "On-Campus",
  "Uptown West Campus" = "On-Campus"
)

# Violation Name Standardization -----------------------------------------

VIOLATION_REPLACEMENTS <- c(
  "Academic Misconduct - Aiding &amp; Abetting" =
    "Academic Misconduct - Aiding and Abetting",
  "Academic Misconduct - Violating Ethical or Professional Standards" =
    "Academic Misconduct - Violating Standards",
  "Aiding &amp; Abetting" =
    "Aiding and Abetting",
  "Alcohol - Underage possession" =
    "Alcohol",
  "Alcohol - Public Intoxication" =
    "Alcohol",
  "Dishonesty &amp; Misrepresentation" =
    "Dishonesty and Misrepresentation",
  "Drugs or Narcotics - Paraphernalia" =
    "Drugs or Narcotics",
  "Drugs or Narcotics - Possession/ Use" =
    "Drugs or Narcotics",
  "Drugs or Narcotics - Distribution" =
    "Drugs or Narcotics",
  "Drugs or Narcotics - Unauthorized prescription" =
    "Drugs or Narcotics",
  "Physical Abuse or Harm, or Threat of Physical Abuse or Harm" =
    "Physical Abuse or Harm (or Threat)",
  "Residence Hall Rules &amp; Regulations - Appliances and Electric Cords" =
    "GUL - Appliances and Electric Cords",
  "Residence Hall Rules &amp; Regulations - Commercial &amp; Business Activity" =
    "GUL - Commercial and Business Activity",
  "Residence Hall Rules &amp; Regulations - Dining Centers" =
    "GUL - Dining Centers",
  "Residence Hall Rules &amp; Regulations - Elevators, Hallways &amp; Restricted Areas" =
    "GUL - Elevators, Hallways, and Restricted Areas",
  "Residence Hall Rules &amp; Regulations - Fire Safety" =
    "GUL - Fire Safety",
  "Residence Hall Rules &amp; Regulations - Furniture" =
    "GUL - Furniture",
  "Residence Hall Rules &amp; Regulations - Gambling" =
    "GUL - Gambling",
  "Residence Hall Rules &amp; Regulations - Guests" =
    "GUL - Guests",
  "Residence Hall Rules &amp; Regulations - Health &amp; Safety" =
    "GUL - Health and Safety",
  "Residence Hall Rules &amp; Regulations - Keys &amp; Access" =
    "GUL - Keys and Access",
  "Residence Hall Rules &amp; Regulations - Mail" =
    "GUL - Mail",
  "Residence Hall Rules &amp; Regulations - Pets, Service Animals, &amp; Assistance Animals" =
    "GUL - Pets, Service Animals, and Assistance Animals",
  "Residence Hall Rules &amp; Regulations - Quiet Hours &amp; Noise" =
    "GUL - Noise",
  "Residence Hall Rules &amp; Regulations - Recording Devices" =
    "GUL - Recording Devices",
  "Residence Hall Rules &amp; Regulations - Restrooms" =
    "GUL - Restrooms",
  "Residence Hall Rules &amp; Regulations - Sign Posting" =
    "GUL - Sign Posting",
  "Residence Hall Rules &amp; Regulations - Tobacco-Free Policy" =
    "GUL - Tobacco-Free Policy",
  "Residence Hall Rules &amp; Regulations - Weapons &amp; Fireworks" =
    "GUL - Weapons and Fireworks",
  "Residence Hall Rules &amp; Regulations - Water Fights &amp; Games" =
    "GUL - Water Fights and Games",
  "Residence Hall Rules &amp; Regulations - Windows" = "GUL - Windows and Exits",
  "Residence Hall Rules &amp; Regulations - Windows &amp; Exits" =
    "GUL - Windows and Exits",
  "Unauthorized use of university key" =
    "Unauthorized Use of University Key",
  "University policies or rules" =
    "University Policies or Rules",
  "University policies or rules â€“ COVID-19 Safety Measures and Protocols" =
    "COVID-19 Safety",
  "University policies or rules – COVID-19 Safety Measures and Protocols" =
    "COVID-19 Safety",
  "University policies or rules \x96 COVID-19 Safety Measures and Protocols" =
    "COVID-19 Safety",
  "Harassment or Discrimination/Dating Violence" =
    "Harassment or Discrimination",
  "Harassment or Discrimination/Sexual/gender-based Harassment" =
    "Harassment or Discrimination",
  "Harassment or Discrimination/Sexual-gender based violence" =
    "Harassment or Discrimination",
  "Harassment or Discrimination/Stalking" =
    "Harassment or Discrimination",
  "Violation of federal, state, or local law" =
    "Violation of Federal, State, or Local Law",
  "Tobacco and Smoke Free Environment Policy" =
    "Tobacco and Smoking"
)

# Issue Name Standardization (BIT/CARE Pipeline) -------------------------
# Used by the behavioral intervention pipeline, not the conduct data model.
# Retained here because config.R is shared across both pipelines.
# "Issues" in Maxient are functionally the same field as charges but reflect
# case management language rather than conduct charging language. Some care
# cases also contain conduct charges entered in error; this map corrects them.

ISSUE_REPLACEMENTS <- c(
  "Alcohol" = "Substance Use Concern (Alcohol)",
  "Alcohol - Underage possession" = "Substance Use Concern (Alcohol)",
  "General Concern - Referred to Title 9" = "Harassment or Discrimination",
  "General Concern DoS Attention" = "General Concern",
  "General Concern-Family/Friends" = "General Concern",
  "Harassment or Discrimination/Stalking" = "Harassment or Discrimination",
  "Hazing (Reporter or Victim)" = "Hazing",
  "Injury, Illness, or Medical" = "Injury or Illness",
  "Mood Swings" = "Concerning Mood Regulation",
  "Potential Harassment or Discrimination" = "Harassment or Discrimination",
  "Strange classroom behavior" = "Unusual Behavior",
  "Physical Abuse or Harm, or Threat of Physical Abuse or Harm" = "Harm (to Others or Self)",
  "Gender-Based Harassment or Violence" = "Harassment or Discrimination",
  "Random or Sudden Outbursts of Emotion" = "Concerning Mood Regulation",
  "Sudden Change in Classroom Performance" = "Academic Challenges",
  "Financial Hardship" = "Financial Insecurity"
)

# Academic Calendar Pause Periods ----------------------------------------
# Breaks, holidays, and other periods to exclude from timeline calculations

OMIT_RANGES <- list(
  # AY1718
  c("2017-08-06", "2017-08-20"), # summer to fall transition
  c("2017-09-04", "2017-09-04"), # labor day
  c("2017-11-10", "2017-11-10"), # veterans day
  c("2017-11-22", "2017-11-26"), # thanksgiving holiday
  c("2017-12-10", "2018-01-07"), # semester break
  c("2018-01-15", "2018-01-15"), # MLK Day
  c("2018-03-12", "2018-03-16"), # spring break
  c("2018-04-27", "2018-05-06"), # spring to summer transition
  c("2018-05-28", "2018-05-28"), # memorial day
  c("2018-07-04", "2018-07-04"), # independence day

  # AY1819
  c("2018-08-06", "2018-08-26"), # summer to fall transition
  c("2018-09-04", "2018-09-04"), # labor day
  c("2018-10-11", "2018-10-12"), # reading days
  c("2018-11-12", "2018-11-12"), # veterans day
  c("2018-11-22", "2018-11-25"), # thanksgiving holiday
  c("2018-12-10", "2019-01-13"), # semester break
  c("2019-01-21", "2019-01-21"), # MLK Day
  c("2019-03-18", "2019-03-24"), # spring break
  c("2019-04-27", "2019-05-12"), # spring to summer transition
  c("2019-05-27", "2019-05-27"), # memorial day
  c("2019-07-04", "2019-07-04"), # independence day

  # AY1920
  c("2019-08-11", "2019-08-25"), # summer to fall transition
  c("2019-09-02", "2019-09-02"), # labor day
  c("2019-10-10", "2019-10-11"), # reading days
  c("2019-11-11", "2019-11-11"), # veterans day
  c("2019-11-28", "2019-12-01"), # thanksgiving holiday
  c("2019-12-09", "2020-01-12"), # semester break
  c("2020-01-20", "2020-01-20"), # MLK Day
  c("2020-03-16", "2020-03-25"), # spring break
  c("2020-04-26", "2020-05-10"), # spring to summer transition
  c("2020-05-25", "2020-05-25"), # memorial day
  c("2020-07-03", "2020-07-03"), # independence day

  # AY2021
  c("2020-08-09", "2020-08-23"), # summer to fall transition
  c("2020-09-07", "2020-09-07"), # labor day
  c("2020-11-11", "2020-11-11"), # veterans day
  c("2020-11-26", "2020-11-29"), # thanksgiving
  c("2020-12-03", "2021-01-10"), # semester break
  c("2021-01-18", "2021-01-18"), # MLK Day
  c("2021-04-24", "2021-05-09"), # spring to summer transition
  c("2021-05-31", "2021-05-31"), # memorial day
  c("2021-07-05", "2021-07-05"), # independence day

  # AY2122
  c("2021-08-10", "2021-08-22"), # summer to fall transition
  c("2021-09-06", "2021-09-06"), # labor day
  c("2021-10-11", "2021-10-12"), # reading days
  c("2021-11-11", "2021-11-11"), # veterans day
  c("2021-11-25", "2021-11-28"), # thanksgiving holiday
  c("2021-12-05", "2022-01-09"), # semester break
  c("2022-01-17", "2022-01-17"), # MLK Day
  c("2022-03-14", "2022-03-20"), # spring break
  c("2022-04-22", "2022-05-08"), # spring to summer transition
  c("2022-05-30", "2022-05-30"), # memorial day
  c("2022-06-20", "2022-06-20"), # juneteenth
  c("2022-07-04", "2022-07-04"), # independence day

  # AY2223
  c("2022-08-07", "2022-08-21"), # summer to fall transition
  c("2022-09-05", "2022-09-05"), # labor day
  c("2022-10-10", "2022-10-10"), # reading day
  c("2022-11-08", "2022-11-08"), # reading day
  c("2022-11-11", "2022-11-11"), # veterans day
  c("2022-11-24", "2022-11-27"), # thanksgiving holiday
  c("2022-12-04", "2023-01-08"), # semester break
  c("2023-01-16", "2023-01-16"), # MLK Day
  c("2023-03-13", "2023-03-19"), # spring break
  c("2023-04-22", "2023-05-07"), # spring to summer transition
  c("2023-05-29", "2023-05-29"), # memorial day
  c("2023-06-19", "2023-06-19"), # juneteenth
  c("2023-07-04", "2023-07-04"), # independence day

  # AY2324
  c("2023-08-06", "2023-08-20"), # summer to fall transition
  c("2023-09-04", "2023-09-04"), # labor day
  c("2023-10-09", "2023-10-09"), # reading day
  c("2023-11-07", "2023-11-07"), # reading day
  c("2023-11-10", "2023-11-10"), # veterans day
  c("2023-11-23", "2023-11-26"), # thanksgiving holiday
  c("2023-12-03", "2024-01-07"), # semester break
  c("2024-01-15", "2024-01-15"), # MLK Day
  c("2024-03-11", "2024-03-17"), # spring break
  c("2024-04-20", "2024-05-05"), # spring to summer transition
  c("2024-05-27", "2024-05-27"), # memorial day
  c("2024-06-19", "2024-06-19"), # juneteenth
  c("2024-07-04", "2024-07-04"), # independence day

  # AY2425
  c("2024-08-04", "2024-08-25"), # summer to fall transition
  c("2024-09-02", "2024-09-02"), # labor day
  c("2024-10-11", "2024-10-11"), # reading day
  c("2024-11-05", "2024-11-05"), # reading day
  c("2024-11-11", "2024-11-11"), # veterans day
  c("2024-11-28", "2024-12-01"), # thanksgiving holiday
  c("2024-12-08", "2025-01-12"), # semester break
  c("2025-01-20", "2025-01-20"), # MLK Day
  c("2025-01-13", "2025-02-14"), # Datafeed error schedules
  c("2025-03-17", "2025-03-23"), # spring break
  c("2025-04-26", "2025-05-11"), # spring to summer transition
  c("2025-05-26", "2025-05-26"), # memorial day
  c("2025-06-19", "2025-06-19"), # juneteenth
  c("2025-07-04", "2025-07-04"), # independence day

  # AY2526
  c("2025-08-10", "2025-08-24"), # summer to fall transition
  c("2025-09-01", "2025-09-01"), # labor day
  c("2025-10-09", "2025-10-10"), # reading day
  c("2025-11-11", "2025-11-11"), # veterans day
  c("2025-11-26", "2025-11-28"), # thanksgiving holiday
  c("2025-12-06", "2026-01-11"), # semester break
  c("2026-01-19", "2026-01-19"), # MLK Day
  c("2026-03-16", "2026-03-20"), # spring break
  c("2026-05-01", "2026-05-10"), # spring to summer transition
  c("2026-05-25", "2026-05-25"), # memorial day
  c("2026-06-19", "2026-06-19"), # juneteenth
  c("2026-07-03", "2026-07-03")  # independence day
)
