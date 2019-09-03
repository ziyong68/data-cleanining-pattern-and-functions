---
title: "Detecting non alpha character string column and removing leading zeros"
author: "Brian Li"
date: "2019/9/1"
output: 
  html_document: 
    keep_md: yes
---

keep_md is set to yes to render a formatted markdown in github view.



## Calling libraries


```r
library(tidyverse)
library(randomNames)
library(dplyr)
library(stringr)
library(kableExtra)
```

We will circle around the usages of muate_at, str_detect and str_replace functions, and discuss how they can be used together to perform data transformation on string columns that contain some number data in some big data databases e.g. Hadoop. 

## Data Creation

The following code chunk will simulate the format and style of data that needs this treatment. It basically has a lot of string columns that contain number data with trailing zeros. However, some of them are meant to be purely alpha characters and remain as string columns. Personal ID (e.g. "P9455837B") and name (e.g. "Betty") are good examples of those.


```r
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
```

Hover the mouse over the table and scroll up-down and left-right to take a quick glimpse of the simulated data.


```r
knitr::kable(df) %>% kable_styling() %>% scroll_box(width = "100%", height = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:600px; overflow-x: scroll; width:100%; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Her, Abhinav </td>
   <td style="text-align:left;"> J959807F </td>
   <td style="text-align:left;"> 000003371 </td>
   <td style="text-align:left;"> 000003613 </td>
   <td style="text-align:left;"> 000006093 </td>
   <td style="text-align:left;"> 000003411 </td>
   <td style="text-align:left;"> 000002180 </td>
   <td style="text-align:left;"> 000007845 </td>
   <td style="text-align:left;"> 000006874 </td>
   <td style="text-align:left;"> 000008435 </td>
   <td style="text-align:left;"> 000001467 </td>
   <td style="text-align:left;"> 000005090 </td>
   <td style="text-align:left;"> 000003554 </td>
   <td style="text-align:left;"> 000007767 </td>
   <td style="text-align:left;"> 000002779 </td>
   <td style="text-align:left;"> 000006235 </td>
   <td style="text-align:left;"> 000007309 </td>
   <td style="text-align:left;"> 000007685 </td>
   <td style="text-align:left;"> 000009916 </td>
   <td style="text-align:left;"> 000006296 </td>
   <td style="text-align:left;"> 000009787 </td>
   <td style="text-align:left;"> 000006766 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dews, Shayna </td>
   <td style="text-align:left;"> G234300N </td>
   <td style="text-align:left;"> 000005610 </td>
   <td style="text-align:left;"> 000003265 </td>
   <td style="text-align:left;"> 000006756 </td>
   <td style="text-align:left;"> 000006307 </td>
   <td style="text-align:left;"> 000008466 </td>
   <td style="text-align:left;"> 000002395 </td>
   <td style="text-align:left;"> 000000285 </td>
   <td style="text-align:left;"> 000004480 </td>
   <td style="text-align:left;"> 000006644 </td>
   <td style="text-align:left;"> 000009457 </td>
   <td style="text-align:left;"> 000008418 </td>
   <td style="text-align:left;"> 000008782 </td>
   <td style="text-align:left;"> 000005735 </td>
   <td style="text-align:left;"> 000006464 </td>
   <td style="text-align:left;"> 000005551 </td>
   <td style="text-align:left;"> 000005849 </td>
   <td style="text-align:left;"> 000007345 </td>
   <td style="text-align:left;"> 000004872 </td>
   <td style="text-align:left;"> 000009102 </td>
   <td style="text-align:left;"> 000005902 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kiefer, Tasia </td>
   <td style="text-align:left;"> B803488K </td>
   <td style="text-align:left;"> 000002973 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000002878 </td>
   <td style="text-align:left;"> 000007659 </td>
   <td style="text-align:left;"> 000002812 </td>
   <td style="text-align:left;"> 000003928 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000007907 </td>
   <td style="text-align:left;"> 000003931 </td>
   <td style="text-align:left;"> 000001124 </td>
   <td style="text-align:left;"> 000007705 </td>
   <td style="text-align:left;"> 000002425 </td>
   <td style="text-align:left;"> 000000464 </td>
   <td style="text-align:left;"> 000008656 </td>
   <td style="text-align:left;"> 000006109 </td>
   <td style="text-align:left;"> 000003763 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000008821 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Watchman, Andrew </td>
   <td style="text-align:left;"> O787540P </td>
   <td style="text-align:left;"> 000009621 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000001979 </td>
   <td style="text-align:left;"> 000009455 </td>
   <td style="text-align:left;"> 000003813 </td>
   <td style="text-align:left;"> 000006375 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000000686 </td>
   <td style="text-align:left;"> 000002134 </td>
   <td style="text-align:left;"> 000007035 </td>
   <td style="text-align:left;"> 000009627 </td>
   <td style="text-align:left;"> 000000560 </td>
   <td style="text-align:left;"> 000006997 </td>
   <td style="text-align:left;"> 000003332 </td>
   <td style="text-align:left;"> 000008448 </td>
   <td style="text-align:left;"> 000000638 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000004018 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Massara, Abigail </td>
   <td style="text-align:left;"> T486795I </td>
   <td style="text-align:left;"> 000008575 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000005560 </td>
   <td style="text-align:left;"> 000004280 </td>
   <td style="text-align:left;"> 000009219 </td>
   <td style="text-align:left;"> 000001598 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000001970 </td>
   <td style="text-align:left;"> 000003871 </td>
   <td style="text-align:left;"> 000001056 </td>
   <td style="text-align:left;"> 000009648 </td>
   <td style="text-align:left;"> 000000722 </td>
   <td style="text-align:left;"> 000006797 </td>
   <td style="text-align:left;"> 000005078 </td>
   <td style="text-align:left;"> 000004767 </td>
   <td style="text-align:left;"> 000009904 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000005505 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tran, Thomas </td>
   <td style="text-align:left;"> E410468Z </td>
   <td style="text-align:left;"> 000003963 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000005599 </td>
   <td style="text-align:left;"> 000006215 </td>
   <td style="text-align:left;"> 000002304 </td>
   <td style="text-align:left;"> 000005753 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000000462 </td>
   <td style="text-align:left;"> 000001652 </td>
   <td style="text-align:left;"> 000005469 </td>
   <td style="text-align:left;"> 000002389 </td>
   <td style="text-align:left;"> 000000502 </td>
   <td style="text-align:left;"> 000006301 </td>
   <td style="text-align:left;"> 000004732 </td>
   <td style="text-align:left;"> 000005718 </td>
   <td style="text-align:left;"> 000006752 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000000346 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Waheed, Rumaana </td>
   <td style="text-align:left;"> Y655483R </td>
   <td style="text-align:left;"> 000004906 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000001123 </td>
   <td style="text-align:left;"> 000002767 </td>
   <td style="text-align:left;"> 000006481 </td>
   <td style="text-align:left;"> 000000635 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000000432 </td>
   <td style="text-align:left;"> 000005707 </td>
   <td style="text-align:left;"> 000004158 </td>
   <td style="text-align:left;"> 000002906 </td>
   <td style="text-align:left;"> 000003909 </td>
   <td style="text-align:left;"> 000001348 </td>
   <td style="text-align:left;"> 000004057 </td>
   <td style="text-align:left;"> 000001828 </td>
   <td style="text-align:left;"> 000005003 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000003928 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bailey, Corie </td>
   <td style="text-align:left;"> C510608T </td>
   <td style="text-align:left;"> 000000026 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000006947 </td>
   <td style="text-align:left;"> 000007788 </td>
   <td style="text-align:left;"> 000002508 </td>
   <td style="text-align:left;"> 000005837 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000002565 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000001710 </td>
   <td style="text-align:left;"> 000009759 </td>
   <td style="text-align:left;"> 000003227 </td>
   <td style="text-align:left;"> 000000273 </td>
   <td style="text-align:left;"> 000004359 </td>
   <td style="text-align:left;"> 000002107 </td>
   <td style="text-align:left;"> 000005865 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000003835 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mata-Lovato, Alexi </td>
   <td style="text-align:left;"> D749327B </td>
   <td style="text-align:left;"> 000000117 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000004626 </td>
   <td style="text-align:left;"> 000003618 </td>
   <td style="text-align:left;"> 000005087 </td>
   <td style="text-align:left;"> 000003105 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000003599 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000005728 </td>
   <td style="text-align:left;"> 000001522 </td>
   <td style="text-align:left;"> 000007715 </td>
   <td style="text-align:left;"> 000005157 </td>
   <td style="text-align:left;"> 000008652 </td>
   <td style="text-align:left;"> 000003860 </td>
   <td style="text-align:left;"> 000009515 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000002159 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Farrah, Jam,Aan </td>
   <td style="text-align:left;"> W704185D </td>
   <td style="text-align:left;"> 000009081 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000003943 </td>
   <td style="text-align:left;"> 000007263 </td>
   <td style="text-align:left;"> 000009296 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000004174 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000008355 </td>
   <td style="text-align:left;"> 000001680 </td>
   <td style="text-align:left;"> 000000111 </td>
   <td style="text-align:left;"> 000005638 </td>
   <td style="text-align:left;"> 000003674 </td>
   <td style="text-align:left;"> 000004643 </td>
   <td style="text-align:left;"> 000001581 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000006288 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Madrill, Arnulfo </td>
   <td style="text-align:left;"> R102458G </td>
   <td style="text-align:left;"> 000004502 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000004634 </td>
   <td style="text-align:left;"> 000005529 </td>
   <td style="text-align:left;"> 000009561 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000003118 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000002498 </td>
   <td style="text-align:left;"> 000002800 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000009035 </td>
   <td style="text-align:left;"> 000003508 </td>
   <td style="text-align:left;"> 000005438 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000006398 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Schmalz, Alyssa </td>
   <td style="text-align:left;"> C305005Z </td>
   <td style="text-align:left;"> 000003565 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000008802 </td>
   <td style="text-align:left;"> 000009178 </td>
   <td style="text-align:left;"> 000003406 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000000109 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000003986 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000002916 </td>
   <td style="text-align:left;"> 000005394 </td>
   <td style="text-align:left;"> 000007192 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000008915 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hickam, Judson </td>
   <td style="text-align:left;"> X93080P </td>
   <td style="text-align:left;"> 000003344 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000000854 </td>
   <td style="text-align:left;"> 000004223 </td>
   <td style="text-align:left;"> 000002952 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000004623 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000003724 </td>
   <td style="text-align:left;"> 000008056 </td>
   <td style="text-align:left;"> 000007007 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000001985 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garland, Lenah </td>
   <td style="text-align:left;"> E758891B </td>
   <td style="text-align:left;"> 000008275 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000005183 </td>
   <td style="text-align:left;"> 000009736 </td>
   <td style="text-align:left;"> 000005371 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000005294 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000001161 </td>
   <td style="text-align:left;"> 000004520 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000004124 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Burki, Dhaki </td>
   <td style="text-align:left;"> L978826F </td>
   <td style="text-align:left;"> 000004289 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000003696 </td>
   <td style="text-align:left;"> 000002132 </td>
   <td style="text-align:left;"> 000001980 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000009282 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000002883 </td>
   <td style="text-align:left;"> 000005529 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000003910 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riddick, Alexander </td>
   <td style="text-align:left;"> Y141885L </td>
   <td style="text-align:left;"> 000008807 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000001984 </td>
   <td style="text-align:left;"> 000000217 </td>
   <td style="text-align:left;"> 000009293 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000001245 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000004594 </td>
   <td style="text-align:left;"> 000001629 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000009571 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Quach, Kanchana </td>
   <td style="text-align:left;"> L762764J </td>
   <td style="text-align:left;"> 000006552 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000005768 </td>
   <td style="text-align:left;"> 000002915 </td>
   <td style="text-align:left;"> 000003118 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000005622 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000001518 </td>
   <td style="text-align:left;"> 000002779 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edwards, Jordan </td>
   <td style="text-align:left;"> L822113R </td>
   <td style="text-align:left;"> 000003309 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000001606 </td>
   <td style="text-align:left;"> 000008578 </td>
   <td style="text-align:left;"> 000007335 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000004720 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000000028 </td>
   <td style="text-align:left;"> 000000692 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Le, Cordelia </td>
   <td style="text-align:left;"> W169026C </td>
   <td style="text-align:left;"> 000003478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000004319 </td>
   <td style="text-align:left;"> 000005988 </td>
   <td style="text-align:left;"> 000004487 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000005045 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000002966 </td>
   <td style="text-align:left;"> 000001053 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Corning, Roget </td>
   <td style="text-align:left;"> F169524C </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000008610 </td>
   <td style="text-align:left;"> 000009951 </td>
   <td style="text-align:left;"> 000002098 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000004050 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000008032 </td>
   <td style="text-align:left;"> 000008823 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis, Sachae </td>
   <td style="text-align:left;"> F833563K </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000000886 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000004542 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000003991 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000006326 </td>
   <td style="text-align:left;"> 000001337 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Casalaina, Taylor </td>
   <td style="text-align:left;"> N747000P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000002128 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000009970 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000000373 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000009098 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wisham, Hannah </td>
   <td style="text-align:left;"> E829622B </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000004089 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000006478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 000006813 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandoval Romero, Cesar </td>
   <td style="text-align:left;"> B122528U </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000004250 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 000008100 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000007545 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mo, Tyler </td>
   <td style="text-align:left;"> B409818K </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000008595 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000005051 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 000007380 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Renfroe, Noah </td>
   <td style="text-align:left;"> W545437Y </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 000003979 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000009035 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis III, Rajon </td>
   <td style="text-align:left;"> A755450T </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000003890 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Johnson, Daijanae </td>
   <td style="text-align:left;"> H641867H </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 000007619 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lindsey, Don </td>
   <td style="text-align:left;"> K850252Q </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 000002114 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iu, Aaron </td>
   <td style="text-align:left;"> P930968J </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
</tbody>
</table></div>

## Core Process
First, create a function that removes leading zero strategically. That is if the string contains all 0 digits, I want it to return a single 0, else transform the 0s into empty string.


```r
# Define a function that trims leading zeros
lead_zero_trim <- function(x){
  x_ws_trim <- trimws(as.character(x))
  ifelse(
    str_detect(x_ws_trim, "^0+$"), 
    str_replace(x_ws_trim, "^0+$", "0"), 
    str_replace(x_ws_trim,"^0+","")
    )
}

# Check if the function works
(test <- c("  0010  ", "   678910  ", "0000000", "    0000000", "0000100000000", "000000.9910"))
```

```
## [1] "  0010  "      "   678910  "   "0000000"       "    0000000"  
## [5] "0000100000000" "000000.9910"
```

```r
lead_zero_trim(test)
```

```
## [1] "10"        "678910"    "0"         "0"         "100000000" ".9910"
```

Then, mutate at columns that start with attr_ or ada_ by detecting matches using regular expression. 


```r
# Uses tidyverse functions
test <- df %>% mutate_at(vars(matches("^(attr_|ada_|ix_)")),lead_zero_trim)

# See how df looks like now
knitr::kable(test) %>% kable_styling() %>% scroll_box(width = "100%", height = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:600px; overflow-x: scroll; width:100%; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Her, Abhinav </td>
   <td style="text-align:left;"> J959807F </td>
   <td style="text-align:left;"> 3371 </td>
   <td style="text-align:left;"> 3613 </td>
   <td style="text-align:left;"> 6093 </td>
   <td style="text-align:left;"> 3411 </td>
   <td style="text-align:left;"> 2180 </td>
   <td style="text-align:left;"> 7845 </td>
   <td style="text-align:left;"> 6874 </td>
   <td style="text-align:left;"> 8435 </td>
   <td style="text-align:left;"> 1467 </td>
   <td style="text-align:left;"> 5090 </td>
   <td style="text-align:left;"> 3554 </td>
   <td style="text-align:left;"> 7767 </td>
   <td style="text-align:left;"> 2779 </td>
   <td style="text-align:left;"> 6235 </td>
   <td style="text-align:left;"> 7309 </td>
   <td style="text-align:left;"> 7685 </td>
   <td style="text-align:left;"> 9916 </td>
   <td style="text-align:left;"> 6296 </td>
   <td style="text-align:left;"> 9787 </td>
   <td style="text-align:left;"> 6766 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dews, Shayna </td>
   <td style="text-align:left;"> G234300N </td>
   <td style="text-align:left;"> 5610 </td>
   <td style="text-align:left;"> 3265 </td>
   <td style="text-align:left;"> 6756 </td>
   <td style="text-align:left;"> 6307 </td>
   <td style="text-align:left;"> 8466 </td>
   <td style="text-align:left;"> 2395 </td>
   <td style="text-align:left;"> 285 </td>
   <td style="text-align:left;"> 4480 </td>
   <td style="text-align:left;"> 6644 </td>
   <td style="text-align:left;"> 9457 </td>
   <td style="text-align:left;"> 8418 </td>
   <td style="text-align:left;"> 8782 </td>
   <td style="text-align:left;"> 5735 </td>
   <td style="text-align:left;"> 6464 </td>
   <td style="text-align:left;"> 5551 </td>
   <td style="text-align:left;"> 5849 </td>
   <td style="text-align:left;"> 7345 </td>
   <td style="text-align:left;"> 4872 </td>
   <td style="text-align:left;"> 9102 </td>
   <td style="text-align:left;"> 5902 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kiefer, Tasia </td>
   <td style="text-align:left;"> B803488K </td>
   <td style="text-align:left;"> 2973 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 2878 </td>
   <td style="text-align:left;"> 7659 </td>
   <td style="text-align:left;"> 2812 </td>
   <td style="text-align:left;"> 3928 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 7907 </td>
   <td style="text-align:left;"> 3931 </td>
   <td style="text-align:left;"> 1124 </td>
   <td style="text-align:left;"> 7705 </td>
   <td style="text-align:left;"> 2425 </td>
   <td style="text-align:left;"> 464 </td>
   <td style="text-align:left;"> 8656 </td>
   <td style="text-align:left;"> 6109 </td>
   <td style="text-align:left;"> 3763 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 8821 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Watchman, Andrew </td>
   <td style="text-align:left;"> O787540P </td>
   <td style="text-align:left;"> 9621 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 1979 </td>
   <td style="text-align:left;"> 9455 </td>
   <td style="text-align:left;"> 3813 </td>
   <td style="text-align:left;"> 6375 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 686 </td>
   <td style="text-align:left;"> 2134 </td>
   <td style="text-align:left;"> 7035 </td>
   <td style="text-align:left;"> 9627 </td>
   <td style="text-align:left;"> 560 </td>
   <td style="text-align:left;"> 6997 </td>
   <td style="text-align:left;"> 3332 </td>
   <td style="text-align:left;"> 8448 </td>
   <td style="text-align:left;"> 638 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 4018 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Massara, Abigail </td>
   <td style="text-align:left;"> T486795I </td>
   <td style="text-align:left;"> 8575 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 5560 </td>
   <td style="text-align:left;"> 4280 </td>
   <td style="text-align:left;"> 9219 </td>
   <td style="text-align:left;"> 1598 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 1970 </td>
   <td style="text-align:left;"> 3871 </td>
   <td style="text-align:left;"> 1056 </td>
   <td style="text-align:left;"> 9648 </td>
   <td style="text-align:left;"> 722 </td>
   <td style="text-align:left;"> 6797 </td>
   <td style="text-align:left;"> 5078 </td>
   <td style="text-align:left;"> 4767 </td>
   <td style="text-align:left;"> 9904 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 5505 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tran, Thomas </td>
   <td style="text-align:left;"> E410468Z </td>
   <td style="text-align:left;"> 3963 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 5599 </td>
   <td style="text-align:left;"> 6215 </td>
   <td style="text-align:left;"> 2304 </td>
   <td style="text-align:left;"> 5753 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 462 </td>
   <td style="text-align:left;"> 1652 </td>
   <td style="text-align:left;"> 5469 </td>
   <td style="text-align:left;"> 2389 </td>
   <td style="text-align:left;"> 502 </td>
   <td style="text-align:left;"> 6301 </td>
   <td style="text-align:left;"> 4732 </td>
   <td style="text-align:left;"> 5718 </td>
   <td style="text-align:left;"> 6752 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 346 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Waheed, Rumaana </td>
   <td style="text-align:left;"> Y655483R </td>
   <td style="text-align:left;"> 4906 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 1123 </td>
   <td style="text-align:left;"> 2767 </td>
   <td style="text-align:left;"> 6481 </td>
   <td style="text-align:left;"> 635 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 432 </td>
   <td style="text-align:left;"> 5707 </td>
   <td style="text-align:left;"> 4158 </td>
   <td style="text-align:left;"> 2906 </td>
   <td style="text-align:left;"> 3909 </td>
   <td style="text-align:left;"> 1348 </td>
   <td style="text-align:left;"> 4057 </td>
   <td style="text-align:left;"> 1828 </td>
   <td style="text-align:left;"> 5003 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 3928 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bailey, Corie </td>
   <td style="text-align:left;"> C510608T </td>
   <td style="text-align:left;"> 26 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 6947 </td>
   <td style="text-align:left;"> 7788 </td>
   <td style="text-align:left;"> 2508 </td>
   <td style="text-align:left;"> 5837 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 2565 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1710 </td>
   <td style="text-align:left;"> 9759 </td>
   <td style="text-align:left;"> 3227 </td>
   <td style="text-align:left;"> 273 </td>
   <td style="text-align:left;"> 4359 </td>
   <td style="text-align:left;"> 2107 </td>
   <td style="text-align:left;"> 5865 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3835 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mata-Lovato, Alexi </td>
   <td style="text-align:left;"> D749327B </td>
   <td style="text-align:left;"> 117 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 4626 </td>
   <td style="text-align:left;"> 3618 </td>
   <td style="text-align:left;"> 5087 </td>
   <td style="text-align:left;"> 3105 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 3599 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 5728 </td>
   <td style="text-align:left;"> 1522 </td>
   <td style="text-align:left;"> 7715 </td>
   <td style="text-align:left;"> 5157 </td>
   <td style="text-align:left;"> 8652 </td>
   <td style="text-align:left;"> 3860 </td>
   <td style="text-align:left;"> 9515 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 2159 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Farrah, Jam,Aan </td>
   <td style="text-align:left;"> W704185D </td>
   <td style="text-align:left;"> 9081 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 3943 </td>
   <td style="text-align:left;"> 7263 </td>
   <td style="text-align:left;"> 9296 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4174 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 8355 </td>
   <td style="text-align:left;"> 1680 </td>
   <td style="text-align:left;"> 111 </td>
   <td style="text-align:left;"> 5638 </td>
   <td style="text-align:left;"> 3674 </td>
   <td style="text-align:left;"> 4643 </td>
   <td style="text-align:left;"> 1581 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 6288 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Madrill, Arnulfo </td>
   <td style="text-align:left;"> R102458G </td>
   <td style="text-align:left;"> 4502 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 4634 </td>
   <td style="text-align:left;"> 5529 </td>
   <td style="text-align:left;"> 9561 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 3118 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 2498 </td>
   <td style="text-align:left;"> 2800 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 9035 </td>
   <td style="text-align:left;"> 3508 </td>
   <td style="text-align:left;"> 5438 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 6398 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Schmalz, Alyssa </td>
   <td style="text-align:left;"> C305005Z </td>
   <td style="text-align:left;"> 3565 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 8802 </td>
   <td style="text-align:left;"> 9178 </td>
   <td style="text-align:left;"> 3406 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 109 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 3986 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 2916 </td>
   <td style="text-align:left;"> 5394 </td>
   <td style="text-align:left;"> 7192 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 8915 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hickam, Judson </td>
   <td style="text-align:left;"> X93080P </td>
   <td style="text-align:left;"> 3344 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 854 </td>
   <td style="text-align:left;"> 4223 </td>
   <td style="text-align:left;"> 2952 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 4623 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 3724 </td>
   <td style="text-align:left;"> 8056 </td>
   <td style="text-align:left;"> 7007 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1985 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garland, Lenah </td>
   <td style="text-align:left;"> E758891B </td>
   <td style="text-align:left;"> 8275 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 5183 </td>
   <td style="text-align:left;"> 9736 </td>
   <td style="text-align:left;"> 5371 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 5294 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 1161 </td>
   <td style="text-align:left;"> 4520 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 4124 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Burki, Dhaki </td>
   <td style="text-align:left;"> L978826F </td>
   <td style="text-align:left;"> 4289 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 3696 </td>
   <td style="text-align:left;"> 2132 </td>
   <td style="text-align:left;"> 1980 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 9282 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 2883 </td>
   <td style="text-align:left;"> 5529 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3910 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riddick, Alexander </td>
   <td style="text-align:left;"> Y141885L </td>
   <td style="text-align:left;"> 8807 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1984 </td>
   <td style="text-align:left;"> 217 </td>
   <td style="text-align:left;"> 9293 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1245 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 4594 </td>
   <td style="text-align:left;"> 1629 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 9571 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Quach, Kanchana </td>
   <td style="text-align:left;"> L762764J </td>
   <td style="text-align:left;"> 6552 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 5768 </td>
   <td style="text-align:left;"> 2915 </td>
   <td style="text-align:left;"> 3118 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 5622 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1518 </td>
   <td style="text-align:left;"> 2779 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edwards, Jordan </td>
   <td style="text-align:left;"> L822113R </td>
   <td style="text-align:left;"> 3309 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1606 </td>
   <td style="text-align:left;"> 8578 </td>
   <td style="text-align:left;"> 7335 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 4720 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 28 </td>
   <td style="text-align:left;"> 692 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Le, Cordelia </td>
   <td style="text-align:left;"> W169026C </td>
   <td style="text-align:left;"> 3478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4319 </td>
   <td style="text-align:left;"> 5988 </td>
   <td style="text-align:left;"> 4487 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 5045 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 2966 </td>
   <td style="text-align:left;"> 1053 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Corning, Roget </td>
   <td style="text-align:left;"> F169524C </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 8610 </td>
   <td style="text-align:left;"> 9951 </td>
   <td style="text-align:left;"> 2098 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4050 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 8032 </td>
   <td style="text-align:left;"> 8823 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis, Sachae </td>
   <td style="text-align:left;"> F833563K </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 886 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 4542 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 3991 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 6326 </td>
   <td style="text-align:left;"> 1337 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Casalaina, Taylor </td>
   <td style="text-align:left;"> N747000P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 2128 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9970 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 373 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 9098 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wisham, Hannah </td>
   <td style="text-align:left;"> E829622B </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4089 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 6478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 6813 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandoval Romero, Cesar </td>
   <td style="text-align:left;"> B122528U </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 4250 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 8100 </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 7545 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mo, Tyler </td>
   <td style="text-align:left;"> B409818K </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 8595 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 5051 </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> 7380 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Renfroe, Noah </td>
   <td style="text-align:left;"> W545437Y </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> 3979 </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 9035 </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis III, Rajon </td>
   <td style="text-align:left;"> A755450T </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 3890 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Johnson, Daijanae </td>
   <td style="text-align:left;"> H641867H </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> 7619 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lindsey, Don </td>
   <td style="text-align:left;"> K850252Q </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> 2114 </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iu, Aaron </td>
   <td style="text-align:left;"> P930968J </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> N </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> S </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> P </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;"> O </td>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
</tbody>
</table></div>

You can see that strings that are ("", NA, or character only) remain intact as before. The function only transform those with leading zeros.<br>

Now, we would want to convert these digit strings into numeric columns.


```r
# Dot . inherits the object after the pipe. i.e. individual column
# Wrap the result from lead_zer0_trim(.) with as.numeric and turn the process into a temp function by funs()
test <- df %>% mutate_at(vars(matches("^(attr_|ada_|ix_)")),funs(as.numeric(lead_zero_trim(.))))

# See how df looks like now
knitr::kable(test) %>% kable_styling() %>% scroll_box(width = "100%", height = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:600px; overflow-x: scroll; width:100%; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> id </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_1 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_2 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_3 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_4 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_5 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_6 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_7 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_8 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_9 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> attr_10 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_1 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_2 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_3 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_4 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_5 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_6 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_7 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_8 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_9 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ada_10 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ix_1 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> ix_2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Her, Abhinav </td>
   <td style="text-align:left;"> J959807F </td>
   <td style="text-align:right;"> 3371 </td>
   <td style="text-align:right;"> 3613 </td>
   <td style="text-align:right;"> 6093 </td>
   <td style="text-align:right;"> 3411 </td>
   <td style="text-align:right;"> 2180 </td>
   <td style="text-align:right;"> 7845 </td>
   <td style="text-align:right;"> 6874 </td>
   <td style="text-align:right;"> 8435 </td>
   <td style="text-align:right;"> 1467 </td>
   <td style="text-align:right;"> 5090 </td>
   <td style="text-align:right;"> 3554 </td>
   <td style="text-align:right;"> 7767 </td>
   <td style="text-align:right;"> 2779 </td>
   <td style="text-align:right;"> 6235 </td>
   <td style="text-align:right;"> 7309 </td>
   <td style="text-align:right;"> 7685 </td>
   <td style="text-align:right;"> 9916 </td>
   <td style="text-align:right;"> 6296 </td>
   <td style="text-align:right;"> 9787 </td>
   <td style="text-align:right;"> 6766 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dews, Shayna </td>
   <td style="text-align:left;"> G234300N </td>
   <td style="text-align:right;"> 5610 </td>
   <td style="text-align:right;"> 3265 </td>
   <td style="text-align:right;"> 6756 </td>
   <td style="text-align:right;"> 6307 </td>
   <td style="text-align:right;"> 8466 </td>
   <td style="text-align:right;"> 2395 </td>
   <td style="text-align:right;"> 285 </td>
   <td style="text-align:right;"> 4480 </td>
   <td style="text-align:right;"> 6644 </td>
   <td style="text-align:right;"> 9457 </td>
   <td style="text-align:right;"> 8418 </td>
   <td style="text-align:right;"> 8782 </td>
   <td style="text-align:right;"> 5735 </td>
   <td style="text-align:right;"> 6464 </td>
   <td style="text-align:right;"> 5551 </td>
   <td style="text-align:right;"> 5849 </td>
   <td style="text-align:right;"> 7345 </td>
   <td style="text-align:right;"> 4872 </td>
   <td style="text-align:right;"> 9102 </td>
   <td style="text-align:right;"> 5902 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kiefer, Tasia </td>
   <td style="text-align:left;"> B803488K </td>
   <td style="text-align:right;"> 2973 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2878 </td>
   <td style="text-align:right;"> 7659 </td>
   <td style="text-align:right;"> 2812 </td>
   <td style="text-align:right;"> 3928 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 7907 </td>
   <td style="text-align:right;"> 3931 </td>
   <td style="text-align:right;"> 1124 </td>
   <td style="text-align:right;"> 7705 </td>
   <td style="text-align:right;"> 2425 </td>
   <td style="text-align:right;"> 464 </td>
   <td style="text-align:right;"> 8656 </td>
   <td style="text-align:right;"> 6109 </td>
   <td style="text-align:right;"> 3763 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8821 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Watchman, Andrew </td>
   <td style="text-align:left;"> O787540P </td>
   <td style="text-align:right;"> 9621 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1979 </td>
   <td style="text-align:right;"> 9455 </td>
   <td style="text-align:right;"> 3813 </td>
   <td style="text-align:right;"> 6375 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 686 </td>
   <td style="text-align:right;"> 2134 </td>
   <td style="text-align:right;"> 7035 </td>
   <td style="text-align:right;"> 9627 </td>
   <td style="text-align:right;"> 560 </td>
   <td style="text-align:right;"> 6997 </td>
   <td style="text-align:right;"> 3332 </td>
   <td style="text-align:right;"> 8448 </td>
   <td style="text-align:right;"> 638 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4018 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Massara, Abigail </td>
   <td style="text-align:left;"> T486795I </td>
   <td style="text-align:right;"> 8575 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5560 </td>
   <td style="text-align:right;"> 4280 </td>
   <td style="text-align:right;"> 9219 </td>
   <td style="text-align:right;"> 1598 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1970 </td>
   <td style="text-align:right;"> 3871 </td>
   <td style="text-align:right;"> 1056 </td>
   <td style="text-align:right;"> 9648 </td>
   <td style="text-align:right;"> 722 </td>
   <td style="text-align:right;"> 6797 </td>
   <td style="text-align:right;"> 5078 </td>
   <td style="text-align:right;"> 4767 </td>
   <td style="text-align:right;"> 9904 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5505 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tran, Thomas </td>
   <td style="text-align:left;"> E410468Z </td>
   <td style="text-align:right;"> 3963 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5599 </td>
   <td style="text-align:right;"> 6215 </td>
   <td style="text-align:right;"> 2304 </td>
   <td style="text-align:right;"> 5753 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 462 </td>
   <td style="text-align:right;"> 1652 </td>
   <td style="text-align:right;"> 5469 </td>
   <td style="text-align:right;"> 2389 </td>
   <td style="text-align:right;"> 502 </td>
   <td style="text-align:right;"> 6301 </td>
   <td style="text-align:right;"> 4732 </td>
   <td style="text-align:right;"> 5718 </td>
   <td style="text-align:right;"> 6752 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 346 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Waheed, Rumaana </td>
   <td style="text-align:left;"> Y655483R </td>
   <td style="text-align:right;"> 4906 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1123 </td>
   <td style="text-align:right;"> 2767 </td>
   <td style="text-align:right;"> 6481 </td>
   <td style="text-align:right;"> 635 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 432 </td>
   <td style="text-align:right;"> 5707 </td>
   <td style="text-align:right;"> 4158 </td>
   <td style="text-align:right;"> 2906 </td>
   <td style="text-align:right;"> 3909 </td>
   <td style="text-align:right;"> 1348 </td>
   <td style="text-align:right;"> 4057 </td>
   <td style="text-align:right;"> 1828 </td>
   <td style="text-align:right;"> 5003 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3928 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bailey, Corie </td>
   <td style="text-align:left;"> C510608T </td>
   <td style="text-align:right;"> 26 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6947 </td>
   <td style="text-align:right;"> 7788 </td>
   <td style="text-align:right;"> 2508 </td>
   <td style="text-align:right;"> 5837 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2565 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1710 </td>
   <td style="text-align:right;"> 9759 </td>
   <td style="text-align:right;"> 3227 </td>
   <td style="text-align:right;"> 273 </td>
   <td style="text-align:right;"> 4359 </td>
   <td style="text-align:right;"> 2107 </td>
   <td style="text-align:right;"> 5865 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3835 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mata-Lovato, Alexi </td>
   <td style="text-align:left;"> D749327B </td>
   <td style="text-align:right;"> 117 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4626 </td>
   <td style="text-align:right;"> 3618 </td>
   <td style="text-align:right;"> 5087 </td>
   <td style="text-align:right;"> 3105 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3599 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5728 </td>
   <td style="text-align:right;"> 1522 </td>
   <td style="text-align:right;"> 7715 </td>
   <td style="text-align:right;"> 5157 </td>
   <td style="text-align:right;"> 8652 </td>
   <td style="text-align:right;"> 3860 </td>
   <td style="text-align:right;"> 9515 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2159 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Farrah, Jam,Aan </td>
   <td style="text-align:left;"> W704185D </td>
   <td style="text-align:right;"> 9081 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3943 </td>
   <td style="text-align:right;"> 7263 </td>
   <td style="text-align:right;"> 9296 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4174 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8355 </td>
   <td style="text-align:right;"> 1680 </td>
   <td style="text-align:right;"> 111 </td>
   <td style="text-align:right;"> 5638 </td>
   <td style="text-align:right;"> 3674 </td>
   <td style="text-align:right;"> 4643 </td>
   <td style="text-align:right;"> 1581 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6288 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Madrill, Arnulfo </td>
   <td style="text-align:left;"> R102458G </td>
   <td style="text-align:right;"> 4502 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4634 </td>
   <td style="text-align:right;"> 5529 </td>
   <td style="text-align:right;"> 9561 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3118 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2498 </td>
   <td style="text-align:right;"> 2800 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9035 </td>
   <td style="text-align:right;"> 3508 </td>
   <td style="text-align:right;"> 5438 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6398 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Schmalz, Alyssa </td>
   <td style="text-align:left;"> C305005Z </td>
   <td style="text-align:right;"> 3565 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8802 </td>
   <td style="text-align:right;"> 9178 </td>
   <td style="text-align:right;"> 3406 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 109 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3986 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2916 </td>
   <td style="text-align:right;"> 5394 </td>
   <td style="text-align:right;"> 7192 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8915 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hickam, Judson </td>
   <td style="text-align:left;"> X93080P </td>
   <td style="text-align:right;"> 3344 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 854 </td>
   <td style="text-align:right;"> 4223 </td>
   <td style="text-align:right;"> 2952 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4623 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3724 </td>
   <td style="text-align:right;"> 8056 </td>
   <td style="text-align:right;"> 7007 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1985 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garland, Lenah </td>
   <td style="text-align:left;"> E758891B </td>
   <td style="text-align:right;"> 8275 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5183 </td>
   <td style="text-align:right;"> 9736 </td>
   <td style="text-align:right;"> 5371 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5294 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1161 </td>
   <td style="text-align:right;"> 4520 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4124 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Burki, Dhaki </td>
   <td style="text-align:left;"> L978826F </td>
   <td style="text-align:right;"> 4289 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3696 </td>
   <td style="text-align:right;"> 2132 </td>
   <td style="text-align:right;"> 1980 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9282 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2883 </td>
   <td style="text-align:right;"> 5529 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3910 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riddick, Alexander </td>
   <td style="text-align:left;"> Y141885L </td>
   <td style="text-align:right;"> 8807 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1984 </td>
   <td style="text-align:right;"> 217 </td>
   <td style="text-align:right;"> 9293 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1245 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4594 </td>
   <td style="text-align:right;"> 1629 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9571 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Quach, Kanchana </td>
   <td style="text-align:left;"> L762764J </td>
   <td style="text-align:right;"> 6552 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5768 </td>
   <td style="text-align:right;"> 2915 </td>
   <td style="text-align:right;"> 3118 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5622 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1518 </td>
   <td style="text-align:right;"> 2779 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edwards, Jordan </td>
   <td style="text-align:left;"> L822113R </td>
   <td style="text-align:right;"> 3309 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 1606 </td>
   <td style="text-align:right;"> 8578 </td>
   <td style="text-align:right;"> 7335 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4720 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 28 </td>
   <td style="text-align:right;"> 692 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Le, Cordelia </td>
   <td style="text-align:left;"> W169026C </td>
   <td style="text-align:right;"> 3478 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4319 </td>
   <td style="text-align:right;"> 5988 </td>
   <td style="text-align:right;"> 4487 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5045 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2966 </td>
   <td style="text-align:right;"> 1053 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Corning, Roget </td>
   <td style="text-align:left;"> F169524C </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8610 </td>
   <td style="text-align:right;"> 9951 </td>
   <td style="text-align:right;"> 2098 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4050 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8032 </td>
   <td style="text-align:right;"> 8823 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis, Sachae </td>
   <td style="text-align:left;"> F833563K </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 886 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4542 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3991 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6326 </td>
   <td style="text-align:right;"> 1337 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Casalaina, Taylor </td>
   <td style="text-align:left;"> N747000P </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2128 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9970 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 373 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9098 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wisham, Hannah </td>
   <td style="text-align:left;"> E829622B </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4089 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6478 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 6813 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandoval Romero, Cesar </td>
   <td style="text-align:left;"> B122528U </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 4250 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8100 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 7545 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mo, Tyler </td>
   <td style="text-align:left;"> B409818K </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 8595 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 5051 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 7380 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Renfroe, Noah </td>
   <td style="text-align:left;"> W545437Y </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3979 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 9035 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis III, Rajon </td>
   <td style="text-align:left;"> A755450T </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 3890 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Johnson, Daijanae </td>
   <td style="text-align:left;"> H641867H </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 7619 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lindsey, Don </td>
   <td style="text-align:left;"> K850252Q </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> 2114 </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iu, Aaron </td>
   <td style="text-align:left;"> P930968J </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
   <td style="text-align:right;"> NA </td>
  </tr>
</tbody>
</table></div>

Oops! The as.numeric() turn those strings into NA, which we don't want.<br>
That means we have to transform those mixed-in chacters (e.g. N, O, P, S) into NA or some meaningful numbers. Then, depending on whether the column contains pure digits, apply as.numeric on them, but skip the ones containing only characters.


```r
# Define another function to check if it contains at least 1 row of proper number
is.proper.number <- function(x){
  str_detect(x, "^[0-9]*(\\.[0-9]*)?$")
}

# Check if it works
test <- c("1000", "0.1000", "10002", "123.444", "123.")
is.proper.number(test)
```

```
## [1] TRUE TRUE TRUE TRUE TRUE
```
Putting all together.

```r
# Combine all these functions into 1 wrangle function
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

test <- df %>% mutate_at(vars(matches("^(attr_|ada_|ix_)")),ig_wrangle)

# See how df looks like now
knitr::kable(test) %>% kable_styling() %>% scroll_box(width = "100%", height = "600px")
```

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:600px; overflow-x: scroll; width:100%; "><table class="table" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> attr_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_3 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_4 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_5 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_6 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_7 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_8 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_9 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ada_10 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_1 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> ix_2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Her, Abhinav </td>
   <td style="text-align:left;"> J959807F </td>
   <td style="text-align:left;"> 3371 </td>
   <td style="text-align:left;"> 3613 </td>
   <td style="text-align:left;"> 6093 </td>
   <td style="text-align:left;"> 3411 </td>
   <td style="text-align:left;"> 2180 </td>
   <td style="text-align:left;"> 7845 </td>
   <td style="text-align:left;"> 6874 </td>
   <td style="text-align:left;"> 8435 </td>
   <td style="text-align:left;"> 1467 </td>
   <td style="text-align:left;"> 5090 </td>
   <td style="text-align:left;"> 3554 </td>
   <td style="text-align:left;"> 7767 </td>
   <td style="text-align:left;"> 2779 </td>
   <td style="text-align:left;"> 6235 </td>
   <td style="text-align:left;"> 7309 </td>
   <td style="text-align:left;"> 7685 </td>
   <td style="text-align:left;"> 9916 </td>
   <td style="text-align:left;"> 6296 </td>
   <td style="text-align:left;"> 9787 </td>
   <td style="text-align:left;"> 6766 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Dews, Shayna </td>
   <td style="text-align:left;"> G234300N </td>
   <td style="text-align:left;"> 5610 </td>
   <td style="text-align:left;"> 3265 </td>
   <td style="text-align:left;"> 6756 </td>
   <td style="text-align:left;"> 6307 </td>
   <td style="text-align:left;"> 8466 </td>
   <td style="text-align:left;"> 2395 </td>
   <td style="text-align:left;"> 285 </td>
   <td style="text-align:left;"> 4480 </td>
   <td style="text-align:left;"> 6644 </td>
   <td style="text-align:left;"> 9457 </td>
   <td style="text-align:left;"> 8418 </td>
   <td style="text-align:left;"> 8782 </td>
   <td style="text-align:left;"> 5735 </td>
   <td style="text-align:left;"> 6464 </td>
   <td style="text-align:left;"> 5551 </td>
   <td style="text-align:left;"> 5849 </td>
   <td style="text-align:left;"> 7345 </td>
   <td style="text-align:left;"> 4872 </td>
   <td style="text-align:left;"> 9102 </td>
   <td style="text-align:left;"> 5902 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Kiefer, Tasia </td>
   <td style="text-align:left;"> B803488K </td>
   <td style="text-align:left;"> 2973 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 2878 </td>
   <td style="text-align:left;"> 7659 </td>
   <td style="text-align:left;"> 2812 </td>
   <td style="text-align:left;"> 3928 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 7907 </td>
   <td style="text-align:left;"> 3931 </td>
   <td style="text-align:left;"> 1124 </td>
   <td style="text-align:left;"> 7705 </td>
   <td style="text-align:left;"> 2425 </td>
   <td style="text-align:left;"> 464 </td>
   <td style="text-align:left;"> 8656 </td>
   <td style="text-align:left;"> 6109 </td>
   <td style="text-align:left;"> 3763 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 8821 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Watchman, Andrew </td>
   <td style="text-align:left;"> O787540P </td>
   <td style="text-align:left;"> 9621 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1979 </td>
   <td style="text-align:left;"> 9455 </td>
   <td style="text-align:left;"> 3813 </td>
   <td style="text-align:left;"> 6375 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 686 </td>
   <td style="text-align:left;"> 2134 </td>
   <td style="text-align:left;"> 7035 </td>
   <td style="text-align:left;"> 9627 </td>
   <td style="text-align:left;"> 560 </td>
   <td style="text-align:left;"> 6997 </td>
   <td style="text-align:left;"> 3332 </td>
   <td style="text-align:left;"> 8448 </td>
   <td style="text-align:left;"> 638 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 4018 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Massara, Abigail </td>
   <td style="text-align:left;"> T486795I </td>
   <td style="text-align:left;"> 8575 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 5560 </td>
   <td style="text-align:left;"> 4280 </td>
   <td style="text-align:left;"> 9219 </td>
   <td style="text-align:left;"> 1598 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1970 </td>
   <td style="text-align:left;"> 3871 </td>
   <td style="text-align:left;"> 1056 </td>
   <td style="text-align:left;"> 9648 </td>
   <td style="text-align:left;"> 722 </td>
   <td style="text-align:left;"> 6797 </td>
   <td style="text-align:left;"> 5078 </td>
   <td style="text-align:left;"> 4767 </td>
   <td style="text-align:left;"> 9904 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 5505 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Tran, Thomas </td>
   <td style="text-align:left;"> E410468Z </td>
   <td style="text-align:left;"> 3963 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 5599 </td>
   <td style="text-align:left;"> 6215 </td>
   <td style="text-align:left;"> 2304 </td>
   <td style="text-align:left;"> 5753 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 462 </td>
   <td style="text-align:left;"> 1652 </td>
   <td style="text-align:left;"> 5469 </td>
   <td style="text-align:left;"> 2389 </td>
   <td style="text-align:left;"> 502 </td>
   <td style="text-align:left;"> 6301 </td>
   <td style="text-align:left;"> 4732 </td>
   <td style="text-align:left;"> 5718 </td>
   <td style="text-align:left;"> 6752 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 346 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Waheed, Rumaana </td>
   <td style="text-align:left;"> Y655483R </td>
   <td style="text-align:left;"> 4906 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1123 </td>
   <td style="text-align:left;"> 2767 </td>
   <td style="text-align:left;"> 6481 </td>
   <td style="text-align:left;"> 635 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 432 </td>
   <td style="text-align:left;"> 5707 </td>
   <td style="text-align:left;"> 4158 </td>
   <td style="text-align:left;"> 2906 </td>
   <td style="text-align:left;"> 3909 </td>
   <td style="text-align:left;"> 1348 </td>
   <td style="text-align:left;"> 4057 </td>
   <td style="text-align:left;"> 1828 </td>
   <td style="text-align:left;"> 5003 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 3928 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Bailey, Corie </td>
   <td style="text-align:left;"> C510608T </td>
   <td style="text-align:left;"> 26 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 6947 </td>
   <td style="text-align:left;"> 7788 </td>
   <td style="text-align:left;"> 2508 </td>
   <td style="text-align:left;"> 5837 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 2565 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1710 </td>
   <td style="text-align:left;"> 9759 </td>
   <td style="text-align:left;"> 3227 </td>
   <td style="text-align:left;"> 273 </td>
   <td style="text-align:left;"> 4359 </td>
   <td style="text-align:left;"> 2107 </td>
   <td style="text-align:left;"> 5865 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 3835 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mata-Lovato, Alexi </td>
   <td style="text-align:left;"> D749327B </td>
   <td style="text-align:left;"> 117 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 4626 </td>
   <td style="text-align:left;"> 3618 </td>
   <td style="text-align:left;"> 5087 </td>
   <td style="text-align:left;"> 3105 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3599 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 5728 </td>
   <td style="text-align:left;"> 1522 </td>
   <td style="text-align:left;"> 7715 </td>
   <td style="text-align:left;"> 5157 </td>
   <td style="text-align:left;"> 8652 </td>
   <td style="text-align:left;"> 3860 </td>
   <td style="text-align:left;"> 9515 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 2159 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Farrah, Jam,Aan </td>
   <td style="text-align:left;"> W704185D </td>
   <td style="text-align:left;"> 9081 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 3943 </td>
   <td style="text-align:left;"> 7263 </td>
   <td style="text-align:left;"> 9296 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4174 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 8355 </td>
   <td style="text-align:left;"> 1680 </td>
   <td style="text-align:left;"> 111 </td>
   <td style="text-align:left;"> 5638 </td>
   <td style="text-align:left;"> 3674 </td>
   <td style="text-align:left;"> 4643 </td>
   <td style="text-align:left;"> 1581 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 6288 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Madrill, Arnulfo </td>
   <td style="text-align:left;"> R102458G </td>
   <td style="text-align:left;"> 4502 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 4634 </td>
   <td style="text-align:left;"> 5529 </td>
   <td style="text-align:left;"> 9561 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 3118 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 2498 </td>
   <td style="text-align:left;"> 2800 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9035 </td>
   <td style="text-align:left;"> 3508 </td>
   <td style="text-align:left;"> 5438 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 6398 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Schmalz, Alyssa </td>
   <td style="text-align:left;"> C305005Z </td>
   <td style="text-align:left;"> 3565 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 8802 </td>
   <td style="text-align:left;"> 9178 </td>
   <td style="text-align:left;"> 3406 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 109 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 3986 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 2916 </td>
   <td style="text-align:left;"> 5394 </td>
   <td style="text-align:left;"> 7192 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 8915 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Hickam, Judson </td>
   <td style="text-align:left;"> X93080P </td>
   <td style="text-align:left;"> 3344 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 854 </td>
   <td style="text-align:left;"> 4223 </td>
   <td style="text-align:left;"> 2952 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 4623 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3724 </td>
   <td style="text-align:left;"> 8056 </td>
   <td style="text-align:left;"> 7007 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1985 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Garland, Lenah </td>
   <td style="text-align:left;"> E758891B </td>
   <td style="text-align:left;"> 8275 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 5183 </td>
   <td style="text-align:left;"> 9736 </td>
   <td style="text-align:left;"> 5371 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 5294 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1161 </td>
   <td style="text-align:left;"> 4520 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 4124 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> al-Burki, Dhaki </td>
   <td style="text-align:left;"> L978826F </td>
   <td style="text-align:left;"> 4289 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 3696 </td>
   <td style="text-align:left;"> 2132 </td>
   <td style="text-align:left;"> 1980 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9282 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 2883 </td>
   <td style="text-align:left;"> 5529 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 3910 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Riddick, Alexander </td>
   <td style="text-align:left;"> Y141885L </td>
   <td style="text-align:left;"> 8807 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1984 </td>
   <td style="text-align:left;"> 217 </td>
   <td style="text-align:left;"> 9293 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1245 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 4594 </td>
   <td style="text-align:left;"> 1629 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9571 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Quach, Kanchana </td>
   <td style="text-align:left;"> L762764J </td>
   <td style="text-align:left;"> 6552 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 5768 </td>
   <td style="text-align:left;"> 2915 </td>
   <td style="text-align:left;"> 3118 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 5622 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1518 </td>
   <td style="text-align:left;"> 2779 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Edwards, Jordan </td>
   <td style="text-align:left;"> L822113R </td>
   <td style="text-align:left;"> 3309 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1606 </td>
   <td style="text-align:left;"> 8578 </td>
   <td style="text-align:left;"> 7335 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 4720 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 28 </td>
   <td style="text-align:left;"> 692 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Le, Cordelia </td>
   <td style="text-align:left;"> W169026C </td>
   <td style="text-align:left;"> 3478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4319 </td>
   <td style="text-align:left;"> 5988 </td>
   <td style="text-align:left;"> 4487 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 5045 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 2966 </td>
   <td style="text-align:left;"> 1053 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Corning, Roget </td>
   <td style="text-align:left;"> F169524C </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 8610 </td>
   <td style="text-align:left;"> 9951 </td>
   <td style="text-align:left;"> 2098 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4050 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 8032 </td>
   <td style="text-align:left;"> 8823 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis, Sachae </td>
   <td style="text-align:left;"> F833563K </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 886 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4542 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3991 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 6326 </td>
   <td style="text-align:left;"> 1337 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Casalaina, Taylor </td>
   <td style="text-align:left;"> N747000P </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 2128 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9970 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 373 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9098 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Wisham, Hannah </td>
   <td style="text-align:left;"> E829622B </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 4089 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 6478 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 6813 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Sandoval Romero, Cesar </td>
   <td style="text-align:left;"> B122528U </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 4250 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 8100 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 7545 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Mo, Tyler </td>
   <td style="text-align:left;"> B409818K </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 8595 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 5051 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 7380 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> South </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Renfroe, Noah </td>
   <td style="text-align:left;"> W545437Y </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 3979 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9035 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> North </td>
   <td style="text-align:left;"> 5E6F </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lewis III, Rajon </td>
   <td style="text-align:left;"> A755450T </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 3890 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Johnson, Daijanae </td>
   <td style="text-align:left;"> H641867H </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 7619 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 8G9H </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lindsey, Don </td>
   <td style="text-align:left;"> K850252Q </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 2114 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> West </td>
   <td style="text-align:left;"> 1A2B </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Iu, Aaron </td>
   <td style="text-align:left;"> P930968J </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 9999 </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> 999 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> 99 </td>
   <td style="text-align:left;"> NA </td>
   <td style="text-align:left;"> East </td>
   <td style="text-align:left;"> 3C4D </td>
  </tr>
</tbody>
</table></div>
You can see that ix_1 and ix_2 remain as character string instead of turning into NA. The N, O, P, S are converted to meaningful numbers, with the missing still defined as missing. 

## Creating a holistic function

```r
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

# Test
test2 <- ig_df_wrangle(df, "attr_|ada_|ix_")
# This will apply the ig_wrangle function to columns that starts with attr_, ada_ or ix_
```

