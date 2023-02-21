library(tidyverse) # https://www.tidyverse.org/
library(synthesisr) # https://CRAN.R-project.org/package=synthesisr
library(revtools) # https://revtools.net/
library(data.table)

data <- read.csv("articles.csv") #load the file
output_filename <- "deduplicated.csv"
#dim(data) #see the initial number of uploaded references

data$title2 <- stringr::str_replace_all(data$title,"[:punct:]","") %>% str_replace_all(.,"[ ]+", " ") %>% tolower() # Removing all punctuation and extra white spaces

distinct_data <- distinct(data, title2, .keep_all = TRUE) #reduce to records with unique titles (removes exact duplicates)

#dim(distinct_data) #see the new number of records

#View(arrange(distinct_data, title2)$title2) #an optional visual check - sorted titles

duplicates_string <- synthesisr::find_duplicates(distinct_data$title2, method = "string_osa", to_lower = TRUE, rm_punctuation = TRUE, threshold = 7)

#dim(manual_checks) #number of duplicated records found
#View( review_duplicates(distinct_data$title2, duplicates_string)) # optional visual check of the list of duplicates detected. If needed, you can manually mark some records as unique (not duplicates) by providing their new record number from duplicates_string (duplicates have the same record number), e.g.
#new_duplicates <- synthesisr::override_duplicates(duplicates_string, 34)

unique_data <- extract_unique_references(distinct_data, duplicates_string) #extract unique references (i.e. remove fuzzy duplicates)
dim(unique_data) #new number of unique records

unique_data %>% select(key, title, authors, journal, issn, volume, issue, pages, year, publisher, url, abstract, doi, keywords) -> processed_data #select the key columns

writeLines(toString(colnames(processed_data)), output_filename)
write.table(processed_data, output_filename, row.names = FALSE, col.names = FALSE, append = TRUE, na = "", sep = ",", qmethod = c("double"))
