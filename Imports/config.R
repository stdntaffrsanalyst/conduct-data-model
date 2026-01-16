# config.R
# Configuration file for student conduct data pipeline
# Contains all constants, mappings, and settings
# Author: Joshua L. Moermond
# Last Updated: 2026-01-13

# Academic Years ---------------------------------------------------------

ACADEMIC_YEARS <- c(
  "AY1920",
  "AY2021", 
  "AY2122",
  "AY2223",
  "AY2324",
  "AY2425",
  "AY2526"
)


# Date Ranges ------------------------------------------------------------

DATE_RANGE <- list(
  start = as.Date("2019-08-01"),
  end = as.Date("2027-07-31")
)


# File Paths -------------------------------------------------------------

PATHS <- list(
  export = "Exports/REDConduct_StarSchema.xlsx",
  pepper = "Imports/pepper.bin",
  imports = list(
    export1 = "Imports/maxientExport_082019_072021.csv",
    export2 = "Imports/maxientExport_082021_072024.csv",
    export3 = "Imports/maxientExport_082024_072027.csv",
    academic_plans = "Imports/academic_plans.csv",
    hearing_officers = "Imports/hearing_officers.csv",
    dim_housing = "Imports/DimHousing.csv",
    dim_housing_year = "Imports/DimHousingYear.csv",
    dim_sanction = "Imports/DimSanction.csv",
    housing_census = "Imports/housing_census.csv"
  )
)


# Residential Locations (RED) --------------------------------------------

RED_LOCATIONS <- c(
  "101 East Corry",
  "Bellevue Gardens", 
  "Calhoun Hall", 
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
  "The Comfort Inn", 
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
  "Verge" = "The Verge"
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
  "Harassment or Discrimination/Dating Violence" = 
    "Harassment or Discrimination",
  "Harassment or Discrimination/Sexual/gender-based Harassment" = 
    "Harassment or Discrimination",
  "Harassment or Discrimination/Sexual-gender based violence" = 
    "Harassment or Discrimination",
  "Harassment or Discrimination/Stalking" = 
    "Harassment or Discrimination",
  "Violation of federal, state, or local law" = 
    "Violation of Federal, State, or Local Law"
)


# Sanction Name Standardization ------------------------------------------

SANCTION_REPLACEMENTS <- c(
  "ABSENCE" = 
    "Absence",
  "ACDISMISS" = 
    "Academic Dismissal",
  "ACSUSP" = 
    "Academic Suspension",
  "ADDENDUM" = 
    "Addendum",
  "ADMS" = 
    "Alcohol Decision Making Seminar",
  "ADP" = 
    "Academic Probation",
  "ADR" = 
    "Academic Reprimand",
  "ALDRPAPER" = 
    "Alcohol and Drug Reflection Paper",
  "ANGERMGMT" = 
    "Anger Management Course",
  "APOLOGY" = 
    "Apology Letter",
  "ASEP" = 
    "Alcohol Skills Education Program",
  "ASSESSMENT" = 
    "Assessment with CAPS",
  "AUTOBIO_PAPER" = 
    "Substance Autobiography Paper",
  "BASICS" = 
    "Brief Alcohol Screening and Intervention for College Students",
  "BEHAVAGREE" = 
    "Behavioral Agreement",
  "BEHAVIORMOD" = 
    "Behavior Modification Course",
  "BULLETIN" = 
    "Bulletin Board",
  "BULLYING" = 
    "Bullying Course",
  "BYSTANDER" = 
    "Bystander Intervention Seminar",
  "CANNABISCRS" = 
    "The Cannabis Course",
  "CHNGDIR" = 
    "Director Change of Information",
  "CHNGPERCENT" = 
    "Reduced Grade for Course",
  "CLASSACCM" = 
    "Classroom Accommodations",
  "COMMUNITY_SERVICE" = 
    "Community Service",
  "CONSENT_WKSP" = 
    "Consent Workshop",
  "CONTACT_PAPER" = 
    "Contract Tracing Exercise and Reflection",
  "CPSRAPIDCONSULT" = 
    "CAPS Rapid Access Consultation",
  "DMS" = 
    "Decision Making Seminar",
  "DRUGALCAWARE" = 
    "Drug & Alcohol Awareness Course",
  "DSEP" = 
    "Drug Skills Education Program",
  "EDPROGP" = 
    "Plagiarism Module",
  "EDU_SIGN" = 
    "Educational Sign or Flier",
  "EMPIM" = 
    "Employment Interim Measure",
  "EXPULSION" = 
    "Dismissal",
  "FAIL" = 
    "Reduced Grade on Exam/Assignment",
  "FIRESAFEED" = 
    "Fire Safety Education",
  "GRADECHNG" = 
    "Failure in the Course",
  "HEALTHY_REL_WKSP" = 
    "Healthy Relationships Workshop",
  "HEALTH_PAPER" = 
    "Health Policy Video and Reaction Paper",
  "HMW" = 
    "Healthy Masculinity Workshop",
  "INTERIMSUSP" = 
    "Interim Suspension",
  "LACROOM" = 
    "Lactation Room Access",
  "LIFESKILLS" = 
    "Life Skills Course",
  "LOSSPRIV" = 
    "Loss of Privileges",
  "MISSASGN" = 
    "Missed Assignment",
  "MOVETOHSNG" = 
    "Move into Housing with Financial Assistance",
  "MOVETOHSNG_NOASST" = 
    "Move into Housing without Financial Assistance",
  "NCO_OEO" = 
    "Mutual No-Contact Order (OEO)",
  "NGHTRIDE" = 
    "NightRide Priority Ride",
  "NOCONTACT" = 
    "No-Contact Directive",
  "ORG_RESTORE" = 
    "Student Organization Restorative Action Plan",
  "PACE" = 
    "PACE Workshop",
  "PARENTNOTIFY" = 
    "Parent/Guardian Notification",
  "PARKING" = 
    "Parking with Financial Assistance",
  "PARKING_NOASST" = 
    "Parking without Financial Assistance",
  "PFL" = 
    "Substance Abuse Education for Alcohol",
  "PFLDRUG" = 
    "Drug Sanction Course",
  "REDEXPUL" = 
    "Housing Termination and Permanent Loss of Privileges",
  "REDSUSP" = 
    "Housing Termination and Temporary Loss of Privileges",
  "REDTRANSFER" = 
    "Housing Assignment Relocation",
  "REFERRAL" = 
    "Referral",
  "REFLECTCONT" = 
    "Reflection Paper",
  "REFLECTOPEN" = 
    "Reflection Paper - Open-Ended",
  "REFLECTPAP" = 
    "Reflection Paper - Preparation",
  "REFLECTPRE" = 
    "Reflection Paper - Pre-Contemplation",
  "REFLGTUL" = 
    "GUL Reflection",
  "REFMEET" = 
    "Reflection Meeting",
  "REFUNDAPP" = 
    "Tuition Refund Application",
  "REGREIMBRSE" = 
    "Registrar Grade Removal with Reimbursement",
  "RELOCATION" = 
    "Housing Relocation",
  "REPRIMAND" = 
    "Reprimand",
  "RESTITUTION" = 
    "Restitution",
  "RESTRICTION" = 
    "Ban From Location",
  "RESUBASSIGN" = 
    "Retest/Re-Submission of the Assignment/Exam",
  "RP_PASSIVE" = 
    "Reflection Paper - Passive Participation",
  "SCHLLTR" = 
    "Scholarship Letter",
  "SECURITYASST" = 
    "Security Assistance",
  "SOBEREXP" = 
    "Sober Experience Calendar",
  "TAIALCOHOL" = 
    "Think About It: Alcohol",
  "TAIDRUGS" = 
    "Think About It: Drugs",
  "TEDTALK" = 
    "TED Talk Reflection",
  "TERMINATION" = 
    "Housing Removal",
  "THEFTAWARE" = 
    "Theft Awareness Course",
  "TOBACCO" = 
    "Tobacco Awareness Course",
  "VAPING" = 
    "Vaping Awareness Course",
  "DEFSUSHP" = 
    "Deferred Suspension of Housing Privileges",
  "DP" = 
    "Disciplinary Probation",
  "SUSPENSION" = 
    "Suspension",
  "ADDITIONAL" = 
    "Additional Sanctions or Stipulations"
)


# College Abbreviations --------------------------------------------------

COLLEGE_REPLACEMENTS <- c(
  'Colege of Dsn, Arch, Art & Pln' = 'DAAP',
  'Lindner College of Business' = 'LCOB',
  'Col of Arts & Science' = 'CAS',
  'College of Ed, CJ, & HS' = 'CECH',
  'Blue Ash College' = 'UCBA',
  'College of Nursing' = 'CON',
  'College of Eng & Appl Sci' = 'CEAS',
  'University of Cincinnati' = 'UC',
  'Clermont College' = 'UCCC',
  'College of Allied Health Sci' = 'CAHS',
  'College of Medicine' = 'COM',
  'College Conservatory of Music' = 'CCM',
  'UC International Pathways' = 'UCIP',
  'Adult Learning Center' = 'ALC',
  'James L. Winkle Coll of Pharm' = 'COP'
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
