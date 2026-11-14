# SNr figure 4 
# Comparison of means during seizure (and against baseline) 
# Within and across genotype (WT, het_sz, het_nsz)

# ============================================================
# Group x Time analysis for calcium signal (z-scored, baseline = 0)
# ============================================================

library(dplyr)
library(tidyr)
library(lme4)
library(lmerTest)   # gives p-values for lmer via Satterthwaite df
library(emmeans)

# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------
# Each table should have one row per mouse, with columns: mouse_id, early, late

# --- sample data ---
# set.seed(1)
# WT_data  <- data.frame(mouse_id = paste0("wt_",1:8),  early = rnorm(8, 0.5, 0.3), late = rnorm(8, 0.3, 0.3))
# het_sz_data <- data.frame(mouse_id = paste0("het_sz__",1:8), early = rnorm(8, 0.8, 0.3), late = rnorm(8, 0.9, 0.3))
# het_nsz_data  <- data.frame(mouse_id = paste0("het_nsz_",1:8),  early = rnorm(8, 0.2, 0.3), late = rnorm(8, 0.1, 0.3))
# ------------------------------------------------------------

# Tag each table with its genotype, then combine
# WT_data$group  <- "WT"
# het_sz_data$group <- "het_sz"
# het_nsz_data$group  <- "het_nsz"

# ------------------------------------------------------------
het_sz_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/seizure_means.xlsx", 
                          sheet = "het_sz")
het_nsz_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/seizure_means.xlsx", 
                           sheet = "het_nsz")
WT_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/seizure_means.xlsx", 
                      sheet = "WT")
# ------------------------------------------------------------

# Keep only datasets
rm(list = setdiff(ls(), c("het_sz_data", "het_nsz_data", "WT_data")))


df_wide <- bind_rows(WT_data, het_sz_data, het_nsz_data)

# Make mouse IDs globally unique (in case IDs repeat across genotype tables)
df_wide$mouse_id <- paste(df_wide$group, df_wide$mouse_id, sep = "_")

# ------------------------------------------------------------
# 2. RESHAPE TO LONG FORMAT
# ------------------------------------------------------------
df_long <- df_wide %>%
  pivot_longer(cols = c(seizure), names_to = "time", values_to = "signal") %>%
  mutate(
    group = factor(group, levels = c("WT", "het_sz", "het_nsz")),   # set your preferred reference order
    time  = factor(time,  levels = c("seizure"))
  )

# ------------------------------------------------------------
# 3. FIT MIXED-EFFECTS MODEL (baseline excluded — it's a fixed 0, not "data")
# ------------------------------------------------------------
model <- lmer(signal ~ group + (1 | mouse_id), data = df_long)
summary(model)          # coefficients
anova(model)            # omnibus test of group, time, group:time (interaction = "do groups differ in how they change over time")


# ------------------------------------------------------------
# 4. ESTIMATED MARGINAL MEANS
# ------------------------------------------------------------
emm <- emmeans(model, ~ group)
emm   # print estimated cell means with SEs and CIs

# ------------------------------------------------------------
# 5. THE TWO CONTRAST FAMILIES
# ------------------------------------------------------------

# (a) Each cell mean vs 0  --> equivalent to "vs baseline" since baseline == 0
vs_zero <- test(emm, null = 0)
vs_zero_df <- as.data.frame(vs_zero) %>%
  rename(estimate = emmean) %>%
  mutate(comparison = paste(group, "vs baseline"),
         family = "vs_baseline") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)


# (b) Group vs group, within each time period
group_vs_group <- contrast(emm, method = "pairwise", by = "time")
gvg_df <- as.data.frame(group_vs_group) %>%
  mutate(comparison = paste( contrast),
         family = "group_vs_group") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# ------------------------------------------------------------
# 6a. COMBINE ALL COMPARISONS INTO ONE FAMILY AND CORRECT ONCE
# ------------------------------------------------------------
all_results <- bind_rows(vs_zero_df, gvg_df) %>%
  mutate(p_adj_BH   = p.adjust(p.value, method = "BH"),
         p_adj_holm = p.adjust(p.value, method = "holm")) %>%
  arrange(family, p.value)

print(all_results, digits = 4)

# Optional: write out for supplementary tables
# write.csv(all_results, "group_time_contrasts.csv", row.names = FALSE)

# ------------------------------------------------------------
# 6b. CORRECT SEPARATELY WITHIN EACH FAMILY
# ------------------------------------------------------------

vs_zero_df <- vs_zero_df %>%
  mutate(p_adj_BH   = p.adjust(p.value, method = "BH"),
         p_adj_holm = p.adjust(p.value, method = "holm"))

gvg_df <- gvg_df %>%
  mutate(p_adj_BH   = p.adjust(p.value, method = "BH"),
         p_adj_holm = p.adjust(p.value, method = "holm"))

# Combine afterwards purely for reporting/viewing — correction already applied per family
all_results <- bind_rows(vs_zero_df, gvg_df) %>%
  arrange(family, p.value)

print(all_results, digits = 4)

# Optional: write out for supplementary tables
# write.csv(all_results, "group_time_contrasts.csv", row.names = FALSE)

# ------------------------------------------------------------
# 7. ADD SIGNIFICANCE STARS + PRINT RESULTS
# ------------------------------------------------------------

p_to_stars <- function(p) {
  case_when(
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    TRUE      ~ ""
  )
}

all_results <- all_results %>%
  mutate(sig_BH   = p_to_stars(p_adj_BH),
         sig_holm = p_to_stars(p_adj_holm))

cat("Significance: * p<0.05, ** p<0.01, *** p<0.001 (adjusted)\n")
print(all_results, digits = 4)


# ------------------------------------------------------------
# 8. DIAGNOSTIC CHECKS
# ------------------------------------------------------------
plot(model)                       # residuals vs fitted — look for major heteroscedasticity
qqnorm(residuals(model)); qqline(residuals(model))   # normality of residuals

# If diagnostics look bad, consider Wilcoxon/Friedman-based non-parametric fallback
# (paired Wilcoxon for early vs late; Kruskal-Wallis + Dunn's test for group vs group)