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
#' @param algo Hashing algorithm (default: "sha256")
#' @param n_hex Number of hex characters to return
#' @return Character vector of hashed values
#' @export
hash_col <- function(x, key, algo = "sha256", n_hex = 32) {
  vapply(x, function(val) {
    if (is.na(val)) return(NA_character_)
    val_chr <- as.character(val)
    h <- openssl::sha256(paste0(val_chr, rawToChar(key)), key = key)
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

#' Calculate cohort-based recidivism rates
#' 
#' Defines cohorts by the academic year of each student's 
#' first responsible finding,
#' then calculates what percentage had any subsequent responsible finding.
#' 
#' @param df Data frame containing conduct records
#' @param cohort_years Character vector of academic years to use as cohorts
#' @param followup_through Academic year to track recidivism through 
#' (default: latest in data)
#' @param group_by Optional grouping variable (e.g., "College")
#' @param format Output format: "display" (with %) or "pbi" (numeric Rate)
#' @return Data frame with cohort-based recidivism metrics
#' @export
#' @examples
#' # What % of students whose first responsible finding was in AY2122 
#' # had another responsible finding in AY2223, AY2324, or AY2425?
#' calculate_cohort_recidivism(df, cohort_years = c("AY2122", "AY2223", 
#' "AY2324"))
calculate_cohort_recidivism <- function(df, 
                                        cohort_years,
                                        followup_through = NULL,
                                        group_by = NULL,
                                        format = c("display", "pbi")) {
  format <- match.arg(format)
  
  # Get FINDING columns
  finding_vars <- grep("^FINDING_", names(df), value = TRUE)
  if (length(finding_vars) == 0) {
    stop("No FINDING_* columns found in dataframe")
  }
  
  # Validate required columns
  validate_columns(df, c("ROLE", "SID", "FILE_ID", "INCIDENT_DATE", 
                         "ACADEMIC_YEAR"), 
                   "conduct data")
  
  # Standardize grouping columns
  if (!is.null(group_by)) {
    df <- df |>
      mutate(across(all_of(group_by), 
                    ~ replace_na(as.character(.x), "Not Reported")))
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
    group_by(SID, FILE_ID, ACADEMIC_YEAR) |>
    summarise(
      INCIDENT_DATE = min(INCIDENT_DATE, na.rm = TRUE),
      .groups = "drop"
    )
  
  # ────────────────────────────────────────────────────────────────────────
  # Step 2: For each student, identify their FIRST responsible case ever
  # ────────────────────────────────────────────────────────────────────────
  first_responsible <- responsible_cases |>
    arrange(SID, INCIDENT_DATE) |>
    group_by(SID) |>
    slice_head(n = 1) |>
    ungroup() |>
    rename(
      first_file_id = FILE_ID,
      first_incident_date = INCIDENT_DATE,
      cohort_year = ACADEMIC_YEAR
    )
  
  # ───────────────────────────────────────────────────────────────────────
  # Step 3: Identify students who had ANY subsequent responsible case
  # ───────────────────────────────────────────────────────────────────────
  subsequent_cases <- responsible_cases |>
    inner_join(
      first_responsible |> select(SID, first_incident_date),
      by = "SID"
    ) |>
    filter(INCIDENT_DATE > first_incident_date)
  
  # Apply followup cutoff if specified
  if (!is.null(followup_through)) {
    # Get end date of followup year
    followup_end <- as.Date(paste0("20", substr(followup_through, 5, 6),
                                   "-07-31"))
    subsequent_cases <- subsequent_cases |>
      filter(INCIDENT_DATE <= followup_end)
  }
  
  students_with_recidivism <- subsequent_cases |>
    distinct(SID) |>
    mutate(is_recidivist = TRUE)
  
  # ───────────────────────────────────────────────────────────────────────
  # Step 4: Build cohort summary
  # ───────────────────────────────────────────────────────────────────────
  
  # Filter to requested cohort years
  cohort_data <- first_responsible |>
    filter(cohort_year %in% cohort_years) |>
    left_join(students_with_recidivism, by = "SID") |>
    mutate(is_recidivist = replace_na(is_recidivist, FALSE))
  
  # Add grouping variable if specified
  if (!is.null(group_by)) {
    student_groups <- df |>
      filter(ROLE == "Respondent") |>
      arrange(SID, desc(INCIDENT_DATE)) |>
      group_by(SID) |>
      slice_head(n = 1) |>
      ungroup() |>
      select(SID, all_of(group_by))
    
    cohort_data <- cohort_data |>
      left_join(student_groups, by = "SID")
  }
  
  # ───────────────────────────────────────────────────────────────────────
  # Step 5: Summarize by cohort year (and optional grouping)
  # ───────────────────────────────────────────────────────────────────────
  group_vars <- c("cohort_year", group_by)
  
  result <- cohort_data |>
    group_by(across(all_of(group_vars))) |>
    summarise(
      Cohort_N = n(),
      Recidivists = sum(is_recidivist),
      Rate = if_else(Cohort_N > 0, 
                     Recidivists / Cohort_N, 
                     NA_real_),
      .groups = "drop"
    ) |>
    rename(Cohort_Year = cohort_year)
  
  # Add overall row if grouped
  if (!is.null(group_by)) {
    overall <- cohort_data |>
      group_by(cohort_year) |>
      summarise(
        Cohort_N = n(),
        Recidivists = sum(is_recidivist),
        Rate = if_else(Cohort_N > 0, Recidivists / Cohort_N, NA_real_),
        .groups = "drop"
      ) |>
      mutate(!!group_by := "Overall") |>
      rename(Cohort_Year = cohort_year)
    
    result <- bind_rows(result, overall)
  }
  
  # ───────────────────────────────────────────────────────────────────────
  # Step 6: Format output
  # ───────────────────────────────────────────────────────────────────────
  if (format == "display") {
    result <- result |>
      mutate(Rate_Display = scales::percent(Rate, accuracy = 0.1)) |>
      select(-Rate) |>
      rename(Rate = Rate_Display)
  } else if (format == "pbi") {
    if (!is.null(group_by)) {
      complete_grid <- expand_grid(
        Cohort_Year = cohort_years,
        !!sym(group_by) := unique(result[[group_by]])
      )
      result <- complete_grid |>
        left_join(result, by = c("Cohort_Year", group_by))
    }
    
    result <- result |>
      mutate(
        AY_Order = as.integer(str_remove(Cohort_Year, "^AY")),
        Rate_Pct_Label = if_else(is.na(Rate), NA_character_, 
                                 scales::percent(Rate, accuracy = 0.1))
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


# Legacy function wrappers for backward compatibility ----------------------

#' Calculate recidivism for given academic years (legacy wrapper)
#' @param df Data frame containing conduct records
#' @param academic_years Character vector of academic years
#' @return Data frame with recidivism rates
#' @export
recidivism <- function(df, academic_years) {
  calculate_recidivism(df, academic_years, format = "display")
}

#' Calculate recidivism by college (legacy wrapper)
#' @param df Data frame containing conduct records
#' @param academic_years Character vector of academic years
#' @return Data frame with recidivism rates by college
#' @export
recidivism_by_college <- function(df, academic_years) {
  calculate_recidivism(df, academic_years, group_by = "College", 
                       format = "display")
}

#' Calculate recidivism by college for Power BI (legacy wrapper)
#' @param df Data frame containing conduct records
#' @param academic_years Character vector of academic years
#' @return Data frame with recidivism rates by college formatted 
#' for Power BI
#' @export
recidivism_by_college_pbi <- function(df, academic_years) {
  calculate_recidivism(df, academic_years, group_by = "College", 
                       format = "pbi")
}

fix_nbsp <- function(x) {
  x <- as.character(x)
  x <- gsub("\u00A0", " ", x, fixed = TRUE)  # NBSP -> normal space
  x <- gsub("[[:space:]]+", " ", x)          # collapse repeated whitespace
  trimws(x)
}

