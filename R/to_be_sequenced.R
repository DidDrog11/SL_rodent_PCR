source(here::here("R", "library.R"))

rodent_trapping <- readRDS(gzcon(url("https://github.com/DidDrog11/rodent_trapping/raw/main/data/data_for_export/combined_data.rds")))

rodent_data <- rodent_trapping$rodent_data %>%
  select(rodent_uid, field_id) %>%
  mutate(field_genus = str_split(field_id, "_", simplify = TRUE)[, 1])

sample_inventory <- read_xlsx(here("data", "Inventory", "sample_inventory_2023-02-14.xlsx"))

known_sequences <- read_rds(file = here("data", "output", "rodent_sequences.rds"))[["rodent_sequences"]] %>%
  select(rodent_uid, blastn, blastn_identity, PCR_id, Barcode) %>%
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

sequencing_file_date <- "Oct_2022"
add_to_eurofins <- read_csv(here("files", list.files(here("files"))[str_detect(list.files(here("files")), paste0(sequencing_file_date, ".csv"))]))
add_processed_samples <- sample_inventory %>%
  left_join(known_sequences, by = c("rodent_uid", "PCR_id")) %>%
  arrange(PCR_id)
require_barcode <- add_processed_samples %>%
  filter(is.na(Barcode) | str_detect(status, "Needs doing|Repeat"), PCR_product == TRUE) %>%
  mutate(Barcode = add_to_eurofins %>%
  filter(!Barcode %in% add_processed_samples$Barcode) %>%
  filter(row_number() <= nrow(require_barcode)) %>%
  pull(Barcode)) %>%
  select(visit, rodent_uid, blood_id, filter_id, PCR_id, Barcode, status) %>%
  write_csv(., here("files", "February_shipment_barcodes.csv"))

write_csv(to_do_list, here("data", "Inventory", paste0("to_do_list_", Sys.Date(), ".csv")))

