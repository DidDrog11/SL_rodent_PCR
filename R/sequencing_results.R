source(here::here("R", "library.R"))

raw_sequencing <- read_csv(here("data", "Inventory", "sequencing.csv"))

inventory <- read_xlsx(here("data", "Inventory", "sample_inventory_2023-05-15.xlsx")) %>%
  select(PCR_id, sample_uid, rodent_uid)

sequencing <- raw_sequencing %>%
  rename(sample_uid = rodent_uid) %>%
  left_join(inventory)

rodent_trapping <- readRDS(gzcon(url("https://github.com/DidDrog11/rodent_trapping/raw/main/data/data_for_export/combined_data.rds")))

rodent_data <- rodent_trapping$rodent_data

enriched_sequencing <- sequencing %>%
  drop_na(rodent_uid) %>%
  left_join(rodent_data %>%
              select(rodent_uid, trap_uid, field_id, sex, age_group, weight, head_body, hind_foot, length_skull),
              by = c("rodent_uid"))

require_sequencing <- enriched_sequencing %>%
  filter(is.na(blastn))

require_checking <- enriched_sequencing %>%
  mutate(field_genus = str_split(field_id, "_", simplify = TRUE)[ , 1],
         sequence_genus = str_split(blastn, "_", simplify = TRUE)[ , 1]) %>%
  filter(field_genus != sequence_genus)

table(enriched_sequencing$blastn, enriched_sequencing$field_id)

dir.create(here("data", "output"))

rodent_sequences = list(rodent_sequences = enriched_sequencing,
                        require_checking = require_checking)

write_rds(x = rodent_sequences,
          file = here("data", "output", "rodent_sequences.rds"))
