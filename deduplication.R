library(tidyverse) # https://www.tidyverse.org/
library(synthesisr) # https://CRAN.R-project.org/package=synthesisr
library(revtools) # https://revtools.net/
library(data.table)

dat <- read.csv("articles.csv") #load the file
output_filename <- "deduplicated.csv"
#dim(dat) #see the initial number of uploaded references

dat$title2 <- stringr::str_replace_all(dat$title,"[:punct:]","") %>% str_replace_all(.,"[ ]+", " ") %>% tolower() # Removing all punctuation and extra white spaces

dat2 <- distinct(dat, title2, .keep_all = TRUE) #reduce to records with unique titles (removes exact duplicates)

#dim(dat2) #see the new number of records

#View(arrange(dat2, title2)$title2) #an optional visual check - sorted titles

duplicates_string <- synthesisr::find_duplicates(dat2$title2, method = "string_osa", to_lower = TRUE, rm_punctuation = TRUE, threshold = 7)

#dim(manual_checks) #number of duplicated records found
#View( review_duplicates(dat2$title2, duplicates_string)) # optional visual check of the list of duplicates detected. If needed, you can manually mark some records as unique (not duplicates) by providing their new record number from duplicates_string (duplicates have the same record number), e.g.
#new_duplicates <- synthesisr::override_duplicates(duplicates_string, 34)

dat3 <- extract_unique_references(dat2, duplicates_string) #extract unique references (i.e. remove fuzzy duplicates)
dim(dat3) #new number of unique records

dat3 %>% select(key, title, authors, journal, issn, volume, issue, pages, year, publisher, url, abstract, doi, keywords) -> dat4 #select the key columns

writeLines(toString(colnames(dat4)), output_filename)
write.table(dat6, output_filename, row.names = FALSE, col.names = FALSE, append = TRUE, na = "", sep = ",", qmethod = c("double"))
