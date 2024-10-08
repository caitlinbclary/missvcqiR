#'Export datasets to Excel for RI_QUAL_09
#'
#' @param VCP VCQI current program name to be logged, default to be the function name
#'
#' @return Sheet(s) in tabular output Excel file in VCQI_OUTPUT_FOLDER
#'
#' @import stringr
#' @import dplyr

# RI_QUAL_09_05TOST R version 1.00 - Biostat Global Consulting - 2023-07-24
# *******************************************************************************
# Change log

# Date 			  Version 	Name			      What Changed
# 2023-07-24  1.00      Mia Yu          Original R package version
# 2024-08-29  1.01      Caitlin Clary   Update to use multilingual strings
# *******************************************************************************

RI_QUAL_09_05TOST <- function(VCP = "RI_QUAL_09_05TOST"){
  vcqi_log_comment(VCP, 5, "Flow", "Starting")

  rm(list = c("TO_RI_QUAL_09", "TO_RI_QUAL_09_columnlabel", "TO_RI_QUAL_09_formatnum", "TO_RI_QUAL_09_colformat"),
     envir = .GlobalEnv) %>% suppressWarnings()

  vc <- str_to_lower(RI_QUAL_09_VALID_OR_CRUDE)

  suff <- c(MOV_OUTPUT_DOSE_LIST,"anydose")

  for (d in seq_along(suff)){

    print(suff[d])

    dose <- suff[d]

    # Do some cleanup work for each dose

    # Establish the local macros ldose and udose to use in situations that
    # require either lower case or upper case in this program

    ldose <- str_to_lower(dose)
    udose <- str_to_upper(dose)

    if (dose == "anydose") {
      ldose <- "anydose"
      udose <- "Any Dose"
    }

    dat <- vcqi_read(paste0(VCQI_OUTPUT_FOLDER, "/RI_QUAL_09_",
                            ANALYSIS_COUNTER, "_", ldose, "_database.rds"))

    # Calculate the three percent figures

    dat <- dat %>%
      mutate(pct_mov = ifelse((n_eligible > 0) %in% TRUE, (n_mov/n_eligible) * 100, NA),
             pct_uncor = ifelse((n_mov > 0) %in% TRUE, (n_uncor_mov/n_mov) * 100, NA),
             pct_cor = ifelse((n_mov > 0) %in% TRUE, (n_cor_mov/n_mov) * 100, NA))

    dat <- dat %>%
      mutate(pct_mov = ifelse(is.na(pct_mov) & !is.na(n_eligible), 0, pct_mov),
             pct_uncor = ifelse(is.na(pct_uncor) & !is.na(n_eligible), 0, pct_uncor),
             pct_cor = ifelse(is.na(pct_cor) & !is.na(n_eligible), 0, pct_cor))

    # Calculate the number and pct who had some but not all MOVs corrected if
    # we're building a table for all doses

    if (dose == "anydose"){
      dat <- dat %>%
        mutate(n_partial = n_mov - n_uncor_mov - n_cor_mov,
               pct_partial = ifelse((n_mov > 0) %in% TRUE, (n_partial/n_mov) * 100, NA))
      dat <- dat %>%
        mutate(pct_partial = ifelse(is.na(pct_partial) & !is.na(n_mov), 0, pct_partial))
    }

    # Generate a new 0/1 flag that indicates which rows in the output are
    # showing results for sub-strata defined by level 4
    dat <- dat %>% mutate(substratum = ifelse(!is.na(level4id), 1, 0))

    names(dat)[which(names(dat) == "n_eligible")] <- "n"

    saveRDS(dat, file = paste0(VCQI_OUTPUT_FOLDER, "/RI_QUAL_09_",
                               ANALYSIS_COUNTER, "_", ldose, "_TO.rds"))

    if (!vcqi_object_exists("RI_QUAL_09_TEMP_DATASETS")){
      RI_QUAL_09_TEMP_DATASETS <- NULL
    }

    vcqi_global(
      RI_QUAL_09_TEMP_DATASETS,
      c(RI_QUAL_09_TEMP_DATASETS,
        paste0("RI_QUAL_09_", ANALYSIS_COUNTER, "_", ldose, "_TO.rds")))

    if (dose != "anydose") {
      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_", ANALYSIS_COUNTER, "_", ldose, "_TO.rds"),
        variable = "n_mov", replacevar = NA, noannotate = TRUE,

        # Had MOSV for <dose> (N)
        label = paste0(language_string(language_use = language_use, str = "OS_24"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_", ANALYSIS_COUNTER, "_", ldose, "_TO.rds"),
        variable = "pct_mov", replacevar = NA, noannotate = TRUE,

        # Had MOSV for <dose> (%)
        label = paste0(language_string(language_use = language_use, str = "OS_24"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_uncor_mov", replacevar = NA, noannotate = TRUE,

        # MOSV uncorrected for <dose> (N)
        label = paste0(language_string(language_use = language_use, str = "OS_46"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0"))

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_uncor", replacevar = NA, noannotate = TRUE,

        # MOSV uncorrected for <dose> (%)
        label = paste0(language_string(language_use = language_use, str = "OS_46"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_cor_mov", replacevar = NA, noannotate = TRUE,

        # MOSV corrected for <dose> (N)
        label = paste0(language_string(language_use = language_use, str = "OS_45"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_cor", replacevar = NA, noannotate = TRUE,

        # MOSV corrected for <dose> (%)
        label = paste0(language_string(language_use = language_use, str = "OS_45"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n", replacevar = NA, noannotate = TRUE,

        # Had visits eligible <dose> (N)
        label = paste0(language_string(language_use = language_use, str = "OS_26"),
                       " ",
                       udose,
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )
    }

    if (dose == "anydose") {
      print("Totals...")

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_mov", replacevar = NA, noannotate = TRUE,

        # Had MOSV for any dose (N)
        label = paste0(language_string(language_use = language_use, str = "OS_25"),
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_mov", replacevar = NA, noannotate = TRUE,

        # Had MOSV for any dose (%)
        label = paste0(language_string(language_use = language_use, str = "OS_25"),
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_uncor_mov", replacevar = NA, noannotate = TRUE,

        # All MOSVs were uncorrected (N)
        label = paste0(language_string(language_use = language_use, str = "OS_7"),
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_uncor", replacevar = NA, noannotate = TRUE,

        # All MOSVs were uncorrected (%)
        label = paste0(language_string(language_use = language_use, str = "OS_7"),
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_cor_mov", replacevar = NA, noannotate = TRUE,

        # All MOSVs were corrected (N)
        label = paste0(language_string(language_use = language_use, str = "OS_6"),
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      # make_table_column(
      #   tablename = "TO_RI_QUAL_09",
      #   dbfilename = paste0("RI_QUAL_09_", ANALYSIS_COUNTER, "_", ldose, "_TO.rds"),
      #   variable = "pct_cor", replacevar = NA, noannotate = TRUE,
      #
      #   # All MOSVs were corrected (%)
      #   paste0(language_string(language_use = language_use, str = "OS_6"),
      #          " ",
      #          language_string(language_use = language_use, str = "OS_1"))
      # )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_cor", replacevar = NA, noannotate = TRUE,
        label = paste0(language_string(language_use = language_use, str = "OS_6"),
                       " ",
                       language_string(language_use = language_use, str = "OS_1")))

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n_partial", replacevar = NA, noannotate = TRUE,

        # Some (not all) MOSVs were corrected (N)
        label = paste0(language_string(language_use = language_use, str = "OS_69"),
                       " ",
                       language_string(language_use = language_use, str = "OS_2")),
        varformat = list("#,##0")
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "pct_partial", replacevar = NA, noannotate = TRUE,

        # Some (not all) MOSVs were corrected (%)
        label = paste0(language_string(language_use = language_use, str = "OS_69"),
                       " ",
                       language_string(language_use = language_use, str = "OS_1"))
      )

      make_table_column(
        tablename = "TO_RI_QUAL_09",
        dbfilename = paste0("RI_QUAL_09_",ANALYSIS_COUNTER,"_",ldose,"_TO.rds"),
        variable = "n", replacevar = NA, noannotate = TRUE,

        # Had visits eligible for any dose (N)
        label = language_string(language_use = language_use, str = "OS_27"),
        varformat = list("#,##0")
      )
    }

  } # end of d loop

  export_table_to_excel(indicator = "RI_QUAL_09",brief = FALSE)

  rm(list = c("TO_RI_QUAL_09", "TO_RI_QUAL_09_columnlabel",
              "TO_RI_QUAL_09_formatnum", "TO_RI_QUAL_09_colformat"),
     envir = .GlobalEnv) %>% suppressWarnings()
  rm(TO_RI_QUAL_09_CN, envir = .GlobalEnv) %>% suppressWarnings()

  vcqi_log_comment(VCP, 5, "Flow", "Exiting")
}

