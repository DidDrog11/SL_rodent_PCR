# We load packages we need
if (!require("pacman")) install.packages("pacman")
pkgs = 
  c("here",
    "genbankr", 
    "ape",
    "rentrez",
    "readr",
    "readxl",
    "insect",
    "tidyverse",
    "seqinr"
  )
pacman::p_load(pkgs, character.only = T)

# We use an API to download the data from LASV related accession codes
entrez_key <- rstudioapi::askForSecret("entrez API key")
google_key <- rstudioapi::askForSecret("Google API key")
