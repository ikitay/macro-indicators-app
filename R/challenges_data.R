# =============================================================================
# DISCOVERY CHALLENGES DATA
# Guided inquiry tasks for student exploration
# =============================================================================

CHALLENGES <- list(

  list(
    id           = "C01",
    title        = "Growth Without Jobs",
    difficulty   = "Medium",
    icon         = "💼",
    description  = paste0(
      "Find a country that experienced sustained GDP growth over at least five ",
      "consecutive years while the employment rate remained flat or declined. ",
      "This pattern — sometimes called 'jobless growth' — challenges the simple ",
      "assumption that GDP growth automatically creates employment."
    ),
    hint         = paste0(
      "Try looking at rapidly industrialising economies in the 1990s–2000s, or at ",
      "countries that invested heavily in capital-intensive industries. Also check ",
      "Eastern European transition economies after 1990."
    ),
    variables    = c("gdp_growth", "employment"),
    solution_countries = list(
      list(country = "China",    years = "1990–2005",
           note = "Rapid growth but structural shift reduced agricultural employment share."),
      list(country = "Russia",   years = "1999–2008",
           note = "Strong GDP recovery but labour market restructuring kept employment subdued."),
      list(country = "Germany",  years = "2003–2007",
           note = "Hartz reforms and productivity gains produced growth with limited job creation initially.")
    ),
    pedagogical_note = paste0(
      "Jobless growth often occurs during periods of rapid technological change or ",
      "structural transformation. It raises important distributional questions: who ",
      "benefits from growth? Discuss how GDP per capita can rise even if many workers ",
      "are displaced. Connect to debates about automation and income inequality."
    ),
    discussion_questions = c(
      "Why might GDP grow without employment growing proportionally?",
      "Who benefits from growth if employment doesn't increase?",
      "What policies might convert jobless growth into job-rich growth?"
    )
  ),

  list(
    id           = "C02",
    title        = "Falling Inflation, Rising Unemployment",
    difficulty   = "Hard",
    icon         = "📉",
    description  = paste0(
      "The Phillips Curve predicts a trade-off: reducing inflation should require ",
      "accepting higher unemployment. Find a period in any country where inflation ",
      "fell substantially AND employment also fell (or stayed low) — a case that ",
      "appears to challenge the basic trade-off narrative."
    ),
    hint         = paste0(
      "This often occurs after a major supply shock or during structural transitions. ",
      "Post-communist Eastern European countries in the 1990s, or countries experiencing ",
      "both a demand contraction and currency stabilisation, are good starting points."
    ),
    variables    = c("inflation", "employment"),
    solution_countries = list(
      list(country = "Poland",    years = "1991–1995",
           note = "Rapid disinflation coincided with high unemployment during transition."),
      list(country = "Argentina", years = "2002–2004",
           note = "Inflation spiked then fell, but unemployment remained very high."),
      list(country = "Spain",     years = "2012–2016",
           note = "Austerity reduced inflation but unemployment exceeded 25%.")
    ),
    pedagogical_note = paste0(
      "The Phillips Curve relationship is empirically unstable. It held reasonably well ",
      "in the 1960s but broke down in the 1970s stagflation and again in various country ",
      "episodes. This challenge invites students to question whether macroeconomic ",
      "'laws' are really universal relationships or context-specific regularities."
    ),
    discussion_questions = c(
      "When would you expect inflation and unemployment to fall together?",
      "What is 'stagflation'? Can you find an example in the data?",
      "Why did the Phillips Curve break down in the 1970s?"
    )
  ),

  list(
    id           = "C03",
    title        = "Surplus AND Deficit",
    difficulty   = "Easy",
    icon         = "↔️",
    description  = paste0(
      "Find a country that simultaneously has a trade surplus (exports > imports) AND ",
      "a fiscal deficit (government spending > revenues) for the same year. This ",
      "challenges students who think surpluses and deficits always go together — ",
      "they are measuring different things!"
    ),
    hint         = paste0(
      "Many large manufacturing exporters run trade surpluses. But even if a country ",
      "exports a lot, its government can still spend more than it collects. Try looking ",
      "at South Korea, Germany, or Japan in different periods."
    ),
    variables    = c("fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "Japan",      years = "Most years 1990–2020",
           note = "Japan runs persistent trade surpluses but also persistent fiscal deficits."),
      list(country = "South Korea",years = "2008–2012",
           note = "Strong exports but fiscal stimulus during the financial crisis."),
      list(country = "Germany",    years = "2002–2005",
           note = "Trade surplus but fiscal deficit under pressure from slow growth.")
    ),
    pedagogical_note = paste0(
      "The trade balance and fiscal balance are related through the national accounts ",
      "identity (S – I = X – M = CA), but they can move in different directions. ",
      "A government can borrow (fiscal deficit) while its private sector saves and exports ",
      "vigorously. Use this challenge to introduce the distinction between the public sector ",
      "balance and the external balance."
    ),
    discussion_questions = c(
      "What is the difference between a trade deficit and a fiscal deficit?",
      "Could a country have a trade deficit AND a fiscal surplus? Find an example.",
      "The 'twin deficits' hypothesis says fiscal and trade deficits move together. Does the data support this?"
    )
  ),

  list(
    id           = "C04",
    title        = "The Macroeconomic All-Star",
    difficulty   = "Hard",
    icon         = "⭐",
    description  = paste0(
      "Find a country that achieved favourable outcomes on ALL FIVE indicators ",
      "simultaneously for at least three consecutive years: ",
      "positive GDP growth (>2%), employment rate above its historical average, ",
      "low inflation (<5%), fiscal balance close to balance (> –3% of GDP), ",
      "and non-negative trade balance. How long did this last? What ended it?"
    ),
    hint         = paste0(
      "Small open economies with strong institutions and commodity wealth sometimes ",
      "achieve this. Australia had an extraordinarily long period of uninterrupted growth. ",
      "South Korea in the mid-2000s, Chile in the mid-1990s, and some Nordic countries ",
      "are candidates."
    ),
    variables    = c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "Australia",  years = "1993–2007",
           note = "14 years of uninterrupted growth, low inflation, modest fiscal and trade positions."),
      list(country = "Chile",      years = "1991–1997",
           note = "Strong growth, fiscal discipline, improving trade balance, controlled inflation."),
      list(country = "South Korea",years = "2004–2007",
           note = "Solid performance across most indicators pre-crisis.")
    ),
    pedagogical_note = paste0(
      "This challenge highlights that sustained good macroeconomic performance is rare ",
      "and temporary. Students should notice what eventually disrupted the run (commodity ",
      "price shock, financial crisis, domestic policy shift). This reinforces the idea that ",
      "macroeconomic stability is not a steady state but requires continuous management ",
      "under changing conditions."
    ),
    discussion_questions = c(
      "What made Australia's long expansion possible?",
      "What finally ended the 'golden run' you found?",
      "Is it possible to permanently achieve all macroeconomic objectives at once?"
    )
  ),

  list(
    id           = "C05",
    title        = "Persistent Trade Surplus",
    difficulty   = "Easy",
    icon         = "📦",
    description  = paste0(
      "Find a country that has maintained a trade surplus (positive trade balance) ",
      "for at least 10 consecutive years. What does this tell you about the country's ",
      "economy? What are the possible explanations?"
    ),
    hint         = paste0(
      "Look at large manufacturing exporters and commodity exporters. Germany and South Korea ",
      "are famous for persistent surpluses. Some oil-exporting nations also qualify."
    ),
    variables    = c("trade_balance"),
    solution_countries = list(
      list(country = "Germany",    years = "1993–present",
           note = "Among the world's largest trade surpluses as % of GDP."),
      list(country = "South Korea",years = "1998–present",
           note = "Became a persistent surplus country after the 1997 crisis."),
      list(country = "China",      years = "1994–present",
           note = "Large and growing trade surpluses, source of global trade tensions.")
    ),
    pedagogical_note = paste0(
      "Persistent surpluses are sometimes praised (strong competitiveness) and sometimes ",
      "criticised (they must be matched by deficits elsewhere, possibly suppressing global demand). ",
      "The Keynesian and mercantilism debates are relevant here. Ask students: should the IMF ",
      "pressure surplus countries as much as deficit countries?"
    ),
    discussion_questions = c(
      "What industries or policies explain a persistent trade surplus?",
      "Is a trade surplus always good? Who might it hurt?",
      "If Germany runs a surplus, which countries must run deficits? Why?"
    )
  ),

  list(
    id           = "C06",
    title        = "Recovery Races",
    difficulty   = "Medium",
    icon         = "🏁",
    description  = paste0(
      "After the 2008 Global Financial Crisis, different countries recovered at very ",
      "different speeds. Compare at least three countries and identify which recovered ",
      "fastest in terms of GDP growth and which took longest to restore employment. ",
      "Do GDP recovery and employment recovery happen at the same speed?"
    ),
    hint         = paste0(
      "Compare Germany, Spain, the United States, and South Korea. Consider which country ",
      "returned to pre-crisis GDP levels fastest. Then ask which recovered employment fastest. ",
      "The answers may surprise you."
    ),
    variables    = c("gdp_growth", "employment"),
    solution_countries = list(
      list(country = "South Korea / Germany", years = "2009–2012",
           note = "Rapid GDP recovery but labour markets adjusted differently."),
      list(country = "Spain / Greece",        years = "2009–2016",
           note = "Prolonged recession; unemployment remained very high for years."),
      list(country = "United States",         years = "2009–2015",
           note = "GDP recovered before employment returned to pre-crisis levels.")
    ),
    pedagogical_note = paste0(
      "This challenge introduces the concept of 'scarring effects' — how crises can ",
      "cause long-term damage to employment even after GDP recovers. The contrast between ",
      "fast-recovering and slow-recovering economies raises questions about the role of ",
      "automatic stabilisers, labour market institutions, and exchange rate flexibility."
    ),
    discussion_questions = c(
      "Why might GDP recover before employment does?",
      "What role did the euro play in slowing Southern Europe's recovery?",
      "What policy choices might explain different recovery speeds?"
    )
  ),

  list(
    id           = "C07",
    title        = "Inflation Without Growth",
    difficulty   = "Medium",
    icon         = "🔥",
    description  = paste0(
      "Find a country that experienced high inflation (>10%) while simultaneously ",
      "having low or negative GDP growth. This pattern — called stagflation — ",
      "violates the standard assumption that inflation is primarily a problem of ",
      "overheating economies."
    ),
    hint         = paste0(
      "Argentina in various periods is a classic case. Look also at Venezuela, Zimbabwe, ",
      "or Turkey in specific years. Supply shocks (like oil price increases in the 1970s) ",
      "can also cause this pattern in many countries simultaneously."
    ),
    variables    = c("gdp_growth", "inflation"),
    solution_countries = list(
      list(country = "Argentina", years = "2014–2016, 2018–2019",
           note = "Multiple stagflationary episodes driven by monetary and confidence crises."),
      list(country = "Turkey",    years = "2018–2019",
           note = "Currency crisis produced inflation above 20% alongside slowing growth."),
      list(country = "South Africa", years = "2008–2009",
           note = "Food and energy shocks raised inflation while the GFC hit growth.")
    ),
    pedagogical_note = paste0(
      "Stagflation challenges the view that a simple trade-off exists between inflation and output. ",
      "It typically arises from supply-side shocks, currency crises, or structural problems ",
      "rather than demand overheating. This challenge is also a good entry point to discuss ",
      "the limitations of demand management policies when the problem is supply-side."
    ),
    discussion_questions = c(
      "If inflation is high but growth is low, should the central bank raise rates? What's the dilemma?",
      "What is a 'supply shock'? Give an example.",
      "Why was stagflation such a policy problem in the 1970s?"
    )
  )
)

# Named vector for UI selector
CHALLENGE_CHOICES <- setNames(
  seq_along(CHALLENGES),
  sapply(CHALLENGES, function(c) paste(c$icon, c$title, paste0("[", c$difficulty, "]")))
)

# Difficulty colors
DIFFICULTY_COLORS <- c(
  "Easy"   = "#16a34a",
  "Medium" = "#d97706",
  "Hard"   = "#dc2626"
)
