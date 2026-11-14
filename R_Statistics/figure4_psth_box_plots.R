# ============================================================
# GraphPad Prism-style dot plot with mean ± SEM overlay
# Pre/Post conditions x 3 groups, individual data points shown
# ============================================================

library(ggplot2)
library(dplyr)


##################################
df_plot <- df_long %>% select(group, time, signal)

# Set factor order so Pre comes before Post, and groups plot in desired order
df_plot$time <- factor(df_plot$time, levels = c("pre", "post"))
df_plot$group <- factor(df_plot$group, levels = c("het_sz", "het_nsz", "WT"))


# ---- 2. Summary stats (mean ± SEM) ---------------------------
summary_df <- df_plot %>%
  group_by(time, group) %>%
  summarise(
    mean = mean(signal),
    sem  = sd(signal) / sqrt(n()),
    .groups = "drop"
  )

# ---- 3. Plot --------------------------------------------------
dodge_width <- 0.7

p <- ggplot(df_plot, aes(x = time, y = signal, color = group, group = group)) +
  
  # Individual data points, jittered within each group's dodge slot
  geom_point(
    position = position_jitterdodge(jitter.width = 0.12, dodge.width = dodge_width),
    size = 2.2, alpha = 0.75
  ) +
  
  # Mean ± SEM error bars
  geom_errorbar(
    data = summary_df,
    aes(x = time, y = mean, ymin = mean - sem, ymax = mean + sem, group = group),
    position = position_dodge(width = dodge_width),
    width = 0.15, linewidth = 0.8, color = "black"
  ) +
  
  # Mean as a horizontal bar (like Prism's mean line)
  geom_errorbar(
    data = summary_df,
    aes(x = time, y = mean, ymin = mean, ymax = mean, group = group),
    position = position_dodge(width = dodge_width),
    width = 0.28, linewidth = 0.9, color = "black"
  ) +
  
  scale_color_manual(values = c("het_sz" = "#ff0000",
                                "het_nsz" = "#ffa500",
                                "WT" = "#0000ff")) +
  
  labs(x = NULL, y = "signal", color = "group") +
  
  theme_classic(base_size = 14) +
  theme(
    axis.line = element_line(linewidth = 0.6),
    axis.ticks = element_line(linewidth = 0.6),
    legend.position = "top",
    panel.grid = element_blank()
  )

print(p)

# ---- 4. Save --------------------------------------------------
ggsave("prepost_group_dotplot.png", plot = p, width = 6, height = 5, dpi = 300)