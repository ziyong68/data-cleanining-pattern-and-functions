library(tidyverse)
library(randomNames)
library(dplyr)
library(stringr)
library(kableExtra)

#################
# Data Creation #
#################

# Set seed for repeatibility
set.seed(68614)

# Input the number of rows
row_num <- 30
# Input the number of columns
col_num <- 10

# Create base dataframe by randomly generating some names and ids
df <- data.frame(name = randomNames(row_num), 
                 id = paste0(sample(LETTERS,row_num, replace = TRUE), sample(c(1:1000000), row_num), sample(LETTERS,row_num, replace = TRUE)))

# Create abc_table
abc_table <- replicate(col_num, {
  
  # Number of rows with trailing zeros
  n<-sample(1:row_num,1)
  
  # Randomly generate the column
  col_vec <- c(str_pad(sample(1:10000,n, replace = TRUE), 9, side = "left", pad = "0"),
               sample(c("", NA, "N", "O", "P", "S"), row_num - n, replace = TRUE)
  )
  
  return(col_vec)
  
})

# Above replicate function will replcate the random column generating function for whatever col_num times (with each replication using a different seed)

# Convert matrix to dataframe
abc_table <- as.data.frame(abc_table)

# Assign colnames to abc_table
colnames(abc_table) <- paste0("attr_", c(1:ncol(abc_table)))

# Create def_table
def_table <- replicate(col_num, {
  
  # Number of rows with trailing zeros
  n<-sample(1:row_num,1)
  
  # Randomly generate the column
  col_vec <- c(str_pad(sample(1:10000,n, replace = TRUE), 9, side = "left", pad = "0"),
               sample(c("", NA, "N", "O", "P", "S"), row_num - n, replace = TRUE)
  )
  
  return(col_vec)
  
})

# Convert matrix to dataframe
def_table <- as.data.frame(def_table)

# Assign column names to def_table
colnames(def_table) <- paste0("ada_", c(1:ncol(def_table)))

df <- cbind(df,abc_table, def_table)

# Create 2 additional columns that have only character strings and alpha-numeric strings
df <- df %>% mutate(ix_1 = sample(c("East", "South", "West", "North"), row_num, replace = TRUE),
                    ix_2 = sample(c("1A2B", "3C4D", "5E6F", "8G9H"), row_num, replace = TRUE))

View(df)

#############
# Functions #
#############

# Define a function that trims leading zeros
lead_zero_trim <- function(x){
  # Pass as.character in case it is a factor
  x_ws_trim <- trimws(as.character(x))
  ifelse(
    str_detect(x_ws_trim, "^0+$"), 
    str_replace(x_ws_trim, "^0+$", "0"), 
    str_replace(x_ws_trim,"^0+","")
  )
}

# Define another function to check if it contains at least 1 row of proper number
is.proper.number <- function(x){
  str_detect(x, "^[0-9]*(\\.[0-9]*)?$")
}

# Define ig_wrangle function
ig_wrangle <- function(x){
  x <- lead_zero_trim(x)
  
  # Lookups based on data dictionary
  x <- case_when(x == "N" ~ "1",
                 x == "O" ~ "99",
                 x == "P" ~ "999",
                 x == "S" ~ "9999",
                 # Turn those blank strings and true NA into NA_character_
                 # NA_character_ is used to enforce same type of data across entire column
                 x == "" | x == " " | is.na(x) ~ NA_character_,
                 # Else Case
                 TRUE ~ x)
  
  # Convert to numeric if there is at least one proper number data in that column
  if(any(is.proper.number(x))){
    as.numeric(x)
  } else {
    x
  }
  
  return(x)
}

# Create a wrapper to pass dataframe and column selection based on regex starts with
ig_df_wrangle <- function(df, start_with_str){
  df <- df %>% mutate_at(vars(matches(paste0("^(",start_with_str,")"))),ig_wrangle)
}

########
# Test #
########
test <- ig_df_wrangle(df, "attr_|ada_|ix_")
View(test)


