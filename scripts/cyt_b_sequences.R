species_data <- readRDS("C:/Users/ucbtds4/R_Repositories/scoping_review/data_clean/species_data.rds")

forward_primer <- "TACCATGAGGACAAATATCATTCTG"
reverse_primer <- "CCTCCTAGTTTGTTAGGGATTGATCG"

potential_species <- species_data %>%
  filter(country %in% c("Guinea", "Liberia", "Sierra Leone")) %>%
  filter(species != "") %>%
  filter(!grepl("/", classification)) %>%
  group_by(classification) %>%
  summarise(species_n = n()) %>%
  arrange(-species_n) %>%
  head(30) %>%
  filter(classification != "graphiurus lorraineus") %>%
  mutate(query = c("JQ735696",
                   "JX292863",
                   "JQ735848",
                   "JF460855",
                   "HM635858",
                   "MT192061",
                   "GU830865",
                   "KF690151",
                   "FJ897499",
                   "KJ542908",
                   "EU603937",
                   "JF704156",
                   "MN845646",
                   "MH805919",
                   "JQ735565",
                   "MH806051",
                   "AJ875300",
                   "MT318936",
                   "JF284216",
                   "MH806052",
                   "JQ639324",
                   "KC684137",
                   "JX845174",
                   "EU053706",
                   "MH805869",
                   "MT192050",
                   "KY753966",
                   "JX292893",
                   "KF478311"),
         cds = 1:29)


cytb_sequences <- read.GenBank(potential_species$query, species.names = T)
write.dna(cytb_sequences, file = here("data", "cyt_b_30.fasta"), format = "fasta")

add_species <- seqinr::read.fasta(file = here("data", "cyt_b_30.fasta"), seqtype = "DNA", as.string = TRUE, forceDNAtolower = FALSE)

match_names <- tibble(query = names(add_species)) %>%
  left_join(., potential_species,
            by = "query") %>%
  mutate(id = str_replace(paste0(query, "_", classification), " ", "_")) %>%
  pull(id)

names(match_names) <- names(add_species)

names(add_species) <- names(add_species) %>%
  recode(., !!!match_names)

seqinr::write.fasta(sequences = add_species, names = names(add_species), file.out = here("data", "cyt_b_30.fasta"))
