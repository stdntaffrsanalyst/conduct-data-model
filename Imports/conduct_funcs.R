# conduct_funcs.R
# Custom functions for student conduct data pipeline
# Author: Joshua L. Moermond
# Last Updated: 2026-01-13

# Load required packages for function operations
library(dplyr)
library(tidyr)
library(lubridate)
library(stringr)
library(purrr)

# Utility Functions ------------------------------------------------------

#' Display schema of a data frame
#' @param df Data frame to describe
#' @param show_example Logical; whether to show example values
#' @param max_example_length Maximum characters for example values
#' @return Data frame describing the schema
#' @export
df_schema <- function(df, show_example = TRUE, max_example_length = 60) {
  schema <- tibble(
    column = names(df),
    type = map_chr(df, ~ paste(class(.x), collapse = ", ")),
    non_na_count = map_int(df, ~ sum(!is.na(.x))),
    na_count = map_int(df, ~ sum(is.na(.x))),
    na_percent = round((na_count / nrow(df)) * 100, 1)
  )

  if (show_example) {
    schema <- schema |>
      mutate(
        example = map_chr(df, function(col) {
          val <- col[!is.na(col)][1]
          # Handle empty columns OR NA result
          if (length(val) == 0 || is.na(val)) {
            return(NA_character_)
          }
          ex <- as.character(val)
          if (nchar(ex) > max_example_length) {
            paste0(substr(ex, 1, max_example_length - 3), "...")
          } else {
            ex
          }
        })
      )
  }

  schema
}

#' Validate required columns exist in dataframe
#' @param df Data frame to validate
#' @param required_cols Character vector of required column names
#' @param df_name Name of dataframe for error messages
#' @return Invisibly returns TRUE if valid, stops with error if not
#' @export
validate_columns <- function(df, required_cols, df_name = "dataframe") {
  missing <- setdiff(required_cols, names(df))

  if (length(missing) > 0) {
    stop(
      "Required columns missing from ", df_name, ":\n  ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

#' Execute a function with progress reporting
#' @param desc Description of the operation
#' @param expr Expression to evaluate
#' @return Result of the expression
#' @export
with_progress <- function(desc, expr) {
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_progress_step(desc)
    result <- force(expr)
    cli::cli_progress_done()
    result
  } else {
    message(desc, "...")
    force(expr)
  }
}

#' Negate %in% operator
#' @export
`%nin%` <- Negate(`%in%`)

#' Fix non-breaking spaces in character vectors
#' @param x Character vector to clean
#' @return Character vector with non-breaking spaces replaced by
#'   regular spaces and repeated whitespace collapsed
#' @export
fix_nbsp <- function(x) {
  x <- as.character(x)
  x <- gsub("\u00A0", " ", x, fixed = TRUE)
  x <- gsub("[[:space:]]+", " ", x)
  trimws(x)
}

#' Count values in a vector and return a frequency table
#'
#' Creates a tibble of unique values and their counts, sorted in descending
#' order of frequency. Primarily intended for categorical or discrete variables.
#'
#' @param x A vector to count
#' @param digits Integer; number of decimal places for the percent column.
#'   Default is 1.
#' @return A tibble with three columns:
#' \describe{
#'   \item{<column_name>}{The unique values from `x`.}
#'   \item{n}{The count of each unique value.}
#'   \item{pct}{The percentage of the total each value represents,
#'     rounded to `digits` decimal places.}
#' }
#'
#' @details
#' This function is useful for quickly generating one-way frequency tables
#' while preserving a clean output column name.
#'
#' If `x` is passed as `df$COLUMN`, the function detects the `$` call and
#' extracts only `COLUMN` for the output tibble.
#'
#' NA values are included in counts but excluded from the percent denominator,
#' meaning percentages reflect the share of non-missing values.
#'
#' @examples
#' count_values(mtcars$cyl)
#'
#' @export
count_values <- function(x, digits = 1) {
  expr <- substitute(x)
  col_name <- if (is.call(expr) && identical(expr[[1]], as.name("$"))) {
    as.character(expr[[3]])
  } else {
    deparse(expr)
  }
  tibble::tibble(!!col_name := x) |>
    dplyr::count(!!rlang::sym(col_name), sort = TRUE) |>
    dplyr::mutate(pct = round(n / sum(n) * 100, digits))
}

# Date and Time Functions ------------------------------------------------

#' Convert columns to Date format
#' @param df Data frame
#' @param columns Character vector of column names
#' @return Data frame with converted date columns
#' @export
convert_to_date <- function(df, columns) {
  # Validate columns exist
  missing_cols <- setdiff(columns, names(df))
  if (length(missing_cols) > 0) {
    warning("Columns not found: ", paste(missing_cols, collapse = ", "))
    columns <- intersect(columns, names(df))
  }

  df |>
    mutate(across(
      all_of(columns),
      ~ {
        if (inherits(.x, "Date")) {
          .x  # Already a date, return as-is
        } else {
          # Try multiple date formats
          as_date(parse_date_time(.x, orders = c("ymd", "mdy", "dmy"),
                                  quiet = TRUE))
        }
      }
    ))
}

#' Calculate academic year from a date
#' @param date Date vector
#' @return Character vector of academic years (e.g., "AY2324")
#' @export
#' @examples
#' compute_academic_year(as.Date("2023-09-15"))  # Returns "AY2324"
#' compute_academic_year(as.Date("2024-05-10"))  # Returns "AY2324"
compute_academic_year <- function(date) {
  year_num <- year(date)
  month_num <- month(date)

  # Academic year starts in August
  # Aug-Dec: current calendar year is AY start
  # Jan-Jul: previous calendar year is AY start
  ay_start_year <- if_else(month_num >= 8, year_num, year_num - 1)

  paste0(
    "AY",
    substr(ay_start_year, 3, 4),
    substr(ay_start_year + 1, 3, 4)
  )
}

#' Compute overlap days between date ranges and omit periods
#' @param start_dates Vector of start dates
#' @param end_dates Vector of end dates
#' @param resolution Vector of resolution types
#' @param omit_ranges List of date range pairs to exclude
#' @return Numeric vector of overlap days
#' @export
compute_overlaps <- function(start_dates, end_dates, resolution,
                             omit_ranges) {
  # Validate inputs
  n <- length(start_dates)
  if (length(end_dates) != n || length(resolution) != n) {
    stop("start_dates, end_dates, and resolution must have same length")
  }

  # Create data frame
  date_df <- tibble(
    start = ymd(start_dates),
    end = ymd(end_dates),
    resolution = resolution,
    adjustment = 0
  )

  # Only adjust non-"Warning Letter" cases
  adjust_mask <- date_df$resolution != "Warning Letter"

  # Calculate overlaps for each omit range
  for (omit_range in omit_ranges) {
    omit_start <- ymd(omit_range[1])
    omit_end <- ymd(omit_range[2])

    # Calculate overlap only where needed
    overlap_start <- pmax(date_df$start[adjust_mask], omit_start,
                          na.rm = TRUE)
    overlap_end <- pmin(date_df$end[adjust_mask], omit_end,
                        na.rm = TRUE)

    # Days of overlap (inclusive, so +1)
    overlap_days <- pmax(0, as.numeric(overlap_end - overlap_start) + 1)

    # Accumulate adjustments
    date_df$adjustment[adjust_mask] <-
      date_df$adjustment[adjust_mask] + overlap_days
  }

  date_df$adjustment
}

#' Build a Power BI-ready date dimension table
#'
#' Generates a complete date spine from start to end date with standard
#' calendar fields, academic year and semester classifications, sort keys,
#' and term identifiers for use as DimDate in the star schema.
#'
#' Academic year follows an Aug 1 – Jul 31 boundary. Semesters are
#' classified as FA (Aug–Dec), SP (Jan–Apr), or SU (May–Jul).
#'
#' @param start_date Start date of the date spine (Date or coercible string)
#' @param end_date End date of the date spine (Date or coercible string)
#' @return A tibble with one row per calendar date containing calendar
#'   fields, academic time fields, and sort keys
#' @export
#' @examples
#' build_dim_date(as.Date("2017-08-01"), as.Date("2026-07-31"))
#' build_dim_date(DATE_RANGE$start, DATE_RANGE$end)
build_dim_date <- function(start_date, end_date) {

  start_date <- as.Date(start_date)
  end_date   <- as.Date(end_date)

  if (start_date > end_date) {
    stop("start_date must be before end_date", call. = FALSE)
  }

  tibble(
    Date = seq.Date(start_date, end_date, by = "day")
  ) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Standard calendar fields
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      Year         = year(Date),
      Month        = month(Date),
      `Month Name` = month(Date, label = TRUE, abbr = FALSE),
      Day          = day(Date),
      `ISO Week`   = isoweek(Date),
      Weekday      = wday(Date, label = TRUE, abbr = FALSE)
    ) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Academic year (Aug 1 – Jul 31)
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      `Academic Year` = if_else(
        Date >= make_date(year(Date), 8, 1),
        paste0("AY", year(Date) - 2000, year(Date) - 1999),
        paste0("AY", year(Date) - 2001, year(Date) - 2000)
      )
    ) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Sort key for academic year ordering in visuals
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      AY_Order = as.integer(substr(`Academic Year`, 3, 6))
    ) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Semester classification
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      Semester = case_when(
        Month >= 8 & Month <= 12 ~ "FA",
        Month >= 1 & Month <= 4  ~ "SP",
        TRUE                     ~ "SU"
      )
    ) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Academic term key for correct term sorting
    # Format: [2-digit AY start] * 10 + [term number]
    # Example: AY2324 Fall = 23 * 10 + 1 = 231
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      AcademicTermKey = case_when(
        Semester == "FA" ~ as.integer(
          substr(`Academic Year`, 3, 4)) * 10 + 1L,
        Semester == "SP" ~ as.integer(
          substr(`Academic Year`, 3, 4)) * 10 + 2L,
        Semester == "SU" ~ as.integer(
          substr(`Academic Year`, 3, 4)) * 10 + 3L,
        TRUE             ~ NA_integer_
      )
    ) |>
    arrange(Date) |>

    # ─────────────────────────────────────────────────────────────────────────
    # Sort helpers for visual ordering
    # ─────────────────────────────────────────────────────────────────────────
    mutate(
      Month_Sort = case_when(
        Month == 8  ~ 1L,  Month == 9  ~ 2L,  Month == 10 ~ 3L,
        Month == 11 ~ 4L,  Month == 12 ~ 5L,  Month == 1  ~ 6L,
        Month == 2  ~ 7L,  Month == 3  ~ 8L,  Month == 4  ~ 9L,
        Month == 5  ~ 10L, Month == 6  ~ 11L, Month == 7  ~ 12L
      ),
      Weekday_Sort = wday(Date, week_start = 7)  # Sunday = 1
    )
}


# Data Cleaning Functions ------------------------------------------------

#' Replace charges using vectorized operations
#' @param df Data frame
#' @param charge_cols Character vector of column names to process
#' @param replacements Named list of replacements
#' @return Data frame with replaced values
#' @export
replace_charges <- function(df, charge_cols, replacements) {
  # Validate inputs
  missing_cols <- setdiff(charge_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("Columns not found in dataframe: ",
         paste(missing_cols, collapse = ", "))
  }

  # Vectorized replacement using case_match
  df |>
    mutate(across(
      all_of(charge_cols),
      ~ case_match(
        .x,
        !!!replacements,
        .default = .x
      )
    ))
}

#' Replace NA values with empty strings
#' @param df Data frame
#' @param columns Character vector of column names
#' @return Data frame with NA values replaced
#' @export
replace_na_empty <- function(df, columns) {
  df |>
    mutate(across(
      all_of(columns),
      ~ if_else(is.na(.x), "", as.character(.x))
    ))
}


# Anonymization Functions ------------------------------------------------

#' Vectorized anonymization function using HMAC
#' @param x Vector to hash
#' @param key Encryption key (raw vector)
#' @param n_hex Number of hex characters to return
#' @return Character vector of hashed values
#' @export
hash_col <- function(x, key, algo = "sha256", n_hex = 32) {
  vapply(x, function(val) {
    if (is.na(val)) return(NA_character_)
    h <- openssl::sha256(as.character(val), key = key)
    if (!is.null(n_hex)) substr(h, 1, n_hex) else h
  }, character(1), USE.NAMES = FALSE)
}

# Analysis Functions -----------------------------------------------------

#' Calculate recidivism rates with optional grouping
#' @param df Data frame containing conduct records
#' @param academic_years Character vector of academic years
#' @param group_by Character vector of grouping variables (e.g., "College")
#' @param format Output format: "display" (with %) or "pbi" (numeric Rate)
#' @return Data frame with recidivism metrics
#' @export
calculate_recidivism <- function(df,
                                 academic_years,
                                 group_by = NULL,
                                 format = c("display", "pbi")) {
  format <- match.arg(format)

  # Get FINDING columns
  finding_vars <- grep("^FINDING_", names(df), value = TRUE)
  if (length(finding_vars) == 0) {
    stop("No FINDING_* columns found in dataframe")
  }

  # Validate required columns
  validate_columns(df, c("ROLE", "SID", "FILE_ID", "INCIDENT_DATE"),
                   "conduct data")

  # If no ACADEMIC_YEAR column, compute it
  if (!"ACADEMIC_YEAR" %in% names(df)) {
    df <- df |> mutate(ACADEMIC_YEAR =
                         compute_academic_year(INCIDENT_DATE))
  }

  # Standardize grouping columns
  if (!is.null(group_by)) {
    df <- df |>
      mutate(across(all_of(group_by),
                    ~ replace_na(as.character(.x), "Not Reported")))
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 1: Identify FILE_IDs with at least one responsible finding
  # ─────────────────────────────────────────────────────────────────────────
  cases_with_responsible <- df |>
    filter(
      ACADEMIC_YEAR %in% academic_years,
      ROLE == "Respondent"
    ) |>
    mutate(
      has_responsible = if_any(
        all_of(finding_vars),
        ~ tolower(trimws(as.character(.x))) == "responsible"
      )
    ) |>
    filter(has_responsible) |>
    # Get one row per case per student, with earliest incident date
    group_by(ACADEMIC_YEAR, SID, FILE_ID) |>
    summarise(
      INCIDENT_DATE = min(INCIDENT_DATE, na.rm = TRUE),
      .groups = "drop"
    )

  # ─────────────────────────────────────────────────────────────────────────
  # Step 2: Count distinct cases per student per academic year
  # ─────────────────────────────────────────────────────────────────────────
  cases_per_student <- cases_with_responsible |>
    group_by(ACADEMIC_YEAR, SID) |>
    summarise(
      case_count = n_distinct(FILE_ID),
      .groups = "drop"
    )

  # ────────────────────────────────────────────────────────────────────────
  # Step 3: Summarize by academic year (and optional grouping)
  # ────────────────────────────────────────────────────────────────────────

  # If grouping, we need to bring group info back in
  if (!is.null(group_by)) {
    # Get the grouping value for each student (use most recent)
    student_groups <- df |>
      filter(ACADEMIC_YEAR %in% academic_years, ROLE == "Respondent") |>
      arrange(SID, desc(INCIDENT_DATE)) |>
      group_by(SID) |>
      slice_head(n = 1) |>
      ungroup() |>
      select(SID, all_of(group_by))

    cases_per_student <- cases_per_student |>
      left_join(student_groups, by = "SID")
  }

  group_vars <- c("ACADEMIC_YEAR", group_by)

  result <- cases_per_student |>
    group_by(across(all_of(group_vars))) |>
    summarise(
      Found_Resp = n(),
      Found_Resp_Again = sum(case_count > 1),
      Rate = if_else(Found_Resp > 0,
                     Found_Resp_Again / Found_Resp,
                     NA_real_),
      .groups = "drop"
    ) |>
    rename(Academic_Year = ACADEMIC_YEAR)

  # Add overall row if grouped
  if (!is.null(group_by)) {
    overall <- cases_per_student |>
      group_by(ACADEMIC_YEAR) |>
      summarise(
        Found_Resp = n(),
        Found_Resp_Again = sum(case_count > 1),
        Rate = if_else(Found_Resp > 0, Found_Resp_Again / Found_Resp,
                       NA_real_),
        .groups = "drop"
      ) |>
      mutate(!!group_by := "Overall") |>
      rename(Academic_Year = ACADEMIC_YEAR)

    result <- bind_rows(result, overall)
  }

  # Format output
  if (format == "display") {
    result <- result |>
      mutate(Rate_Display = scales::percent(Rate, accuracy = 0.01)) |>
      select(-Rate) |>
      rename(Rate = Rate_Display)
  } else if (format == "pbi") {
    if (!is.null(group_by)) {
      complete_grid <- expand_grid(
        Academic_Year = academic_years,
        !!sym(group_by) := unique(result[[group_by]])
      )
      result <- complete_grid |>
        left_join(result, by = c("Academic_Year", group_by))
    }

    result <- result |>
      mutate(
        AY_Order = as.integer(str_remove(Academic_Year, "^AY")),
        Rate_Pct_Label = if_else(is.na(Rate), NA_character_,
                                 scales::percent(Rate, accuracy = 0.01))
      )

    if (!is.null(group_by)) {
      result <- result |>
        arrange(AY_Order, desc(!!sym(group_by) == "Overall"),
                !!sym(group_by))
    } else {
      result <- result |> arrange(AY_Order)
    }
  }

  result
}

#' Build student-level cohort recidivism fact table
#'
#' Assigns each student to a cohort based on the academic year of their
#' first-ever responsible finding, then tracks whether they had any subsequent
#' responsible finding. Produces one row per student for use as a Power BI
#' fact table — aggregation and rate calculations are handled in the
#' analytical layer.
#'
#' @param df Data frame containing conduct records
#' @param cohort_years Character vector of academic years to include as cohorts
#' @param followup_through Optional academic year string (e.g., "AY2425")
#'   limiting recidivism tracking to cases on or before the end of that year.
#'   Default NULL includes all available data.
#' @return Data frame with one row per student, containing cohort year,
#'   first incident date, recidivism status, intensity category, and
#'   time-to-recidivism metrics
#' @export
#' @examples
#' calculate_cohort_recidivism(df, cohort_years = ACADEMIC_YEARS)
#' calculate_cohort_recidivism(df, cohort_years = ACADEMIC_YEARS,
#'                             followup_through = "AY2324")
calculate_cohort_recidivism <- function(df,
                                        cohort_years,
                                        followup_through = NULL) {

  # Validate required columns
  validate_columns(
    df,
    c("ROLE", "SID", "FILE_ID", "INCIDENT_DATE", "ACADEMIC_YEAR"),
    "conduct data"
  )

  # Get FINDING columns
  finding_vars <- grep("^FINDING_", names(df), value = TRUE)
  if (length(finding_vars) == 0) {
    stop("No FINDING_* columns found in dataframe")
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 1: Identify all cases with at least one responsible finding
  # ─────────────────────────────────────────────────────────────────────────
  responsible_cases <- df |>
    filter(ROLE == "Respondent") |>
    mutate(
      has_responsible = if_any(
        all_of(finding_vars),
        ~ tolower(trimws(as.character(.x))) == "responsible"
      )
    ) |>
    filter(has_responsible) |>
    # One row per case per student
    group_by(SID, FILE_ID, ACADEMIC_YEAR) |>
    summarise(
      INCIDENT_DATE = min(INCIDENT_DATE, na.rm = TRUE),
      .groups = "drop"
    ) |>
    arrange(SID, INCIDENT_DATE)

  # Apply followup cutoff if specified
  if (!is.null(followup_through)) {
    followup_end <- as.Date(
      paste0("20", substr(followup_through, 5, 6), "-07-31")
    )
    responsible_cases <- responsible_cases |>
      filter(INCIDENT_DATE <= followup_end)
  }

  # ─────────────────────────────────────────────────────────────────────────
  # Step 2: For each student, identify case sequence
  # ─────────────────────────────────────────────────────────────────────────
  student_cases <- responsible_cases |>
    group_by(SID) |>
    mutate(
      case_sequence = row_number(),
      total_cases   = n()
    ) |>
    ungroup()

  # ─────────────────────────────────────────────────────────────────────────
  # Step 3: Extract first case (defines cohort)
  # ─────────────────────────────────────────────────────────────────────────
  first_cases <- student_cases |>
    filter(case_sequence == 1) |>
    select(
      SID,
      Cohort_Year              = ACADEMIC_YEAR,
      First_Incident_Date      = INCIDENT_DATE,
      First_File_ID            = FILE_ID,
      Total_Responsible_Cases  = total_cases
    )

  # ─────────────────────────────────────────────────────────────────────────
  # Step 4: Extract second case (if exists) for recidivism metrics
  # ─────────────────────────────────────────────────────────────────────────
  second_cases <- student_cases |>
    filter(case_sequence == 2) |>
    select(
      SID,
      Second_Incident_Date = INCIDENT_DATE,
      Second_File_ID       = FILE_ID,
      Second_Case_Year     = ACADEMIC_YEAR
    )

  # ─────────────────────────────────────────────────────────────────────────
  # Step 5: Build final fact table
  # ─────────────────────────────────────────────────────────────────────────
  first_cases |>
    left_join(second_cases, by = "SID") |>
    mutate(
      Is_Recidivist      = !is.na(Second_Incident_Date),
      Days_to_Recidivism = as.numeric(
        difftime(Second_Incident_Date, First_Incident_Date, units = "days")
      ),

      # Recidivism intensity categories
      Recidivism_Category = case_when(
        Total_Responsible_Cases == 1 ~ "No Recidivism",
        Total_Responsible_Cases == 2 ~ "One Repeat",
        Total_Responsible_Cases == 3 ~ "Two Repeats",
        Total_Responsible_Cases >= 4 ~ "Three+ Repeats"
      ),
      # Factor for proper sorting in visuals
      Recidivism_Category = factor(
        Recidivism_Category,
        levels = c("No Recidivism", "One Repeat",
                   "Two Repeats", "Three+ Repeats")
      ),
      # Numeric version for calculations
      Repeat_Count = Total_Responsible_Cases - 1,

      # Cohort year ordering for proper sorting in visuals
      Cohort_AY_Order = as.integer(str_remove(Cohort_Year, "^AY"))
    ) |>
    # Filter to cohorts within the requested analysis period
    filter(Cohort_Year %in% cohort_years) |>
    select(
      SID,
      Cohort_Year,
      Cohort_AY_Order,
      First_Incident_Date,
      Total_Responsible_Cases,
      Repeat_Count,
      Is_Recidivist,
      Recidivism_Category,
      Second_Incident_Date,
      Second_Case_Year,
      Days_to_Recidivism
    ) |>
    arrange(Cohort_Year, First_Incident_Date)
}

#' Calculate year-over-year violation comparison
#' @param df Data frame containing conduct records
#' @param years Character vector of academic years to compare
#' @return Data frame with violation counts and percent changes
#' @export
charge_comp <- function(df, years) {
  # Initialize list to store yearly data
  yearly_data <- list()

  # Process each year
  for (year in years) {
    year_col_name <- paste0("AY", substr(year, 3, 6))

    yearly_data[[year]] <- df |>
      filter(ACADEMIC_YEAR == year) |>
      select(CHARGE_1:CHARGE_6) |>
      pivot_longer(
        cols = CHARGE_1:CHARGE_6,
        names_to = 'CHARGE',
        values_to = 'VIOLATION',
        values_drop_na = TRUE
      ) |>
      count(VIOLATION) |>
      mutate(n = replace_na(n, 0)) |>
      rename(!!year_col_name := n)
  }

  # Merge all yearly data
  y2y_comp <- reduce(yearly_data, full_join, by = "VIOLATION")

  # Replace NA with 0 and calculate percentage changes
  for (i in seq_along(years)) {
    year_col_name <- paste0("AY", substr(years[i], 3, 6))
    y2y_comp[[year_col_name]] <- replace_na(y2y_comp[[year_col_name]], 0)

    if (i > 1) {
      prev_year_col_name <- paste0("AY", substr(years[i - 1], 3, 6))
      change_col_name <- paste0("Change from ", prev_year_col_name,
                                " to ", year_col_name)
      y2y_comp[[change_col_name]] <- scales::percent(
        (y2y_comp[[year_col_name]] - y2y_comp[[prev_year_col_name]]) /
          y2y_comp[[prev_year_col_name]],
        accuracy = 0.01
      )
    }
  }

  y2y_comp |>
    filter(!is.na(VIOLATION)) |>
    arrange(VIOLATION)
}

#' Analyze warning letter policy impact on recidivism
#'
#' Classifies students into conduct pathway groups for a single academic year
#' and produces a combined summary table with a separate anomaly audit table.
#'
#' @section Case Classification:
#' \describe{
#'   \item{Warning Letter}{TYPE == "RED Educational Response",
#'     Resolution == "Educational Response",
#'     at least one FINDING_* == "Founded"}
#'   \item{Formal}{TYPE == "Non Academic Misconduct",
#'     Resolution \%in\% c("Procedural Review", "University Conduct Board"),
#'     at least one FINDING_* == "Responsible"}
#' }
#'
#' @section Sequencing:
#' INCIDENT_DATE is used only for academic year assignment.
#' HEARING_DATE determines case sequence within the year.
#' Same-day HEARING_DATE conflicts (Founded and Responsible on the same day)
#' are flagged as unclassifiable and excluded from pathway groups.
#'
#' @param df Data frame containing conduct records
#' @param academic_year Single academic year string (e.g., "AY2425")
#'
#' @return A named list with two elements:
#' \describe{
#'   \item{summary}{Data frame with recidivism metrics by pathway group}
#'   \item{anomalies}{Data frame of FILE_IDs with reason flagged for audit}
#' }
#'
#' @export
calculate_warning_letter_recidivism <- function(df, academic_year) {

  # ── 0. Input validation ────────────────────────────────────────────────────
  required_cols <- c("FILE_ID", "SID", "ROLE", "TYPE", "Resolution",
                     "INCIDENT_DATE", "HEARING_DATE")
  missing_cols <- setdiff(required_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  finding_vars <- grep("^FINDING_", names(df), value = TRUE)
  if (length(finding_vars) == 0) {
    stop("No FINDING_* columns found in dataframe")
  }

  # ── 1. Compute academic year and filter to year of interest ────────────────
  if (!"ACADEMIC_YEAR" %in% names(df)) {
    df <- df |> mutate(ACADEMIC_YEAR = compute_academic_year(INCIDENT_DATE))
  }

  df_year <- df |>
    filter(ACADEMIC_YEAR == academic_year, ROLE == "Respondent")

  if (nrow(df_year) == 0) {
    stop("No Respondent records found for academic year: ", academic_year)
  }

  # ── 2. Anomaly detection ───────────────────────────────────────────────────
  # Work at the FILE_ID level (one row per FILE_ID after collapsing findings)
  cases <- df_year |>
    group_by(FILE_ID, TYPE, Resolution) |>
    summarise(
      SID             = first(SID),
      HEARING_DATE    = first(HEARING_DATE),
      INCIDENT_DATE   = first(INCIDENT_DATE),
      # Collapse all finding values for this FILE_ID into a single vector
      findings        = list(unique(na.omit(tolower(trimws(
        unlist(across(all_of(finding_vars)))
      ))))),
      .groups = "drop"
    )

  valid_red_findings    <- c("founded", "unfounded")
  valid_nam_findings    <- c("responsible", "not responsible",
                             "educational response")
  valid_nam_resolutions <- c("Procedural Review", "University Conduct Board")

  anomalies <- bind_rows(

    # RED Educational Response: wrong resolution
    cases |>
      filter(TYPE == "RED Educational Response",
             Resolution != "Educational Response") |>
      transmute(FILE_ID,
                reason = paste0(
                  "RED Educational Response case has unexpected Resolution: '",
                  Resolution, "'"
                )),

    # RED Educational Response: invalid finding values
    cases |>
      filter(TYPE == "RED Educational Response") |>
      mutate(
        invalid_findings = map_chr(findings, ~ {
          bad <- setdiff(.x, valid_red_findings)
          if (length(bad) == 0) NA_character_
          else paste(bad, collapse = ", ")
        })
      ) |>
      filter(!is.na(invalid_findings)) |>
      transmute(FILE_ID,
                reason = paste0(
                  "RED Educational Response case has invalid finding(s): '",
                  invalid_findings, "'"
                )),

    # Non Academic Misconduct: wrong resolution
    cases |>
      filter(TYPE == "Non Academic Misconduct",
             !Resolution %in% valid_nam_resolutions) |>
      transmute(FILE_ID,
                reason = paste0(
                  "Non Academic Misconduct case has unexpected Resolution: '",
                  Resolution, "'"
                )),

    # Non Academic Misconduct: invalid finding values
    cases |>
      filter(TYPE == "Non Academic Misconduct") |>
      mutate(
        invalid_findings = map_chr(findings, ~ {
          bad <- setdiff(.x, valid_nam_findings)
          if (length(bad) == 0) NA_character_
          else paste(bad, collapse = ", ")
        })
      ) |>
      filter(!is.na(invalid_findings)) |>
      transmute(FILE_ID,
                reason = paste0(
                  "Non Academic Misconduct case has invalid finding(s): '",
                  invalid_findings, "'"
                )),

    # ROLE != Respondent records (should not appear after filter, but catches
    # any FILE_IDs where the respondent row is missing entirely)
    df |>
      filter(ACADEMIC_YEAR == academic_year,
             FILE_ID %in% df_year$FILE_ID,
             ROLE != "Respondent") |>
      distinct(FILE_ID) |>
      anti_join(df_year |> distinct(FILE_ID), by = "FILE_ID") |>
      transmute(FILE_ID,
                reason = "FILE_ID has no Respondent row in this academic year")

  ) |>
    distinct(FILE_ID, reason) |>
    arrange(FILE_ID)

  # Remove anomalous FILE_IDs from further analysis
  clean_cases <- cases |>
    filter(!FILE_ID %in% anomalies$FILE_ID)

  # ── 3. Classify each case as warning_letter or formal ─────────────────────
  warning_cases <- clean_cases |>
    filter(
      TYPE == "RED Educational Response",
      Resolution == "Educational Response",
      map_lgl(findings, ~ "founded" %in% .x)
    ) |>
    mutate(case_type = "warning_letter")

  formal_cases <- clean_cases |>
    filter(
      TYPE == "Non Academic Misconduct",
      Resolution %in% valid_nam_resolutions,
      map_lgl(findings, ~ "responsible" %in% .x)
    ) |>
    mutate(case_type = "formal")

  classified_cases <- bind_rows(warning_cases, formal_cases) |>
    select(FILE_ID, SID, case_type, HEARING_DATE, INCIDENT_DATE)

  # ── 4. Sequence cases within student-year ─────────────────────────────────
  student_sequences <- classified_cases |>
    arrange(SID, HEARING_DATE) |>
    group_by(SID) |>
    mutate(case_order = row_number()) |>
    ungroup()

  # Flag same-day conflicts: student has both a warning_letter and formal case
  # on the exact same HEARING_DATE — sequence is ambiguous
  same_day_conflicts <- student_sequences |>
    group_by(SID, HEARING_DATE) |>
    filter(n_distinct(case_type) > 1) |>
    ungroup()

  if (nrow(same_day_conflicts) > 0) {
    conflict_file_ids <- same_day_conflicts |> distinct(FILE_ID)
    anomalies <- bind_rows(
      anomalies,
      conflict_file_ids |>
        transmute(FILE_ID,
                  reason = paste0(
                    "Same-day HEARING_DATE conflict: Founded and Responsible ",
                    "case on same date for same student — sequence ambiguous"
                  ))
    ) |>
      distinct(FILE_ID, reason) |>
      arrange(FILE_ID)

    student_sequences <- student_sequences |>
      filter(!SID %in% same_day_conflicts$SID)
  }

  # ── 5. Assign students to pathway groups ──────────────────────────────────

  # Determine each student's first case type (by HEARING_DATE)
  first_case <- student_sequences |>
    group_by(SID) |>
    slice_min(HEARING_DATE, n = 1, with_ties = FALSE) |>
    ungroup() |>
    select(SID, first_case_type = case_type)

  student_cases <- student_sequences |>
    left_join(first_case, by = "SID")

  # Formal-Only: first case is formal, has >= 2 formal Responsible cases
  formal_recid <- student_cases |>
    filter(first_case_type == "formal", case_type == "formal") |>
    group_by(SID) |>
    summarise(formal_count = n(), .groups = "drop") |>
    mutate(
      group         = "Formal Only",
      is_recidivist = formal_count >= 2
    )

  # Warning → Responsible: first case is warning, has >= 1 subsequent formal
  warn_to_formal <- student_cases |>
    filter(first_case_type == "warning_letter") |>
    group_by(SID) |>
    summarise(
      warning_count = sum(case_type == "warning_letter"),
      formal_count  = sum(case_type == "formal"),
      .groups = "drop"
    ) |>
    mutate(
      group = case_when(
        formal_count >= 1  ~ "Warning → Responsible",
        warning_count >= 2 ~ "Warning → Warning",
        TRUE               ~ "Warning (No Repeat)"
      ),
      is_recidivist = group %in% c("Warning → Responsible",
                                   "Warning → Warning")
    )

  # Warning → Any Repeat (union of Warning → Responsible and Warning → Warning)
  warn_any_repeat <- warn_to_formal |>
    summarise(
      group         = "Warning → Any Repeat",
      n_students    = n(),
      n_recidivists = sum(is_recidivist),
      .groups       = "drop"
    ) |>
    mutate(rate = if_else(n_students > 0,
                          n_recidivists / n_students,
                          NA_real_))

  # ── 6. Build summary table ─────────────────────────────────────────────────
  group_summary <- bind_rows(
    formal_recid  |> select(SID, group, is_recidivist),
    warn_to_formal |> select(SID, group, is_recidivist)
  ) |>
    group_by(group) |>
    summarise(
      n_students    = n(),
      n_recidivists = sum(is_recidivist),
      rate          = if_else(n() > 0, sum(is_recidivist) / n(), NA_real_),
      .groups       = "drop"
    )

  summary_table <- bind_rows(
    group_summary,
    warn_any_repeat
  ) |>
    mutate(
      Academic_Year = academic_year,
      Rate_Display  = scales::percent(rate, accuracy = 0.01)
    ) |>
    select(
      Academic_Year,
      Group         = group,
      N_Students    = n_students,
      N_Recidivists = n_recidivists,
      Rate          = Rate_Display
    ) |>
    arrange(factor(Group, levels = c(
      "Formal Only",
      "Warning → Responsible",
      "Warning → Warning",
      "Warning → Any Repeat",
      "Warning (No Repeat)"
    )))

  # ── 7. Return ──────────────────────────────────────────────────────────────
  list(
    summary   = summary_table,
    anomalies = anomalies
  )
}
