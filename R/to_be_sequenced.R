source(here::here("R", "library.R"))

rodent_trapping <- readRDS(gzcon(url("https://github.com/DidDrog11/rodent_trapping/raw/main/data/data_for_export/combined_data.rds")))

rodent_data <- rodent_trapping$rodent_data %>%
  select(rodent_uid, field_id) %>%
  mutate(field_genus = str_split(field_id, "_", simplify = TRUE)[, 1])

sample_inventory <- read_xlsx(here("data", "Inventory", "sample_inventory_2022-12-13.xlsx"))

known_sequences <- read_rds(file = here("data", "output", "rodent_sequences.rds"))[["rodent_sequences"]] %>%
  select(rodent_uid, blastn, blastn_identity) %>%
  mutate(blast_genus = str_split(blastn, "_", simplify = TRUE)[, 1])

matching_to_inventory <- sample_inventory %>%
  select(rodent_uid, PCR_id) %>%
  left_join(rodent_data, by = "rodent_uid") %>%
  left_join(known_sequences, by = "rodent_uid") %>%
  mutate(genus_match = case_when(is.na(field_genus) | is.na(blast_genus) ~ NA,
                                 field_genus == blast_genus ~ TRUE,
                                 field_genus != blast_genus ~ FALSE))

to_do_list <- matching_to_inventory %>%
  filter(is.na(blastn) | genus_match == FALSE) %>%
  select(rodent_uid, PCR_id)

write_csv(to_do_list, here("data", "Inventory", paste0("to_do_list_", Sys.Date(), ".csv")))

