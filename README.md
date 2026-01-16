# Building an Assessment-Ready Conduct Data Model

Transforms Maxient student conduct exports into a star schema data model for reliable Power BI dashboards.

## The Problem

Maxient is excellent for case management but wasn't designed for trend analysis. When practitioners try to answer questions like "Are alcohol incidents increasing?" or "Which halls need more support?", they find exports that are:

- Inconsistent across years
- Full of duplicate spellings and variations
- Structured in ways that make accurate counting nearly impossible

## The Solution

This project provides a data pipeline that transforms raw Maxient exports into clean, organized tables following a star schema design. The result is dashboards where:

- Filters work as expected
- Numbers stay stable regardless of how you slice the data
- Stakeholders can trust what they're seeing

## Who This Is For

| Audience | What You'll Find |
|----------|------------------|
| **Conduct professionals** | Methodology documentation explaining what the model does and why, without requiring technical knowledge |
| **IR/Assessment/IT partners** | Complete R code, table definitions, and an entity-relationship diagram to replicate or adapt this approach |

## Repository Contents

This repository contains **code, documentation, and template files**—not actual student data. 

```
├── Building-an-Assessment-Ready-Conduct-Data-Model.qmd   # Main documentation (Quarto)
├── Building-an-Assessment-Ready-Conduct-Data-Model.pdf   # Rendered documentation
├── Imports/
│   ├── config.R                 # Configuration: paths, mappings, constants
│   ├── conduct_funcs.R          # Custom R functions for transformation
│   ├── star_schema.bib          # Bibliography
│   ├── DimSanction.csv          # Sanction categories and severity levels (template with example data)
│   ├── DimHousing.csv           # Housing attributes (template with example data)
│   ├── DimHousingYear.csv       # Year-specific housing attributes (template with example data)
│   └── housing_census.csv       # Building census data (template with example data)
├── images/
│   └── erd-star-schema.png      # Entity-relationship diagram
└── _quarto.yml                  # Quarto configuration
```

The template CSV files contain example data with placeholder building names. Replace these with your institution's actual data.

## What the Pipeline Creates

When you run this code with your own Maxient exports, it produces an Excel workbook containing the following tables:

### Dimension Tables (Context)
| Table | Purpose |
|-------|---------|
| DimDate | Calendar and academic time fields |
| DimAcademicYear | Academic year boundaries and sort keys |
| DimAcademicTerm | Fall/Spring/Summer term definitions |
| DimStudent | Student demographics and academic context |
| DimCase | Case-level attributes |
| DimHousing | Residence hall attributes |
| DimHousingYear | Year-specific housing attributes |
| DimSanction | Sanction categories and severity classifications |
| DimHearingOfficer | Staff assignment information |
| DimCollege | Academic college lookup |

### Fact Tables (Events)
| Table | Purpose |
|-------|---------|
| FactIncident | Core incident records |
| FactViolation | Alleged violations and outcomes |
| FactSanction | Sanctions applied |
| FactTimeline | Process timing metrics |
| FactRecidivism | Within-year repeat involvement |
| FactCohortRecidivism | Long-term cohort-based recidivism |
| FactHousingCensus | Violation rates per 100 residents |
| FactDeadline | Case deadline tracking |

**These tables are outputs of running the pipeline—they are not included in this repository.**

## What's NOT Included (and Why)

| Excluded | Reason |
|----------|--------|
| Raw Maxient exports | Contain student data |
| Output Excel files | Contain transformed but potentially identifiable patterns |
| `pepper.bin` | Encryption key for anonymization—must be generated locally |
| `hearing_officers.csv` | Contains staff names |
| `academic_plans.csv` | Institution-specific major/college mappings |

To use this at your institution, you'll need to provide your own versions of these files.

## Key Concepts

### Star Schema
A data structure that separates "what happened" (fact tables) from "context about what happened" (dimension tables). This prevents the filter confusion and inconsistent counts that plague flat exports.

### Grain
What one row in a table represents. Understanding grain prevents most reporting disagreements:

| Table | One Row = |
|-------|-----------|
| FactIncident | One incident |
| FactViolation | One alleged charge |
| FactSanction | One sanction applied |
| DimStudent | One unique student |

### Anonymization
Student IDs, case numbers, and file IDs are hashed using HMAC-SHA256, making them consistent (the same student always gets the same code) but irreversible (you can't work backward to find the real ID).

## Requirements

- **R** (4.0+)
- **R packages:** tidyverse, writexl, openssl, digest
- **Quarto** (for rendering documentation)
- **Power BI Desktop** (for dashboards)

## Maxient Standard Fields

Maxient uses a combination of standard fields (consistent across all institutions) and custom fields (configured per institution). This pipeline uses the following **standard fields** available in Custom Analytics:

| Field | Field | Field | Field |
|-------|-------|-------|-------|
| FILE_ID | APPT_DATE | CASE_NUMBER | DEADLINE_REASON |
| DEADLINE | SID | ASSIGNED_TO | STATUS |
| TYPE | CASE_CREATED_DATE | HOLD_IN_PLACE | GENDER |
| ACADEMIC_MAJOR | GPA_CUME | CLASSIFICATION | DOB |
| MEM_ATHLETICS_SPORT | ETHNICITY | REPORTED_DATE | CLERY_REPORTABILITY |
| INCIDENT_LOCATION | ROLE | INCIDENT_DATE | HEARING_DATE |
| HEARING_TYPE | CHARGE_1 | FINDING_1 | CHARGE_2 |
| FINDING_2 | CHARGE_3 | FINDING_3 | CHARGE_4 |
| FINDING_4 | CHARGE_5 | FINDING_5 | CHARGE_6 |
| FINDING_6 | | | |

If your institution uses these standard fields, much of the pipeline will work with minimal modification. The `config.R` file handles institution-specific variations like location name spellings and violation name standardizations.

**Custom fields** (labeled OTHER1, OTHER2, Sanctions, etc. in Maxient) will vary by institution and require adjustment in the pipeline code.

## Generating an Encryption Key

The pipeline uses a 32-byte encryption key (`pepper.bin`) to anonymize student identifiers. To generate your own:

```r
# Run once to create your key
pepper <- openssl::rand_bytes(32)
writeBin(pepper, "Imports/pepper.bin")
```

**Important:**
- Generate this only once and reuse it for all pipeline runs
- The same key produces the same hashed IDs, allowing records to link across refreshes
- Keep this file secure—do not commit it to version control
- Back it up—if lost, you cannot regenerate consistent hashes

## Adapting for Your Institution

This code was built specifically for the author's institutional Maxient configuration. To adapt it:

1. **Review `config.R`** — Update file paths, location mappings, and violation name standardizations to match your data
2. **Review field names** — Your Maxient exports may use different column names for custom fields
3. **Update the template files** — Replace the placeholder data in DimHousing.csv, DimHousingYear.csv, DimSanction.csv, and housing_census.csv with your institution's actual values
4. **Create additional lookup tables** — Build your own hearing_officers.csv (see note below), academic_plans.csv, etc.
5. **Generate an encryption key** — See "Generating an Encryption Key" above

The methodology and table structures should transfer; the specific field mappings will need customization. To create hearing_officers.csv, run Maxient System Report 914 (Hearing Officer Titles in Use). Take the first and second columns and then add columns for Office and Position. This will enable you to look at outcomes by office and position.  For example, you might ask, *"How long is it taking residence life staff to resolve cases?*

## Citation

If you use or adapt this work, please cite:

> Moermond, J. L. (2026). *Building an Assessment-Ready Conduct Data Model: Transforming Maxient Exports into Reliable Dashboards for Student Conduct Analysis.*

## License

This work is licensed under [CC BY-NC 4.0](LICENSE) (Creative Commons Attribution-NonCommercial 4.0 International).

You are free to share and adapt this work for non-commercial purposes with attribution. See the LICENSE file for details.

## Contact

Joshua L. Moermond  
Email: [moermondsahe@gmail.com](mailto:moermondsahe@gmail.com)
Social: [LinkedIn](https://www.linkedin.com/in/jmoermond)

## Acknowledgments

Portions of this documentation were developed with the assistance of generative AI tools for writing clarity and code refinement. All analytic decisions, methodology, and interpretations were designed and validated by the author.



