# =============================================================================
# HISTORICAL EVENTS DATA
# Connects macroeconomic data with major world economic events
# =============================================================================

HISTORICAL_EVENTS <- list(

  asian_crisis = list(
    id          = "asian_crisis",
    name        = "Crisis financiera asiática",
    short_name  = "Crisis asiática",
    year_start  = 1997,
    year_end    = 1999,
    peak_year   = 1998,
    color       = "#e74c3c",
    icon        = "⚡",
    description = paste0(
      "Crisis financiera que se extendió por el este y el sudeste de Asia a partir de ",
      "Tailandia, en julio de 1997. Devaluaciones bruscas, derrumbes bursátiles y quiebras ",
      "bancarias provocaron recesiones profundas. El FMI otorgó paquetes de rescate a ",
      "Tailandia, Indonesia y Corea del Sur, con condiciones de ajuste muy discutidas."
    ),
    macro_impact = paste0(
      "El crecimiento del PBI se desplomó en las economías afectadas: el PBI de Indonesia ",
      "cayó cerca de un 13% en 1998, y Corea del Sur y Tailandia también tuvieron recesiones ",
      "profundas. El desempleo subió. La inflación aumentó en los países con fuertes ",
      "devaluaciones. El resultado fiscal empeoró por el costo de rescatar a los bancos."
    ),
    key_lesson   = paste0(
      "Muestra cómo una crisis financiera puede contagiarse rápido entre países y cómo un ",
      "mismo shock afecta de manera distinta a distintas economías."
    ),
    affected_iso2c   = c("KR", "TH", "ID", "MY", "PH"),
    affected_regions = c("Asia oriental y Pacífico"),
    key_variables    = c("gdp_growth", "employment", "inflation")
  ),

  argentina_crisis = list(
    id          = "argentina_crisis",
    name        = "Crisis argentina de 2001–2002",
    short_name  = "Crisis argentina",
    year_start  = 1999,
    year_end    = 2003,
    peak_year   = 2002,
    color       = "#f39c12",
    icon        = "💥",
    description = paste0(
      "El colapso económico argentino incluyó el congelamiento de los depósitos ",
      "(el corralito), la cesación de pagos de unos 100.000 millones de dólares de deuda ",
      "soberana y el abandono de la Convertibilidad en enero de 2002. El peso perdió cerca ",
      "del 70% de su valor y el PBI cayó alrededor de un 20% desde su pico. El desempleo ",
      "superó el 20% y la pobreza se disparó."
    ),
    macro_impact = paste0(
      "El PBI cayó fuertemente (alrededor de –11% en 2002). El desempleo superó el 20%. ",
      "La inflación saltó después de la devaluación. El resultado fiscal empeoró mucho. ",
      "El saldo comercial mejoró porque la devaluación abarató las exportaciones y ",
      "encareció las importaciones."
    ),
    key_lesson   = paste0(
      "Un ejemplo de crisis que golpea a la vez la producción, el empleo, los precios y las ",
      "cuentas públicas. También muestra que el saldo comercial puede mejorar en plena ",
      "crisis (por la devaluación y la caída de las importaciones)."
    ),
    affected_iso2c   = c("AR"),
    affected_regions = c("América Latina y el Caribe"),
    key_variables    = c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance")
  ),

  gfc = list(
    id          = "gfc",
    name        = "Crisis financiera global",
    short_name  = "Crisis global (2008)",
    year_start  = 2008,
    year_end    = 2010,
    peak_year   = 2009,
    color       = "#8e44ad",
    icon        = "🏦",
    description = paste0(
      "Comenzó con el derrumbe del mercado de hipotecas de alto riesgo (subprime) de ",
      "Estados Unidos y la quiebra de grandes entidades financieras (Lehman Brothers, en ",
      "septiembre de 2008). Se extendió rápido por todo el mundo a través de los vínculos ",
      "financieros y causó la peor recesión global desde la Gran Depresión. Los gobiernos ",
      "lanzaron enormes programas de estímulo y rescates bancarios."
    ),
    macro_impact = paste0(
      "El crecimiento mundial se desplomó: la mayoría de las economías avanzadas tuvo ",
      "caídas del PBI en 2009. El desempleo subió mucho y siguió alto durante años ",
      "(sobre todo en el sur de Europa). La inflación primero bajó. Los resultados fiscales ",
      "empeoraron fuertemente por los estabilizadores automáticos y los paquetes de estímulo."
    ),
    key_lesson   = paste0(
      "Ilustra una recesión global sincronizada: casi todos los indicadores empeoraron a ",
      "la vez en la mayoría de los países. También muestra velocidades de recuperación muy ",
      "distintas: algunos países se recuperaron rápido (Alemania, Corea del Sur) y otros ",
      "tardaron años (Grecia, España)."
    ),
    affected_iso2c   = c("US", "GB", "DE", "FR", "ES", "GR", "JP", "KR", "AU"),
    affected_regions = c("Europa y Asia central", "América del Norte", "Asia oriental y Pacífico"),
    key_variables    = c("gdp_growth", "employment", "fiscal_balance")
  ),

  covid = list(
    id          = "covid",
    name        = "Pandemia de COVID-19",
    short_name  = "COVID-19 (2020)",
    year_start  = 2020,
    year_end    = 2022,
    peak_year   = 2020,
    color       = "#16a085",
    icon        = "🦠",
    description = paste0(
      "La pandemia de COVID-19 provocó la contracción económica mundial más brusca desde ",
      "la Segunda Guerra Mundial. Los confinamientos, los problemas en las cadenas de ",
      "suministro y el derrumbe de la demanda golpearon a casi todas las economías a la vez ",
      "en 2020. Estímulos fiscales y monetarios sin precedentes amortiguaron el golpe en ",
      "muchos países. La recuperación fue desigual y en 2021–22 llegó una suba rápida de la inflación."
    ),
    macro_impact = paste0(
      "El PBI mundial cayó alrededor de un 3,1% en 2020, la peor contracción en tiempos de ",
      "paz registrada. El empleo cayó fuertemente. Los déficits fiscales se dispararon por ",
      "los programas de asistencia. La inflación fue baja en 2020 y se aceleró en 2021–22. ",
      "Los saldos comerciales cambiaron por el desplazamiento del consumo de servicios a bienes."
    ),
    key_lesson   = paste0(
      "El shock global más sincronizado de la historia reciente. Compará la profundidad de ",
      "la caída entre países y la velocidad de la recuperación. También sirve para observar ",
      "la suba de la inflación que siguió a la recuperación."
    ),
    affected_iso2c   = c("US", "GB", "DE", "FR", "ES", "IT", "JP", "CN", "BR", "IN",
                         "MX", "ZA", "AU", "KR", "TR"),
    affected_regions = c("Asia oriental y Pacífico", "Europa y Asia central",
                         "América Latina y el Caribe", "América del Norte",
                         "Asia meridional", "África subsahariana"),
    key_variables    = c("gdp_growth", "employment", "fiscal_balance", "trade_balance")
  ),

  energy_crisis = list(
    id          = "energy_crisis",
    name        = "Crisis energética europea",
    short_name  = "Crisis energética (2022)",
    year_start  = 2021,
    year_end    = 2023,
    peak_year   = 2022,
    color       = "#e67e22",
    icon        = "⚡",
    description = paste0(
      "La invasión rusa de Ucrania, en febrero de 2022, agravó un mercado energético ya ",
      "ajustado y llevó los precios del gas y de la electricidad en Europa a máximos ",
      "históricos. Junto con los problemas de suministro posteriores a la pandemia, provocó ",
      "la inflación más alta en Europa en 40 años."
    ),
    macro_impact = paste0(
      "La inflación superó el 10% en muchos países europeos en 2022. El crecimiento se ",
      "desaceleró, aunque la mayoría de las economías europeas evitó la recesión. Los ",
      "resultados fiscales empeoraron por los subsidios a la energía. Los países ",
      "exportadores de energía (Noruega, algunos países del Golfo) se beneficiaron de los precios altos."
    ),
    key_lesson   = paste0(
      "Muestra un shock externo de oferta que genera inflación sin que haya un exceso de ",
      "demanda. También muestra que un mismo shock global puede beneficiar a algunas ",
      "economías (las exportadoras de energía) y perjudicar a otras (las importadoras)."
    ),
    affected_iso2c   = c("DE", "FR", "GB", "ES", "IT", "PL", "TR"),
    affected_regions = c("Europa y Asia central"),
    key_variables    = c("inflation", "gdp_growth", "fiscal_balance")
  )
)

# Ordered list for UI display
EVENT_CHOICES <- setNames(
  names(HISTORICAL_EVENTS),
  sapply(HISTORICAL_EVENTS, function(e) paste(e$icon, e$name, paste0("(", e$year_start, ")") ))
)
