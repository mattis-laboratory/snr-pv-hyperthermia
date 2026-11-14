# SNr figure 4
# Comparison of mean detected transients pre and post UEO
# Within and across genotype (WT, het_sz, het_nsz)

# ============================================================
# Group x Time analysis for calcium signal (z-scored, baseline = 0)
# ============================================================

library(dplyr)
library(tidyr)
library(lme4)
library(lmerTest)   # gives p-values for lmer via Satterthwaite df
library(emmeans)
library(readxl)
# ------------------------------------------------------------
# 1. LOAD DATA
# ------------------------------------------------------------
het_sz_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/PSTH_lme.xlsx", 
                          sheet = "het_sz")
het_nsz_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/PSTH_lme.xlsx", 
                           sheet = "het_nsz")
WT_data <- read_excel("C:/Users/cr740/University of Michigan Dropbox/Chandni Rana/MattisLab_DB/Projects/SNr/data/analysis/PSTH_lme.xlsx", 
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
  pivot_longer(cols = c(pre, post), names_to = "time", values_to = "signal") %>%
  mutate(
    group = factor(group, levels = c("WT", "het_sz", "het_nsz")),   # set your preferred reference order
    time  = factor(time,  levels = c("pre", "post"))
  )

# ------------------------------------------------------------
# 3. FIT MIXED-EFFECTS MODEL (baseline excluded — it's a fixed 0, not "data")
# ------------------------------------------------------------
model <- lmer(signal ~ group * time + (1 | mouse_id), data = df_long)

summary(model)          # coefficients
anova(model)            # omnibus test of group, time, group:time (interaction = "do groups differ in how they change over time")

# ------------------------------------------------------------
# 4. ESTIMATED MARGINAL MEANS
# ------------------------------------------------------------
emm <- emmeans(model, ~ group * time)
emm   # print estimated cell means with SEs and CIs

# ------------------------------------------------------------
# 5. THE TWO CONTRAST FAMILIES
# ------------------------------------------------------------

# (a) pre vs post, within each group
pre_vs_post <- contrast(emm, method = "revpairwise", by = "group")
evl_df <- as.data.frame(pre_vs_post) %>%
  mutate(comparison = paste(group, contrast),
         family = "pre_vs_post") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# (b) Group vs group, within each time period
group_vs_group <- contrast(emm, method = "pairwise", by = "time")
gvg_df <- as.data.frame(group_vs_group) %>%
  mutate(comparison = paste(time, contrast),
         family = "group_vs_group") %>%
  select(comparison, family, estimate, SE, df, t.ratio, p.value)

# ------------------------------------------------------------
# 6. COMBINE ALL COMPARISONS INTO ONE FAMILY AND CORRECT ONCE
# ------------------------------------------------------------
all_results <- bind_rows( evl_df, gvg_df) %>%
  mutate(p_adj_BH   = p.adjust(p.value, method = "BH"),
         p_adj_holm = p.adjust(p.value, method = "holm")) %>%
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
# (paired Wilcoxon for pre vs post; Kruskal-Wallis + Dunn's test for group vs group)