# =============================================================================
# DISCOVERY CHALLENGES DATA
# Guided inquiry tasks for student exploration.
# Every quoted figure is checked against the bundled data by
# tests/testthat/test-challenge-keys.R.
# =============================================================================

CHALLENGES <- list(

  list(
    id           = "C01",
    title        = "Crecimiento sin empleo",
    difficulty   = "Media",
    icon         = "💼",
    description  = paste0(
      "Encontrá un país cuyo PBI haya crecido durante al menos cinco años seguidos ",
      "mientras su tasa de empleo se mantenía o bajaba. Este patrón, a veces llamado ",
      "\"crecimiento sin empleo\", cuestiona la idea de que el crecimiento del PBI crea ",
      "empleo automáticamente."
    ),
    hint         = paste0(
      "Mirá economías que se industrializaron rápido en los años noventa y dos mil, o ",
      "países que invirtieron mucho en industrias intensivas en capital. Revisá también ",
      "el sudeste asiático en la década de 2010 y las economías en transición de Europa del Este."
    ),
    variables    = c("gdp_growth", "employment"),
    solution_countries = list(
      list(country = "China",     years = "1991–2005",
           note = "Creció cerca del 10% anual mientras la tasa de empleo bajó del 77% al 69%, porque mucha gente dejó el trabajo rural y estudió más años."),
      list(country = "Tailandia", years = "2010–2019",
           note = "Diez años de crecimiento (3,6% anual en promedio) mientras la tasa de empleo bajó del 71% al 67%, en parte por el envejecimiento de la población."),
      list(country = "Serbia",    years = "2000–2008",
           note = "Fuerte crecimiento después de la transición mientras la tasa de empleo bajó del 49% al 46% por la reestructuración de empresas estatales.")
    ),
    pedagogical_note = paste0(
      "El crecimiento sin empleo suele aparecer en períodos de cambio tecnológico rápido ",
      "o de transformación estructural. Ojo: la tasa de empleo también puede bajar por ",
      "razones que no tienen que ver con la falta de trabajo (más años de estudio, ",
      "envejecimiento de la población). Por eso el principal indicador del pleno empleo ",
      "es la tasa de desempleo: la parte de la población económicamente activa que busca ",
      "trabajo y no lo encuentra. El desafío también abre preguntas distributivas: ",
      "¿quién se beneficia del crecimiento? Se puede vincular con los debates sobre ",
      "automatización y desigualdad del ingreso."
    ),
    discussion_questions = c(
      "¿Por qué el PBI podría crecer sin que el empleo crezca en la misma proporción?",
      "¿Quién se beneficia del crecimiento si el empleo no aumenta?",
      "¿Qué políticas podrían convertir un crecimiento sin empleo en uno que genere trabajo?"
    )
  ),

  list(
    id           = "C02",
    title        = "El costo de bajar la inflación",
    difficulty   = "Difícil",
    icon         = "📉",
    description  = paste0(
      "Bajar la inflación puede tener un costo en empleo y actividad: es un ejemplo de ",
      "tensión entre objetivos. Encontrá un período de tres a cinco años en el que la ",
      "inflación haya bajado mucho (a menos de la mitad de su nivel inicial) mientras la ",
      "tasa de empleo también bajaba. Después buscá un contraejemplo: un período en el ",
      "que la inflación bajó y el empleo subió."
    ),
    hint         = paste0(
      "Mirá los planes de estabilización de principios de los noventa: países de América ",
      "Latina que dejaban atrás la alta inflación y economías poscomunistas de Europa del Este. ",
      "Para el contraejemplo, mirá la Argentina después de la crisis de 2002."
    ),
    variables    = c("inflation", "employment"),
    solution_countries = list(
      list(country = "Argentina", years = "1991–1994",
           note = "La Convertibilidad bajó la inflación del 172% al 4% mientras la tasa de empleo caía del 56,7% al 54,7%."),
      list(country = "Brasil",    years = "1992–1996",
           note = "La inflación bajó del 952% al 16% con el Plan Real mientras la tasa de empleo caía del 60,4% al 58,8%."),
      list(country = "Polonia",   years = "1991–1994",
           note = "Desinflación durante la transición (del 77% al 33%) mientras la tasa de empleo caía del 53,0% al 50,9%."),
      list(country = "Argentina (contraejemplo)", years = "2002–2004",
           note = "La inflación bajó del 26% al 4% mientras la tasa de empleo subía del 48,4% al 53,6% en la recuperación posterior a la crisis.")
    ),
    pedagogical_note = paste0(
      "Reducir la inflación mientras se desacelera la actividad es una de las tensiones ",
      "entre objetivos que plantea el curso, y es lo que predice la curva de Phillips. ",
      "El contraejemplo muestra que la relación no es una ley fija: depende del punto de ",
      "partida y del contexto. La curva de Phillips funcionó razonablemente bien en los ",
      "años sesenta, pero dejó de cumplirse con la estanflación de los setenta (ver ",
      "\"Inflación sin crecimiento\")."
    ),
    discussion_questions = c(
      "Tus casos, ¿confirman o cuestionan la idea de una disyuntiva entre inflación y empleo?",
      "¿Por qué en la Argentina de 2002–2004 la inflación pudo bajar mientras el empleo subía?",
      "¿Valió la pena el costo en empleo de bajar la inflación? ¿Qué más necesitarías saber para juzgarlo?"
    )
  ),

  list(
    id           = "C03",
    title        = "Superávit y déficit a la vez",
    difficulty   = "Fácil",
    icon         = "↔️",
    description  = paste0(
      "Encontrá un país que en un mismo año tenga superávit comercial (exportaciones ",
      "mayores que importaciones) y déficit fiscal (gastos del Estado mayores que sus ",
      "ingresos). Sirve para ver que un superávit y un déficit pueden convivir: ",
      "¡miden cosas distintas!"
    ),
    hint         = paste0(
      "Muchos grandes exportadores industriales tienen superávit comercial. Pero aunque un ",
      "país exporte mucho, su Estado puede gastar más de lo que recauda. Probá con Japón, ",
      "Alemania o Malasia en distintos períodos."
    ),
    variables    = c("fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "Japón",    years = "1993–2010",
           note = "Superávit comercial todos los años junto con déficits fiscales de hasta el 10% del PBI. Desde 2011 el saldo comercial también pasó a ser negativo."),
      list(country = "Alemania", years = "2002–2005",
           note = "Superávit comercial de entre el 3,6% y el 5% del PBI, con un déficit fiscal mayor al 3% del PBI en años de bajo crecimiento."),
      list(country = "Malasia",  years = "1998–2023",
           note = "Superávit comercial y déficit fiscal en todos los años desde la crisis asiática.")
    ),
    pedagogical_note = paste0(
      "El saldo comercial y el resultado fiscal están vinculados por la identidad de las ",
      "cuentas nacionales (S – I = X – M), pero pueden moverse en direcciones distintas. ",
      "El Estado puede endeudarse (déficit fiscal) mientras el sector privado ahorra y ",
      "exporta mucho. Sirve para presentar la diferencia entre el resultado del sector ",
      "público y el resultado externo."
    ),
    discussion_questions = c(
      "¿Qué diferencia hay entre un déficit comercial y un déficit fiscal?",
      "¿Podría un país tener déficit comercial y superávit fiscal a la vez? Buscá un ejemplo.",
      "La hipótesis de los \"déficits gemelos\" dice que el déficit fiscal y el comercial se mueven juntos. ¿Los datos la confirman?"
    )
  ),

  list(
    id           = "C04",
    title        = "¿Bien hoy, sostenible mañana?",
    difficulty   = "Difícil",
    icon         = "⭐",
    description  = paste0(
      "Encontrá un país al que le haya ido bien en los tres objetivos centrales durante ",
      "al menos tres años seguidos: crecimiento del PBI mayor al 2%, una tasa de empleo ",
      "por encima de su propio promedio de 1990–2023 e inflación de entre 0% y 5%. ",
      "Después mirá la sostenibilidad en esos mismos años: ¿qué pasaba con el resultado ",
      "fiscal y con el saldo comercial? ¿Podía durar la buena racha? ¿Qué la terminó?"
    ),
    hint         = paste0(
      "Mirá el sur de Europa en los años previos a 2008 y el este de Asia en la década ",
      "de 2010. Compará un caso en el que se acumularon grandes déficits durante los años ",
      "buenos con otro en el que no."
    ),
    variables    = c("gdp_growth", "employment", "inflation", "fiscal_balance", "trade_balance"),
    solution_countries = list(
      list(country = "España",        years = "2001–2007",
           note = "Buenos resultados centrales y cuentas públicas equilibradas, pero un déficit comercial de hasta el 6% del PBI. La crisis de 2008 terminó la racha: el PBI cayó en 2009 y otra vez en 2011–2013."),
      list(country = "Grecia",        years = "1998–2004",
           note = "Buenos resultados centrales junto con déficits fiscales del 4% al 9% del PBI y déficits comerciales del 9% al 11% del PBI todos los años: los desequilibrios detrás de la crisis de deuda de 2010."),
      list(country = "Corea del Sur", years = "2013–2019",
           note = "Buenos resultados centrales con superávit fiscal y comercial todos los años. La racha terminó con la pandemia de 2020, no por un desequilibrio propio.")
    ),
    pedagogical_note = paste0(
      "Los buenos resultados de hoy no alcanzan para evaluar una economía: puede crecer, ",
      "crear empleo y mantener la inflación baja mientras acumula desequilibrios que ",
      "hacen difícil sostener esos resultados. Un déficit no es automáticamente un ",
      "problema; lo que importa es si puede financiarse en el tiempo. La app muestra el ",
      "saldo comercial y no la balanza de pagos completa, y no tiene datos de deuda ",
      "pública, así que conviene pedir que digan qué información adicional necesitarían ",
      "para llegar a una conclusión firme."
    ),
    discussion_questions = c(
      "¿Cuáles de tus casos parecían sostenibles y cuáles no? ¿En qué datos te basaste?",
      "¿Qué terminó con la buena racha que encontraste?",
      "¿Qué otra información (deuda pública, cómo se financiaban los déficits) necesitarías para tener certeza?"
    )
  ),

  list(
    id           = "C05",
    title        = "Superávit comercial persistente",
    difficulty   = "Fácil",
    icon         = "📦",
    description  = paste0(
      "Encontrá un país que haya tenido superávit comercial (saldo comercial positivo) ",
      "durante al menos 10 años seguidos. ¿Qué te dice eso sobre su economía? ¿Cuáles ",
      "pueden ser las explicaciones?"
    ),
    hint         = paste0(
      "Mirá grandes exportadores industriales y exportadores de materias primas. Alemania ",
      "y Corea del Sur son conocidas por sus superávits persistentes. Algunos países ",
      "petroleros también cumplen la condición."
    ),
    variables    = c("trade_balance"),
    solution_countries = list(
      list(country = "Alemania",      years = "1993–2023",
           note = "Uno de los mayores superávits comerciales del mundo en porcentaje del PBI."),
      list(country = "Corea del Sur", years = "1998–2007, 2009–2023",
           note = "Pasó a tener superávit persistente después de la crisis de 1997, con un solo año de déficit en 2008."),
      list(country = "China",         years = "1994–2023",
           note = "Superávits comerciales grandes y crecientes, fuente de tensiones comerciales globales.")
    ),
    pedagogical_note = paste0(
      "Los superávits persistentes a veces se elogian (por la competitividad que reflejan) ",
      "y a veces se critican (deben compensarse con déficits en otros países y pueden ",
      "deprimir la demanda mundial). Son pertinentes los debates keynesianos y sobre el ",
      "mercantilismo. Pregunta para la clase: ¿el FMI debería presionar a los países con ",
      "superávit tanto como a los que tienen déficit?"
    ),
    discussion_questions = c(
      "¿Qué industrias o políticas explican un superávit comercial persistente?",
      "¿Un superávit comercial es siempre bueno? ¿A quién podría perjudicar?",
      "Si Alemania tiene superávit, ¿qué países tienen que tener déficit? ¿Por qué?"
    )
  ),

  list(
    id           = "C06",
    title        = "Carrera de recuperación",
    difficulty   = "Media",
    icon         = "🏁",
    description  = paste0(
      "Después de la crisis financiera global de 2008, los países se recuperaron a ",
      "velocidades muy distintas. Compará al menos tres países: ¿cuál recuperó más rápido ",
      "el crecimiento del PBI y cuál tardó más en recuperar el empleo? ¿El PBI y el empleo ",
      "se recuperan al mismo ritmo?"
    ),
    hint         = paste0(
      "Compará Alemania, España, Estados Unidos y Corea del Sur. Fijate qué país volvió ",
      "más rápido a crecer y cuál recuperó antes el empleo. Las respuestas pueden sorprenderte."
    ),
    variables    = c("gdp_growth", "employment"),
    solution_countries = list(
      list(country = "Corea del Sur / Alemania", years = "2009–2012",
           note = "Rápida recuperación del PBI, pero los mercados de trabajo se ajustaron de forma distinta."),
      list(country = "España / Grecia",          years = "2009–2016",
           note = "Recesión prolongada; el desempleo siguió muy alto durante años."),
      list(country = "Estados Unidos",           years = "2009–2015",
           note = "El PBI se recuperó antes de que el empleo volviera a los niveles previos a la crisis.")
    ),
    pedagogical_note = paste0(
      "Este desafío introduce la idea de \"cicatrices\": las crisis pueden dañar el empleo ",
      "por mucho tiempo incluso después de que el PBI se recupera. El contraste entre ",
      "economías que se recuperaron rápido y lento abre preguntas sobre el papel de los ",
      "estabilizadores automáticos, las instituciones del mercado de trabajo y la ",
      "flexibilidad del tipo de cambio."
    ),
    discussion_questions = c(
      "¿Por qué el PBI podría recuperarse antes que el empleo?",
      "¿Qué papel tuvo el euro en la lenta recuperación del sur de Europa?",
      "¿Qué decisiones de política podrían explicar las distintas velocidades de recuperación?"
    )
  ),

  list(
    id           = "C07",
    title        = "Inflación sin crecimiento",
    difficulty   = "Media",
    icon         = "🔥",
    description  = paste0(
      "Encontrá un país con inflación alta (más del 10%) y, al mismo tiempo, crecimiento ",
      "del PBI bajo o negativo. Este patrón, llamado estanflación, contradice la idea de ",
      "que la inflación es sobre todo un problema de economías recalentadas."
    ),
    hint         = paste0(
      "La Argentina en distintos períodos es un caso clásico. Mirá también Venezuela, ",
      "Zimbabue o Turquía en algunos años. Los shocks de oferta (como las subas del ",
      "petróleo de los años setenta) también pueden generar este patrón en muchos países a la vez."
    ),
    variables    = c("gdp_growth", "inflation"),
    solution_countries = list(
      list(country = "Argentina", years = "2014, 2016, 2018–2019",
           note = "El PBI cayó en cada uno de esos años con una inflación de entre el 34% y el 54%."),
      list(country = "Turquía",   years = "2019",
           note = "Después de una crisis cambiaria, la inflación siguió por encima del 15% mientras el crecimiento bajaba al 1,3%."),
      list(country = "Nigeria",   years = "2016",
           note = "La caída del precio del petróleo hizo bajar el PBI un 1,6% mientras la inflación subía del 9% al 16%.")
    ),
    pedagogical_note = paste0(
      "La estanflación cuestiona la idea de una disyuntiva simple entre inflación y ",
      "producción. Suele originarse en shocks de oferta, crisis cambiarias o problemas ",
      "estructurales, más que en un exceso de demanda. También es una buena puerta de ",
      "entrada para discutir los límites de las políticas de demanda cuando el problema ",
      "es de oferta."
    ),
    discussion_questions = c(
      "Si la inflación es alta y el crecimiento bajo, ¿el banco central debería subir la tasa de interés? ¿Cuál es el dilema?",
      "¿Qué es un \"shock de oferta\"? Dá un ejemplo.",
      "¿Por qué la estanflación fue un problema tan difícil para la política económica en los años setenta?"
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
  "Fácil"   = "#16a34a",
  "Media"   = "#d97706",
  "Difícil" = "#dc2626"
)
