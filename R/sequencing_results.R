source(here::here("R", "library.R"))

sequencing <- read_csv(here("data", "Inventory", "sequencing.csv"))

rodent_trapping <- readRDS(gzcon(url("https://github.com/DidDrog11/rodent_trapping/raw/main/data/data_for_export/combined_data.rds")))

rodent_data <- rodent_trapping$rodent_data

enriched_sequencing <- sequencing %>%
  drop_na(rodent_uid) %>%
  left_join(rodent_data %>%
              select(rodent_uid, trap_uid, clean_names, sex, age_group, weight, head_body, tail, hind_foot, length_skull),
              by = c("rodent_uid"))

require_sequencing <- enriched_sequencing %>%
  filter(is.na(blastn))

require_checking <- enriched_sequencing %>%
  mutate(field_genus = str_split(clean_names, "_", simplify = TRUE)[ , 1],
         sequence_genus = str_split(blastn, "_", simplify = TRUE)[ , 1]) %>%
  filter(field_genus != sequence_genus)

table(enriched_sequencing$blastn, enriched_sequencing$clean_names)

dir.create(here("data", "output"))

rodent_sequences = list(rodent_sequences = enriched_sequencing,
                        require_checking = require_checking)

write_rds(x = rodent_sequences,
          file = here("data", "output", "rodent_sequences.rds"))
