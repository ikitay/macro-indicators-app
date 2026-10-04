# =============================================================================
# GLOSSARY
# Macroeconomic term definitions for undergraduate students
# =============================================================================

GLOSSARY_TERMS <- list(

  list(
    term       = "GDP Growth",
    category   = "Output",
    definition = paste0(
      "The annual percentage change in a country's real Gross Domestic Product (GDP), ",
      "measured at constant prices. GDP is the value of the final goods and services ",
      "produced in an economy during a period. Nominal GDP uses each year's prices, so it ",
      "can rise only because prices rose; real GDP removes that effect and shows whether ",
      "the economy actually produced more. Economic growth is the objective; the change ",
      "in real GDP is the indicator we use to observe it."
    ),
    example    = "If GDP grows by 3%, the economy produced 3% more goods and services than the previous year.",
    related    = "Recession, Business Cycle, Nominal GDP"
  ),

  list(
    term       = "Recession",
    category   = "Output",
    definition = paste0(
      "A period of sustained decline in production, income and employment. With quarterly ",
      "data, a common rule of thumb is two consecutive quarters of falling real GDP. This ",
      "app uses annual data, so a year of negative GDP growth is a signal of recession, not ",
      "a definition. Recessions are typically accompanied by rising unemployment, falling ",
      "investment and reduced consumer spending. The global financial crisis of 2008–09 ",
      "caused simultaneous recessions in many countries."
    ),
    example    = "During 2020, many countries experienced their deepest recessions in decades due to COVID-19.",
    related    = "GDP Growth, Business Cycle, Unemployment"
  ),

  list(
    term       = "Employment Rate",
    category   = "Labour",
    definition = paste0(
      "The percentage of the working-age population (15+) that is currently employed. ",
      "Also called the employment-to-population ratio. Different from the unemployment rate, ",
      "which measures only those actively seeking work. The employment rate can fall even ",
      "if unemployment stays constant (if people leave the labour force)."
    ),
    example    = "An employment rate of 60% means 60 out of every 100 working-age people have jobs.",
    related    = "Unemployment Rate, Labour Force, Participation Rate"
  ),

  list(
    term       = "Unemployment Rate",
    category   = "Labour",
    definition = paste0(
      "The percentage of the labour force (employed + actively job-seeking) that is ",
      "unemployed. This app uses the employment rate instead because it captures ",
      "structural differences in labour force participation across countries more reliably."
    ),
    example    = "If 5 out of 100 active workers are unemployed, the unemployment rate is 5%.",
    related    = "Employment Rate, Labour Force, Natural Rate of Unemployment"
  ),

  list(
    term       = "Inflation",
    category   = "Prices",
    definition = paste0(
      "A sustained, generalised increase in the general price level. It is measured as the ",
      "percentage change of a price index such as the Consumer Price Index (CPI). The CPI ",
      "is not inflation: it is an index of the cost of a representative household basket; ",
      "inflation is its rate of change. Price stability does not mean no price ever rises: ",
      "the aim is to avoid high or unstable inflation. Low, stable inflation (typically 2%) ",
      "is the target of most central banks. Very high inflation erodes purchasing power; ",
      "deflation (a sustained fall in the price level) is not desirable either, especially ",
      "when it reflects weak economic activity."
    ),
    example    = "If the CPI goes from 100 to 110 in a year, the basket costs 10% more: inflation for that year is 10%. Saying \"the CPI was 110\" does not tell you how much inflation there was.",
    related    = "Hyperinflation, Deflation, Central Bank, Monetary Policy"
  ),

  list(
    term       = "Hyperinflation",
    category   = "Prices",
    definition = paste0(
      "Extremely rapid inflation, often defined as exceeding 50% per month. ",
      "It destroys the value of savings, causes economic chaos, and typically results ",
      "from excessive money creation. Argentina (1989–90), Venezuela (2017–19) and ",
      "Zimbabwe (2007–08) have experienced hyperinflation in recent decades."
    ),
    example    = "Argentina's annual inflation reached 2,314% in 1990, at the end of its 1989–90 hyperinflation (see Explore Country). High inflation is not always hyperinflation: Argentina's 133% in 2023 was very high, but far below 50% a month.",
    related    = "Inflation, Monetary Policy, Currency Crisis"
  ),

  list(
    term       = "Fiscal Balance",
    category   = "Government",
    definition = paste0(
      "The difference between government revenues (taxes, fees) and expenditures ",
      "(spending, transfers), expressed as a percentage of GDP. A surplus means the ",
      "government earns more than it spends; a deficit means it must borrow, which adds ",
      "to public debt. A deficit is not necessarily a problem: in a recession tax revenue ",
      "falls while some spending rises, and a temporary deficit can be compatible with ",
      "sound public finances. Fiscal sustainability depends on the path of public debt ",
      "relative to the size of the economy, not on one year's result."
    ),
    example    = "A fiscal balance of –3% of GDP means the government spends 3% of GDP more than it collects.",
    related    = "Fiscal Sustainability, Public Debt, Austerity, Fiscal Policy"
  ),

  list(
    term       = "Trade Balance",
    category   = "External Sector",
    definition = paste0(
      "Exports minus imports of goods and services, as a percentage of GDP. A trade ",
      "surplus (positive) means a country exports more than it imports. A trade deficit ",
      "(negative) means it imports more. It is narrower than the balance of payments, ",
      "which also records investment, loans and income flows with the rest of the world. ",
      "A trade deficit is not necessarily unsustainable: what matters is how it is ",
      "financed and whether it can be maintained over time."
    ),
    example    = "Germany typically runs a large trade surplus because its exports greatly exceed its imports.",
    related    = "Current Account, Exchange Rate, Trade Policy, Balance of Payments"
  ),

  list(
    term       = "Balance of Payments",
    category   = "External Sector",
    definition = paste0(
      "The record of all economic transactions between a country and the rest of the ",
      "world during a period: trade in goods and services, but also income, transfers, ",
      "investment and loans. It is the main tool for analysing external sustainability: ",
      "whether a country can keep up its economic relations with the rest of the world ",
      "without building up growing vulnerability."
    ),
    example    = "A foreign company building a factory in the country does not appear in the trade balance, but it does appear in the balance of payments.",
    related    = "Trade Balance, External Sustainability, Exchange Rate"
  ),

  list(
    term       = "Fiscal Sustainability",
    category   = "Government",
    definition = paste0(
      "The government's capacity to meet its current and future commitments without ",
      "building up fiscal and debt imbalances that become hard to finance. It is analysed ",
      "with the fiscal balance together with the path of public debt over time, ",
      "relative to the size of the economy."
    ),
    example    = "Two countries run the same deficit this year. In one, public debt stays stable relative to GDP; in the other it grows year after year and becomes harder to finance. Same fiscal balance, different sustainability.",
    related    = "Fiscal Balance, Public Debt, Recession"
  ),

  list(
    term       = "Nominal GDP",
    category   = "Output",
    definition = paste0(
      "GDP valued at each period's own (current) prices. It can rise simply because ",
      "prices rose, without the economy producing more. To know whether production ",
      "grew, look at real GDP, which removes the effect of price changes."
    ),
    example    = "If an economy produces exactly the same as last year but all prices rise 20%, nominal GDP rises 20% and real GDP does not change.",
    related    = "GDP Growth, Inflation"
  ),

  list(
    term       = "Trade-off",
    category   = "Concepts",
    definition = paste0(
      "In macroeconomics, a trade-off is a situation where improving one objective ",
      "makes it harder to achieve another. The famous Phillips Curve suggests a ",
      "trade-off between inflation and unemployment: reducing unemployment may raise ",
      "inflation, and vice versa. However, this relationship is not stable across all ",
      "countries and time periods."
    ),
    example    = "A government may stimulate the economy to reduce unemployment, but risk higher inflation.",
    related    = "Phillips Curve, Macroeconomic Objectives, Monetary Policy"
  ),

  list(
    term       = "Correlation",
    category   = "Statistics",
    definition = paste0(
      "A statistical measure of how strongly two variables move together. A correlation ",
      "of +1 means they move in perfect lockstep; –1 means they move in exact opposite ",
      "directions; 0 means no linear relationship. Crucially, correlation does not prove ",
      "that one variable causes the other."
    ),
    example    = "GDP growth and employment rates often correlate positively, but the strength varies by country.",
    related    = "Causation, Regression, Phillips Curve"
  ),

  list(
    term       = "Causation",
    category   = "Statistics",
    definition = paste0(
      "A causal relationship means that changing one variable directly produces a change ",
      "in another. This is much harder to establish than correlation. Two variables can ",
      "be correlated because: (A) causes (B), (B) causes (A), a third variable (C) ",
      "causes both, or it is pure coincidence."
    ),
    example    = "Ice cream sales and drownings are correlated (both increase in summer) but neither causes the other.",
    related    = "Correlation, Endogeneity, Omitted Variable Bias"
  ),

  list(
    term       = "Business Cycle",
    category   = "Concepts",
    definition = paste0(
      "The recurring pattern of economic expansion (boom) and contraction (recession) ",
      "around a long-run growth trend. Cycles vary in length and severity. Understanding ",
      "business cycles helps explain why GDP growth, employment, and fiscal balances all ",
      "tend to worsen simultaneously during downturns."
    ),
    example    = "The 2008–09 global financial crisis triggered a deep cyclical downturn in most economies.",
    related    = "GDP Growth, Recession, Fiscal Policy, Monetary Policy"
  ),

  list(
    term       = "Monetary Policy",
    category   = "Policy",
    definition = paste0(
      "Actions by a country's central bank to influence the money supply and interest ",
      "rates, primarily to control inflation and support economic activity. When inflation ",
      "is high, central banks typically raise interest rates (tighten); when recession ",
      "threatens, they lower rates (loosen)."
    ),
    example    = "The US Federal Reserve raised interest rates sharply in 2022–23 to combat high inflation.",
    related    = "Inflation, Interest Rate, Central Bank, Fiscal Policy"
  ),

  list(
    term       = "Fiscal Policy",
    category   = "Policy",
    definition = paste0(
      "Government decisions about spending and taxation designed to influence the economy. ",
      "Expansionary fiscal policy (more spending or lower taxes) can boost growth but may ",
      "increase deficits. Contractionary policy (austerity) reduces deficits but can slow ",
      "growth and raise unemployment."
    ),
    example    = "COVID-19 stimulus packages were expansionary fiscal policy that led to large fiscal deficits.",
    related    = "Fiscal Balance, Monetary Policy, Multiplier Effect, Austerity"
  )
)

# Sort alphabetically
GLOSSARY_TERMS <- GLOSSARY_TERMS[order(sapply(GLOSSARY_TERMS, `[[`, "term"))]

# =============================================================================
# GLOSSARY MODAL UI
# =============================================================================
glossary_modal <- function() {
  modalDialog(
    title = tags$span("📖 Macroeconomics Glossary"),
    size  = "xl",
    easyClose = TRUE,
    tags$div(
      style = "margin-bottom:14px;",
      tags$p(
        style = "color:#555; margin:0;",
        "Hover over any ", tags$code("📖"), " icon in the application to see quick definitions.",
        " This glossary provides full explanations with examples."
      )
    ),
    # Filter by category
    tags$div(
      style = "margin-bottom:16px;",
      radioGroupButtons(
        inputId  = "glossary_filter",
        label    = NULL,
        choices  = c("All", "Output", "Labour", "Prices", "Government",
                     "External Sector", "Policy", "Concepts", "Statistics"),
        selected = "All",
        size     = "sm",
        status   = "outline-primary"
      )
    ),
    # Glossary entries
    uiOutput("glossary_content"),
    footer = modalButton("Close")
  )
}

#' Render glossary entries (called from server)
render_glossary <- function(filter_cat = "All") {
  terms <- if (filter_cat == "All") {
    GLOSSARY_TERMS
  } else {
    Filter(function(t) t$category == filter_cat, GLOSSARY_TERMS)
  }

  tags$div(
    lapply(terms, function(t) {
      tags$div(
        class = "glossary-entry",
        style = "border:1px solid #e2e8f0; border-radius:8px; padding:14px;
                 margin-bottom:10px; background:#fafafa;",
        tags$div(
          style = "display:flex; justify-content:space-between; align-items:flex-start;",
          tags$h6(style = "color:#1e3a5f; font-weight:700; margin:0 0 6px;", t$term),
          tags$span(
            style = paste0(
              "background:", category_color(t$category), "; color:white; ",
              "border-radius:12px; padding:2px 10px; font-size:0.72rem; white-space:nowrap;"
            ),
            t$category
          )
        ),
        tags$p(style = "margin:0 0 6px; color:#333; font-size:0.88rem; line-height:1.6;",
               t$definition),
        tags$div(
          style = "background:#f0f9ff; border-radius:5px; padding:6px 10px; font-size:0.83rem;",
          tags$span(style = "font-weight:600; color:#0369a1;", "Example: "),
          tags$span(style = "color:#334155;", t$example)
        ),
        if (!is.null(t$related)) {
          tags$div(
            style = "margin-top:6px; font-size:0.78rem; color:#64748b;",
            tags$span(style = "font-weight:600;", "Related: "),
            t$related
          )
        }
      )
    })
  )
}

category_color <- function(cat) {
  cols <- c(
    "Output"          = "#2563eb",
    "Labour"          = "#16a34a",
    "Prices"          = "#dc2626",
    "Government"      = "#7c3aed",
    "External Sector" = "#d97706",
    "Policy"          = "#0891b2",
    "Concepts"        = "#db2777",
    "Statistics"      = "#475569"
  )
  unname(cols[cat])
}

# Helper: inline info icon with tooltip
info_icon <- function(term_key) {
  term_data <- Filter(function(t) tolower(t$term) == tolower(term_key), GLOSSARY_TERMS)
  if (length(term_data) == 0) return(NULL)
  t <- term_data[[1]]
  tooltip_text <- substr(t$definition, 1, 200)
  if (nchar(t$definition) > 200) tooltip_text <- paste0(tooltip_text, "…")
  tags$span(
    title = tooltip_text,
    style = "cursor:help; color:#2563eb; font-size:0.8rem; margin-left:4px;",
    "📖"
  )
}

# =============================================================================
# SERVER BINDING — must be called inside the main server function
# =============================================================================
glossary_server_outputs <- function(input, output, session) {
  output$glossary_content <- renderUI({
    filter_val <- if (!is.null(input$glossary_filter)) input$glossary_filter else "All"
    render_glossary(filter_val)
  })
}
