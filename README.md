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

This repository contains **code and documentation**, not data. 

```
├── Building-an-Assessment-Ready-Conduct-Data-Model.qmd   # Main documentation (Quarto)
├── Building-an-Assessment-Ready-Conduct-Data-Model.pdf   # Rendered documentation
├── Imports/
│   ├── config.R                 # Configuration: paths, mappings, constants
│   ├── conduct_funcs.R          # Custom R functions for transformation
│   ├── star_schema.bib          # Bibliography
│   ├── DimSanction.csv          # Sanction categories and severity levels
│   ├── DimHousing.csv           # Housing attributes (template)
│   └── DimHousingYear.csv       # Year-specific housing attributes (template)
├── images/
│   └── erd-star-schema.png      # Entity-relationship diagram
└── _quarto.yml                  # Quarto configuration
```

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
| `housing_census.csv` | Institution-specific occupancy data |
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

## Adapting for Your Institution

This code was built for the University of Cincinnati's Maxient configuration. To adapt it:

1. **Review `config.R`** — Update file paths, location mappings, and violation name standardizations to match your data
2. **Review field names** — Your Maxient exports may use different column names
3. **Create lookup tables** — Build your own DimHousing.csv, hearing_officers.csv, etc.
4. **Generate an encryption key** — Create your own `pepper.bin` file (see documentation)

The methodology and table structures should transfer; the specific field mappings will need customization.

## Citation

If you use or adapt this work, please cite:

> Moermond, J. L. (2026). *Building an Assessment-Ready Conduct Data Model: Transforming Maxient Exports into Reliable Dashboards for Student Conduct Analysis.*

## License

This work is licensed under [CC BY-NC 4.0](LICENSE) (Creative Commons Attribution-NonCommercial 4.0 International).

You are free to share and adapt this work for non-commercial purposes with attribution. See the LICENSE file for details.

## Contact

Joshua L. Moermond  
[moermondsahe@gmail.com](mailto:moermondsahe@gmail.com)
[LinkedIn](https://www.linkedin.com/in/jmoermond)

## Acknowledgments

Portions of this documentation were developed with the assistance of generative AI tools for writing clarity and code refinement. All analytic decisions, methodology, and interpretations were designed and validated by the author.
