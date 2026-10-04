# =============================================================================
# GLOSSARY
# Macroeconomic term definitions for undergraduate students
# =============================================================================

GLOSSARY_TERMS <- list(

  list(
    term       = "GDP Growth",
    category   = "Output",
    definition = paste0(
      "The annual percentage change in a country's Gross Domestic Product (GDP) ",
      "at constant prices (adjusting for inflation). GDP measures the total value of ",
      "all goods and services produced in an economy. Positive GDP growth means the ",
      "economy is expanding; negative growth indicates contraction."
    ),
    example    = "If GDP grows by 3%, the economy produced 3% more goods and services than the previous year.",
    related    = "Recession, Business Cycle, Real GDP"
  ),

  list(
    term       = "Recession",
    category   = "Output",
    definition = paste0(
      "Conventionally defined as two consecutive quarters of negative GDP growth. ",
      "Recessions are typically accompanied by rising unemployment, falling investment, ",
      "and reduced consumer spending. The global financial crisis of 2008–09 caused ",
      "simultaneous recessions in many countries."
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
      "The annual percentage change in the general price level, measured by the Consumer ",
      "Price Index (CPI). Low, stable inflation (typically 2%) is the target of most ",
      "central banks. Very high inflation erodes purchasing power; deflation (negative ",
      "inflation) can cause consumers to delay purchases, depressing the economy."
    ),
    example    = "If a basket of goods costs $100 today and $103 next year, inflation is 3%.",
    related    = "Hyperinflation, Deflation, Central Bank, Monetary Policy"
  ),

  list(
    term       = "Hyperinflation",
    category   = "Prices",
    definition = paste0(
      "Extremely rapid inflation, often defined as exceeding 50% per month. ",
      "It destroys the value of savings, causes economic chaos, and typically results ",
      "from excessive money creation. Argentina and Zimbabwe have experienced ",
      "hyperinflation in recent decades."
    ),
    example    = "Argentina's inflation exceeded 200% annually in 2023.",
    related    = "Inflation, Monetary Policy, Currency Crisis"
  ),

  list(
    term       = "Fiscal Balance",
    category   = "Government",
    definition = paste0(
      "The difference between government revenues (taxes, fees) and expenditures ",
      "(spending, transfers), expressed as a percentage of GDP. A surplus means the ",
      "government earns more than it spends; a deficit means it must borrow. Persistent ",
      "deficits increase public debt."
    ),
    example    = "A fiscal balance of –3% of GDP means the government spends 3% of GDP more than it collects.",
    related    = "Budget Deficit, Public Debt, Austerity, Fiscal Policy"
  ),

  list(
    term       = "Trade Balance",
    category   = "External Sector",
    definition = paste0(
      "Exports minus imports of goods and services, as a percentage of GDP. A trade ",
      "surplus (positive) means a country exports more than it imports. A trade deficit ",
      "(negative) means it imports more. Trade balances are related to international ",
      "capital flows and exchange rates."
    ),
    example    = "Germany typically runs a large trade surplus because its exports greatly exceed its imports.",
    related    = "Current Account, Exchange Rate, Trade Policy, Balance of Payments"
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
