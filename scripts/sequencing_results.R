sequencing <- read_csv(here("data", "Inventory", "sequencing.csv"))

rodent_trapping <- readRDS(gzcon(url("https://github.com/DidDrog11/rodent_trapping/raw/main/data/data_for_export/combined_data.rds")))

rodent_data <- rodent_trapping$rodent_data

enriched_sequencing <- sequencing %>%
  drop_na(rodent_uid) %>%
  left_join(rodent_data %>%
              select(rodent_uid, trap_uid, clean_names, sex, age_group, weight, head_body, tail, hind_foot, length_skull),
              by = c("rodent_uid"))

table(enriched_sequencing$BLAST, enriched_sequencing$clean_names)
