# =============================================================================
# HISTORICAL EVENTS DATA
# Connects macroeconomic data with major world economic events
# =============================================================================

HISTORICAL_EVENTS <- list(

  asian_crisis = list(
    id          = "asian_crisis",
    name        = "Asian Financial Crisis",
    short_name  = "Asian Crisis",
    year_start  = 1997,
    year_end    = 1999,
    peak_year   = 1998,
    color       = "#e74c3c",
    icon        = "⚡",
    description = paste0(
      "A financial crisis that spread across East and Southeast Asia beginning in ",
      "Thailand in July 1997. Rapid currency depreciations, stock market crashes, ",
      "and banking collapses triggered severe recessions. The IMF provided bailout ",
      "packages to Thailand, Indonesia, and South Korea, attached to controversial ",
      "austerity conditions."
    ),
    macro_impact = paste0(
      "GDP growth collapsed sharply in affected economies. Indonesia's GDP contracted ",
      "by ~13% in 1998. South Korea and Thailand also saw deep recessions. Unemployment ",
      "spiked. Inflation rose in countries with sharp currency depreciations. Fiscal ",
      "balances deteriorated as governments spent on bank bailouts."
    ),
    key_lesson   = paste0(
      "Shows how financial crises can spread rapidly between countries and how the ",
      "same shock can affect different economies in different ways."
    ),
    affected_iso2c   = c("KR", "TH", "ID", "MY", "PH"),
    affected_regions = c("East Asia & Pacific"),
    key_variables    = c("gdp_growth", "employment", "inflation")
  ),

  argentina_crisis = list(
    id          = "argentina_crisis",
    name        = "Argentine Economic Crisis",
    short_name  = "Argentine Crisis",
    year_start  = 1999,
    year_end    = 2003,
    peak_year   = 2002,
    color       = "#f39c12",
    icon        = "💥",
    description = paste0(
      "Argentina's severe economic collapse involved a banking freeze (corralito), ",
      "default on $100 billion in sovereign debt, and the abandonment of the peso-dollar ",
      "peg (convertibility) in January 2002. The peso lost ~70% of its value. GDP fell ",
      "~20% from peak to trough. Unemployment exceeded 20% and poverty soared."
    ),
    macro_impact = paste0(
      "GDP growth turned sharply negative (~–11% in 2002). Unemployment rose above 20%. ",
      "Inflation surged after devaluation. The fiscal balance deteriorated sharply. ",
      "The trade balance improved as devaluation made exports competitive."
    ),
    key_lesson   = paste0(
      "A dramatic example of all five indicators deteriorating simultaneously. Also shows ",
      "how a trade balance can improve even during a severe economic crisis (via devaluation)."
    ),
    affected_iso2c   = c("AR"),
    affected_regions = c("Latin America & Caribbean"),
    key_variables    = c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance")
  ),

  gfc = list(
    id          = "gfc",
    name        = "Global Financial Crisis",
    short_name  = "Global Crisis (2008)",
    year_start  = 2008,
    year_end    = 2010,
    peak_year   = 2009,
    color       = "#8e44ad",
    icon        = "🏦",
    description = paste0(
      "Triggered by the collapse of the US subprime mortgage market and the failure of ",
      "major financial institutions (Lehman Brothers, September 2008). The crisis rapidly ",
      "spread worldwide through financial linkages, causing the worst global recession ",
      "since the Great Depression. Governments launched massive stimulus programs and ",
      "bank bailouts."
    ),
    macro_impact = paste0(
      "Global GDP growth collapsed. Most advanced economies saw GDP contract in 2009. ",
      "Unemployment rose sharply and stayed elevated for years (especially in Southern Europe). ",
      "Inflation initially fell, then reflected policy responses. Fiscal balances deteriorated ",
      "massively as automatic stabilizers and stimulus packages took effect."
    ),
    key_lesson   = paste0(
      "Illustrates synchronised global recessions: virtually all indicators worsened ",
      "simultaneously in most countries. Also shows divergence in recovery speeds — ",
      "some countries recovered quickly (Germany, South Korea); others struggled for years ",
      "(Greece, Spain)."
    ),
    affected_iso2c   = c("US", "GB", "DE", "FR", "ES", "GR", "JP", "KR", "AU"),
    affected_regions = c("Europe & Central Asia", "North America", "East Asia & Pacific"),
    key_variables    = c("gdp_growth", "employment", "fiscal_balance")
  ),

  covid = list(
    id          = "covid",
    name        = "COVID-19 Pandemic",
    short_name  = "COVID-19 (2020)",
    year_start  = 2020,
    year_end    = 2022,
    peak_year   = 2020,
    color       = "#16a085",
    icon        = "🦠",
    description = paste0(
      "The COVID-19 pandemic caused the sharpest global economic contraction since ",
      "World War II. Lockdowns, supply chain disruptions, and demand collapses hit most ",
      "economies simultaneously in 2020. Unprecedented fiscal stimulus and monetary easing ",
      "cushioned the blow in many countries. Recovery was uneven and rapid inflation ",
      "followed in 2021–22."
    ),
    macro_impact = paste0(
      "Global GDP contracted ~3.1% in 2020 — the worst peacetime contraction on record. ",
      "Employment fell sharply. Fiscal deficits exploded as governments spent on support ",
      "programs. Inflation was initially subdued (2020) then surged (2021–22). ",
      "Trade balances changed due to shifting goods vs. services patterns."
    ),
    key_lesson   = paste0(
      "The most synchronised global shock in modern history. Compare the depth of ",
      "contraction across countries and the speed of recovery. Also useful for observing ",
      "the inflation surge that followed the recovery."
    ),
    affected_iso2c   = c("US", "GB", "DE", "FR", "ES", "IT", "JP", "CN", "BR", "IN",
                         "MX", "ZA", "AU", "KR", "TR"),
    affected_regions = c("East Asia & Pacific", "Europe & Central Asia",
                         "Latin America & Caribbean", "North America",
                         "South Asia", "Sub-Saharan Africa"),
    key_variables    = c("gdp_growth", "employment", "fiscal_balance", "trade_balance")
  ),

  energy_crisis = list(
    id          = "energy_crisis",
    name        = "European Energy Crisis",
    short_name  = "Energy Crisis (2022)",
    year_start  = 2021,
    year_end    = 2023,
    peak_year   = 2022,
    color       = "#e67e22",
    icon        = "⚡",
    description = paste0(
      "Russia's invasion of Ukraine in February 2022 dramatically worsened an already ",
      "tight global energy market, causing natural gas and electricity prices in Europe ",
      "to reach historic highs. Combined with post-COVID supply chain disruptions, this ",
      "drove the highest inflation in Europe for 40 years."
    ),
    macro_impact = paste0(
      "Inflation reached 10%+ in many European countries in 2022. GDP growth slowed ",
      "but most European economies avoided recession. Fiscal balances deteriorated as ",
      "governments subsidised energy costs. Countries with energy independence ",
      "(Norway, some Gulf states) benefited from high energy prices."
    ),
    key_lesson   = paste0(
      "Demonstrates an external supply shock causing inflation without being a demand ",
      "stimulus. Also shows how the same global shock can benefit some economies ",
      "(energy exporters) while harming others (energy importers)."
    ),
    affected_iso2c   = c("DE", "FR", "GB", "ES", "IT", "PL", "TR"),
    affected_regions = c("Europe & Central Asia"),
    key_variables    = c("inflation", "gdp_growth", "fiscal_balance")
  )
)

# Ordered list for UI display
EVENT_CHOICES <- setNames(
  names(HISTORICAL_EVENTS),
  sapply(HISTORICAL_EVENTS, function(e) paste(e$icon, e$name, paste0("(", e$year_start, ")") ))
)
