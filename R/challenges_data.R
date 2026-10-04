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
      "Southeast Asia in the 2010s and Eastern European transition economies."
    ),
    variables    = c("gdp_growth", "employment"),
    solution_countries = list(
      list(country = "China",    years = "1991–2005",
           note = "Growth near 10% a year while the employment rate fell from 77% to 69%, as people left farm work and stayed longer in education."),
      list(country = "Thailand", years = "2010–2019",
           note = "Ten years of growth (3.6% a year on average) while the employment rate fell from 71% to 67%, partly because the population aged."),
      list(country = "Serbia",   years = "2000–2008",
           note = "Strong post-transition growth while the employment rate fell from 49% to 46% as state firms were restructured.")
    ),
    pedagogical_note = paste0(
      "Jobless growth often occurs during periods of rapid technological change or ",
      "structural transformation. Note that the employment rate can also fall for reasons ",
      "unrelated to a lack of jobs (more years of schooling, an ageing population), which is ",
      "why the unemployment rate (people looking for work who cannot find it) is the main ",
      "indicator for the full-employment objective. It raises important distributional questions: who ",
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
    title        = "The Cost of Bringing Inflation Down",
    difficulty   = "Hard",
    icon         = "📉",
    description  = paste0(
      "Bringing inflation down can come at a cost in jobs and activity — an example of ",
      "two objectives in tension. Find a period of three to five years in which inflation ",
      "fell sharply (to less than half its starting level) while the employment rate also ",
      "fell. Then look for a counter-example: a period in which inflation fell and ",
      "employment rose."
    ),
    hint         = paste0(
      "Look at the stabilisation plans of the early 1990s: Latin American countries ",
      "leaving high inflation behind, and post-communist economies in Eastern Europe. ",
      "For the counter-example, look at Argentina just after the 2002 crisis."
    ),
    variables    = c("inflation", "employment"),
    solution_countries = list(
      list(country = "Argentina", years = "1991–1994",
           note = "The Convertibility plan cut inflation from 172% to 4% while the employment rate fell from 56.7% to 54.7%."),
      list(country = "Brazil",    years = "1992–1996",
           note = "Inflation fell from 952% to 16% around the Plan Real while the employment rate fell from 60.4% to 58.8%."),
      list(country = "Poland",    years = "1991–1994",
           note = "Transition-era disinflation (77% to 33%) while the employment rate fell from 53.0% to 50.9%."),
      list(country = "Argentina (counter-example)", years = "2002–2004",
           note = "Inflation fell from 26% to 4% while the employment rate rose from 48.4% to 53.6% in the recovery after the crisis.")
    ),
    pedagogical_note = paste0(
      "Reducing inflation while activity slows is one of the tensions between objectives ",
      "the course describes, and it is what the Phillips Curve predicts. The counter-example ",
      "shows the relationship is not a fixed law: it depends on the starting point and the ",
      "context. The Phillips Curve held reasonably well in the 1960s but broke down in the ",
      "1970s stagflation (see 'Inflation Without Growth')."
    ),
    discussion_questions = c(
      "Do your cases confirm or challenge the idea of a trade-off between inflation and employment?",
      "Why could inflation fall while employment rose in Argentina in 2002–2004?",
      "Was bringing inflation down worth the cost in jobs? What else would you need to know to judge?"
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
      "at Japan, Germany, or Malaysia in different periods."
    ),
    variables    = c("fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "Japan",      years = "1993–2010",
           note = "Trade surpluses every year alongside fiscal deficits of up to 10% of GDP. From 2011 the trade balance turned negative too."),
      list(country = "Germany",    years = "2002–2005",
           note = "Trade surplus of 3.6–5% of GDP but a fiscal deficit above 3% of GDP while growth was slow."),
      list(country = "Malaysia",   years = "1998–2023",
           note = "A trade surplus and a fiscal deficit in every year since the Asian crisis.")
    ),
    pedagogical_note = paste0(
      "The trade balance and fiscal balance are related through the national accounts ",
      "identity (S – I = X – M), but they can move in different directions. ",
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
    title        = "Good Today, Sustainable Tomorrow?",
    difficulty   = "Hard",
    icon         = "⭐",
    description  = paste0(
      "Find a country that did well on the three central objectives for at least three ",
      "consecutive years: GDP growth above 2%, an employment rate above its own 1990–2023 ",
      "average, and inflation between 0% and 5%. Then look at the sustainability side for ",
      "the same years: what were the fiscal balance and the trade balance doing? ",
      "Could the good run last? What ended it?"
    ),
    hint         = paste0(
      "Look at Southern Europe in the years before 2008, and at East Asia in the 2010s. ",
      "Compare a case where large deficits built up during the good years with one ",
      "where they did not."
    ),
    variables    = c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "Spain",      years = "2001–2007",
           note = "Good central results and a balanced budget, but a trade deficit of up to 6% of GDP. The 2008 crisis ended the run: GDP fell in 2009 and again in 2011–2013."),
      list(country = "Greece",     years = "1998–2004",
           note = "Good central results alongside fiscal deficits of 4–9% of GDP and trade deficits of 9–11% of GDP every year: the imbalances behind the 2010 debt crisis."),
      list(country = "South Korea",years = "2013–2019",
           note = "Good central results with fiscal and trade surpluses in every year. The run ended with the 2020 pandemic, not with a domestic imbalance.")
    ),
    pedagogical_note = paste0(
      "Good results today are not enough to judge an economy: it can grow, create jobs and ",
      "keep inflation low while building up imbalances that make those results hard to ",
      "sustain. Deficits are not automatically a problem; what matters is whether they can ",
      "be financed over time. Note that the app shows the trade balance, not the full balance ",
      "of payments, and has no public-debt series, so students should say what extra ",
      "information they would need to reach a firm conclusion."
    ),
    discussion_questions = c(
      "Which of your cases looked sustainable, and which did not? What evidence did you use?",
      "What finally ended the good run you found?",
      "What other information (public debt, how the deficits were financed) would you need to be sure?"
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
      list(country = "Germany",    years = "1993–2023",
           note = "Among the world's largest trade surpluses as % of GDP."),
      list(country = "South Korea",years = "1998–2007, 2009–2023",
           note = "Became a persistent surplus country after the 1997 crisis, with a single deficit year in 2008."),
      list(country = "China",      years = "1994–2023",
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
      list(country = "Argentina", years = "2014, 2016, 2018–2019",
           note = "GDP fell in each of these years while inflation ran between 34% and 54%."),
      list(country = "Turkey",    years = "2019",
           note = "After a currency crisis, inflation stayed above 15% while growth slowed to 1.3%."),
      list(country = "Nigeria",   years = "2016",
           note = "The oil price collapse pushed GDP down 1.6% while inflation rose from 9% to 16%.")
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
