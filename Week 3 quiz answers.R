library("data.table")
library("dplyr")
FGDP <- data.table::fread("./data/GDP.csv", skip = 5, nrows = 190, select = c(1,2,4,5), col.names = c("CountryCode", "Rank", "Economy", "Total"))
FEDSTATS_Country <- data.table::fread("./data/EDSTATS_Country.csv")

mergedDT <- merge(FGDP, FEDSTATS_Country, by = "CountryCode")
nrow(mergedDT)

mergedDT[order(-Rank)][13, Economy]

rah <- tbl_df(mergedDT)
grouped_rah <- group_by(rah, `Income Group`)
fil_rah <- filter(grouped_rah, `Income Group` == "High income: OECD" | `Income Group` == "High income: nonOECD")
summarise(fil_rah, avg = mean(Rank, na.rm = TRUE))

rah$RankGroups <- cut(rah$Rank, breaks = 5)
table(rah$RankGroups, rah$`Income Group`)