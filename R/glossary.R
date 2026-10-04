# =============================================================================
# GLOSSARY
# Macroeconomic term definitions for undergraduate students, following the
# course notes "La mirada macroeconómica: objetivos e indicadores". The terms
# and their wording come from the glossary of the notes; the entries marked
# "indicador de la app" or in the last categories add what the app needs (the
# series it shows, statistics, policies). Order: GLOSSARY_ORDER, the structure
# of the notes, not alphabetical.
# =============================================================================

GLOSSARY_TERMS <- list(

  list(
    term       = "Macroeconomía",
    category   = "Conceptos generales",
    definition = paste0(
      "Parte de la economía que estudia el funcionamiento de la economía considerada en su ",
      "conjunto: producción, empleo, precios y relaciones con el exterior. No deja de importar ",
      "lo que hacen las personas, las empresas o el Estado: interesa cómo esas decisiones se ",
      "reflejan en resultados agregados, es decir, que corresponden a toda la economía y no a un ",
      "participante en particular."
    ),
    example    = "Que una empresa contrate a 50 personas es un dato de una empresa; la tasa de desempleo de todo el país es un resultado agregado.",
    related    = "Objetivo macroeconómico, Indicador"
  ),

  list(
    term       = "Objetivo macroeconómico",
    category   = "Conceptos generales",
    definition = paste0(
      "Resultado que se busca alcanzar o preservar en una economía. Los objetivos centrales ",
      "son el crecimiento económico, el pleno empleo y la estabilidad de precios; los objetivos ",
      "de sostenibilidad son la sostenibilidad fiscal y la sostenibilidad externa. Un objetivo ",
      "no es lo mismo que el indicador que se usa para observarlo."
    ),
    example    = "Un termómetro permite saber si una persona tiene fiebre, pero el objetivo no es cambiar el número del termómetro, sino que la persona esté sana.",
    related    = "Indicador, Crecimiento económico, Pleno empleo, Estabilidad de precios, Sostenibilidad"
  ),

  list(
    term       = "Indicador",
    category   = "Conceptos generales",
    definition = paste0(
      "Variable que permite observar y evaluar la evolución de una determinada situación u ",
      "objetivo. Indicadores principales: el PBI real para el crecimiento económico, la tasa de ",
      "desempleo para el pleno empleo, el IPC y la inflación para la estabilidad de precios; para ",
      "la sostenibilidad, el resultado fiscal junto con la trayectoria de la deuda pública (fiscal) ",
      "y la balanza de pagos junto con otros indicadores externos (externa)."
    ),
    example    = "El PBI real no es el objetivo: el objetivo es el crecimiento económico, y el PBI real nos da información para analizarlo.",
    related    = "Objetivo macroeconómico, PBI real, Tasa de desempleo, IPC (Índice de Precios al Consumidor)"
  ),

  list(
    term       = "Crecimiento económico",
    category   = "Producción",
    definition = paste0(
      "Aumento de la producción de bienes y servicios de una economía a lo largo del tiempo. Es ",
      "un objetivo macroeconómico central; su indicador principal es el PBI real. Crecimiento ",
      "económico ≠ PBI: el crecimiento es la evolución de la producción, y el PBI real es el ",
      "indicador que usamos para observarla."
    ),
    example    = "Un país puede tener un PBI muy grande y no estar creciendo, si este año produce lo mismo que el año anterior.",
    related    = "PBI, PBI real, Crecimiento del PBI, Objetivo macroeconómico"
  ),

  list(
    term       = "PBI (Producto Bruto Interno)",
    category   = "Producción",
    definition = paste0(
      "Valor de los bienes y servicios finales producidos dentro de una economía durante un ",
      "período determinado. Su valor puede cambiar por dos motivos: porque se producen más o ",
      "menos bienes y servicios, o porque cambian sus precios. Por eso se distingue entre PBI ",
      "nominal y PBI real."
    ),
    example    = "Un país con un PBI muy grande no es por eso un país que crece: crecer es producir más que antes.",
    related    = "PBI nominal, PBI real, Crecimiento económico"
  ),

  list(
    term       = "PBI real",
    category   = "Producción",
    definition = paste0(
      "Medida de la producción que descuenta el efecto de los cambios de precios y permite ",
      "observar, en términos generales, cómo evolucionan las cantidades producidas. Es el ",
      "principal indicador del crecimiento económico: para comparar cuánto produce una economía ",
      "en distintos momentos interesa su evolución."
    ),
    example    = "Si el PBI real aumenta respecto del año anterior, la producción de la economía aumentó.",
    related    = "PBI nominal, Crecimiento del PBI, Crecimiento económico"
  ),

  list(
    term       = "Empleo",
    category   = "Empleo",
    definition = paste0(
      "Situación de las personas que realizan un trabajo a cambio de un ingreso."
    ),
    example    = "Quien atiende un comercio a cambio de un sueldo tiene empleo.",
    related    = "Desempleo, Tasa de empleo, Población económicamente activa"
  ),

  list(
    term       = "Desempleo",
    category   = "Empleo",
    definition = paste0(
      "Situación de las personas que no tienen trabajo, quieren trabajar y lo buscan ",
      "activamente."
    ),
    example    = "Quien estudia a tiempo completo y no busca trabajo no está desempleado: no forma parte de la población económicamente activa.",
    related    = "Tasa de desempleo, Población económicamente activa, Empleo"
  ),

  list(
    term       = "Estabilidad de precios",
    category   = "Precios",
    definition = paste0(
      "Situación en la que no existe una inflación elevada e inestable, que dificulte las ",
      "decisiones de hogares y empresas. No significa que ningún precio pueda aumentar. Es un ",
      "objetivo macroeconómico central; se observa con el IPC y la inflación."
    ),
    example    = "Que suba el precio de un producto no implica que falte estabilidad de precios: lo que importa es el nivel general de precios.",
    related    = "Nivel general de precios, Inflación, IPC (Índice de Precios al Consumidor)"
  ),

  list(
    term       = "Nivel general de precios",
    category   = "Precios",
    definition = paste0(
      "Nivel promedio de los precios de los bienes y servicios de una economía. Es lo que ",
      "interesa a nivel macroeconómico: que algunos precios suban o bajen no significa ",
      "necesariamente que exista inflación."
    ),
    example    = "Si sube el precio de las verduras pero baja el de la ropa, el nivel general de precios puede casi no cambiar.",
    related    = "Inflación, Deflación, Estabilidad de precios"
  ),

  list(
    term       = "Déficit fiscal",
    category   = "Sector público",
    definition = paste0(
      "Situación en la que los gastos del Estado superan sus ingresos. Hay que financiarlo, ",
      "por ejemplo pidiendo prestado, y de ahí surge la deuda pública. Déficit fiscal ≠ ",
      "necesariamente un problema: puede ser transitorio y compatible con una situación fiscal ",
      "sostenible."
    ),
    example    = "Durante una recesión, un Estado puede tener déficit porque cae la recaudación. Si la deuda se mantiene estable en relación con el tamaño de la economía, eso no implica una situación insostenible.",
    related    = "Resultado fiscal, Superávit fiscal, Deuda pública, Sostenibilidad fiscal"
  ),

  list(
    term       = "Superávit fiscal",
    category   = "Sector público",
    definition = paste0(
      "Situación en la que los ingresos del Estado superan sus gastos."
    ),
    example    = "Si el Estado recauda el 22% del PBI y gasta el 20%, tiene un superávit fiscal del 2% del PBI.",
    related    = "Resultado fiscal, Déficit fiscal"
  ),

  list(
    term       = "Sector externo",
    category   = "Sector externo",
    definition = paste0(
      "Conjunto de relaciones económicas que una economía mantiene con el resto del mundo: ",
      "compra y venta de bienes y servicios, pagos, ingresos provenientes del exterior, ",
      "inversiones y préstamos internacionales."
    ),
    example    = "Exportar soja, recibir una inversión extranjera y pagar intereses de una deuda externa son operaciones del sector externo.",
    related    = "Balanza de pagos, Sostenibilidad externa"
  ),

  list(
    term       = "Balanza comercial",
    category   = "Sector externo",
    definition = paste0(
      "Registro de las exportaciones e importaciones de bienes. Es más acotada que la balanza ",
      "de pagos: balanza comercial ≠ balanza de pagos. El indicador \"Saldo comercial\" de esta ",
      "app mide un concepto cercano, que incluye también los servicios."
    ),
    example    = "Si un país exporta bienes por 100 e importa bienes por 120, su balanza comercial tiene un déficit de 20.",
    related    = "Saldo comercial, Balanza de pagos"
  ),

  list(
    term       = "Déficit y superávit externo",
    category   = "Sector externo",
    definition = paste0(
      "Cuando los pagos que un país realiza al exterior por sus compras y otros gastos superan ",
      "los ingresos que recibe por sus ventas y otros cobros, tiene un déficit externo; en la ",
      "situación contraria, un superávit externo. El déficit comercial es un caso particular: ",
      "las importaciones de bienes superan a las exportaciones. Ninguno de los dos resultados es ",
      "automáticamente bueno o malo: un déficit externo tiene que financiarse, por ejemplo, con ",
      "inversiones o préstamos provenientes del exterior. Déficit externo ≠ necesariamente ",
      "insostenibilidad externa."
    ),
    example    = "Un déficit externo financiado con inversión extranjera directa no genera la misma vulnerabilidad que uno financiado con préstamos de corto plazo.",
    related    = "Cuenta corriente, Saldo comercial, Sostenibilidad externa, Inversión extranjera directa"
  ),

  list(
    term       = "Crecimiento del PBI",
    category   = "Producción",
    definition = paste0(
      "Indicador de la app: variación porcentual anual del Producto Bruto Interno (PBI) real, ",
      "es decir, medido a precios constantes. El PBI nominal usa los precios de cada año, así ",
      "que puede aumentar solo porque subieron los precios; el PBI real descuenta ese efecto y ",
      "muestra si la economía produjo más. El crecimiento económico es el objetivo; la ",
      "variación del PBI real es el indicador que usamos para observarlo."
    ),
    example    = "Si el PBI real crece un 3%, la economía produjo un 3% más de bienes y servicios que el año anterior.",
    related    = "Crecimiento económico, PBI real, PBI nominal, Recesión"
  ),

  list(
    term       = "PBI nominal",
    category   = "Producción",
    definition = paste0(
      "PBI valuado a los precios de cada período (precios corrientes). Puede aumentar solo ",
      "porque suben los precios, sin que la economía produzca más. Para saber si aumentó la ",
      "producción hay que mirar el PBI real, que descuenta el efecto de los cambios de precios."
    ),
    example    = "Si una economía produce exactamente lo mismo que el año pasado pero todos los precios suben un 20%, el PBI nominal aumenta un 20% y el PBI real no cambia.",
    related    = "PBI (Producto Bruto Interno), PBI real, Crecimiento del PBI, Inflación"
  ),

  list(
    term       = "Recesión",
    category   = "Producción",
    definition = paste0(
      "Período de caída sostenida de la producción, los ingresos y el empleo. Con datos ",
      "trimestrales, una regla práctica habitual es dos trimestres seguidos de caída del PBI ",
      "real. Esta app usa datos anuales, así que un año con caída del PBI es una señal de ",
      "recesión, no una definición. Las recesiones suelen venir con más desempleo, menos ",
      "inversión y menos consumo. La crisis financiera global de 2008–09 provocó recesiones ",
      "simultáneas en muchos países."
    ),
    example    = "En 2020 muchos países tuvieron su recesión más profunda en décadas por la pandemia de COVID-19.",
    related    = "Crecimiento del PBI, Ciclo económico, Tasa de desempleo"
  ),

  list(
    term       = "Pleno empleo",
    category   = "Empleo",
    definition = paste0(
      "Situación en la que no existe un nivel elevado y persistente de desempleo involuntario. ",
      "No significa desempleo cero: en cualquier economía hay personas que están cambiando de ",
      "trabajo o que acaban de empezar a buscar. Su indicador principal es la tasa de desempleo."
    ),
    example    = "Una persona que renunció a su trabajo y tarda algunas semanas en conseguir otro figura como desempleada, aunque la economía ofrezca muchas oportunidades laborales.",
    related    = "Tasa de desempleo, Población económicamente activa"
  ),

  list(
    term       = "Población económicamente activa",
    category   = "Empleo",
    definition = paste0(
      "Conjunto de personas que trabajan o que buscan trabajo activamente. Es la base sobre la ",
      "que se calcula la tasa de desempleo."
    ),
    example    = "Si en una economía 100 personas trabajan o buscan trabajo, la población económicamente activa es de 100 personas.",
    related    = "Tasa de desempleo, Pleno empleo"
  ),

  list(
    term       = "Tasa de desempleo",
    category   = "Empleo",
    definition = paste0(
      "Porcentaje de la población económicamente activa que busca trabajo y no lo encuentra. ",
      "Una persona está desempleada cuando no tiene trabajo, quiere trabajar y lo busca ",
      "activamente. Es el principal indicador del pleno empleo. La app usa la estimación de ",
      "la OIT publicada por el Banco Mundial, disponible desde 1991."
    ),
    example    = "Si de 100 personas que trabajan o buscan trabajo, 8 buscan y no encuentran, la tasa de desempleo es del 8%.",
    related    = "Tasa de empleo, Población económicamente activa, Pleno empleo"
  ),

  list(
    term       = "Tasa de empleo",
    category   = "Empleo",
    definition = paste0(
      "Porcentaje de la población de 15 años o más que tiene empleo. No es lo mismo que la tasa ",
      "de desempleo: la tasa de empleo puede bajar aunque el desempleo no cambie, por ejemplo ",
      "si más personas estudian durante más años o si la población envejece."
    ),
    example    = "Una tasa de empleo del 60% significa que 60 de cada 100 personas de 15 años o más tienen trabajo.",
    related    = "Tasa de desempleo, Población económicamente activa"
  ),

  list(
    term       = "Inflación",
    category   = "Precios",
    definition = paste0(
      "Aumento sostenido y generalizado del nivel general de precios. Se mide como la variación ",
      "porcentual de un índice de precios como el IPC. El IPC no es la inflación: es un índice ",
      "del costo de una canasta representativa de los hogares; la inflación es su variación. ",
      "La estabilidad de precios no significa que ningún precio pueda subir: lo que se busca ",
      "evitar es una inflación elevada o inestable. La mayoría de los bancos centrales apunta ",
      "a una inflación baja y estable (en general, alrededor del 2%). La inflación reduce el ",
      "poder adquisitivo del dinero."
    ),
    example    = "Si el IPC pasa de 100 a 110 en un año, la canasta cuesta un 10% más: la inflación de ese año fue del 10%. Decir que \"el IPC fue de 110\" no dice cuánta inflación hubo.",
    related    = "IPC, Deflación, Hiperinflación, Política monetaria"
  ),

  list(
    term       = "IPC (Índice de Precios al Consumidor)",
    category   = "Precios",
    definition = paste0(
      "Índice que mide la evolución del costo de una canasta de bienes y servicios ",
      "representativa del consumo de los hogares. Es el principal indicador para observar la ",
      "estabilidad de precios: la inflación se calcula a partir de su variación."
    ),
    example    = "Si el IPC pasa de 200 a 230, el costo de la canasta aumentó un 15%.",
    related    = "Inflación, Deflación"
  ),

  list(
    term       = "Deflación",
    category   = "Precios",
    definition = paste0(
      "Caída sostenida y generalizada del nivel general de precios. Tampoco es necesariamente ",
      "deseable, sobre todo cuando refleja una fuerte debilidad de la actividad económica: ",
      "puede llevar a postergar compras y deprimir todavía más la economía."
    ),
    example    = "Japón tuvo varios años de deflación leve entre fines de los noventa y la década de 2010.",
    related    = "Inflación, IPC, Recesión"
  ),

  list(
    term       = "Hiperinflación",
    category   = "Precios",
    definition = paste0(
      "Inflación extremadamente rápida, que suele definirse como más del 50% mensual. Destruye ",
      "el valor de los ahorros y desorganiza la economía; en general se origina en una emisión ",
      "monetaria excesiva. La Argentina (1989–90), Venezuela (2017–19) y Zimbabue (2007–08) ",
      "tuvieron hiperinflación en las últimas décadas."
    ),
    example    = "La inflación anual de la Argentina llegó al 2.314% en 1990, al final de la hiperinflación de 1989–90 (ver Explorar un país). No toda inflación alta es hiperinflación: el 133% de 2023 fue muy alto, pero muy lejos del 50% mensual.",
    related    = "Inflación, Política monetaria"
  ),

  list(
    term       = "Resultado fiscal",
    category   = "Sector público",
    definition = paste0(
      "Diferencia entre los ingresos del Estado (impuestos, tasas) y sus gastos (salarios, ",
      "transferencias, servicios públicos, inversión) durante un período, en porcentaje del PBI. ",
      "Si los ingresos superan a los gastos hay superávit fiscal; si los gastos superan a los ",
      "ingresos hay déficit fiscal, que se financia, por ejemplo, tomando deuda. Un déficit no ",
      "es necesariamente un problema: en una recesión cae la recaudación mientras aumentan ",
      "algunos gastos, y un déficit transitorio puede ser compatible con cuentas públicas ",
      "sostenibles. La sostenibilidad fiscal depende de la trayectoria de la deuda pública en ",
      "relación con el tamaño de la economía, no del resultado de un solo año."
    ),
    example    = "Un resultado fiscal de –3% del PBI significa que el Estado gastó un 3% del PBI más de lo que recaudó.",
    related    = "Sostenibilidad fiscal, Deuda pública, Política fiscal"
  ),

  list(
    term       = "Deuda pública",
    category   = "Sector público",
    definition = paste0(
      "Conjunto de obligaciones financieras que el Estado acumula, por ejemplo, al endeudarse ",
      "para financiar sus déficits. Para evaluar la sostenibilidad fiscal importa su ",
      "trayectoria: si crece, se mantiene o baja en relación con el tamaño de la economía, y en ",
      "qué condiciones puede financiarse el Estado."
    ),
    example    = "Dos países con el mismo déficit pueden estar en situaciones muy distintas si en uno la deuda se mantiene estable en relación con el PBI y en el otro crece año tras año.",
    related    = "Resultado fiscal, Sostenibilidad fiscal"
  ),

  list(
    term       = "Sostenibilidad fiscal",
    category   = "Sector público",
    definition = paste0(
      "Capacidad del Estado para sostener sus compromisos actuales y futuros sin acumular ",
      "desequilibrios fiscales y de deuda que resulten difíciles de financiar. Se analiza con el ",
      "resultado fiscal junto con la trayectoria de la deuda pública en relación con el tamaño ",
      "de la economía."
    ),
    example    = "Dos países tienen el mismo déficit este año. En el primero, la deuda pública se mantiene estable en relación con el PBI; en el segundo, crece año tras año y cada vez es más difícil financiarla. El resultado fiscal es el mismo; la sostenibilidad fiscal, no.",
    related    = "Resultado fiscal, Deuda pública, Recesión"
  ),

  list(
    term       = "Saldo comercial",
    category   = "Sector externo",
    definition = paste0(
      "Indicador de la app: exportaciones menos importaciones, en porcentaje del PBI. Un saldo positivo es un ",
      "superávit comercial; uno negativo, un déficit comercial. La balanza comercial, en sentido ",
      "estricto, registra solo bienes; el indicador de esta app incluye también servicios. ",
      "En ambos casos es más acotado que la balanza de pagos, que registra además inversiones, ",
      "préstamos e ingresos con el resto del mundo. Un déficit comercial no es necesariamente ",
      "insostenible: importa cómo se financia y si puede mantenerse en el tiempo."
    ),
    example    = "Alemania suele tener un gran superávit comercial porque sus exportaciones superan ampliamente a sus importaciones.",
    related    = "Balanza comercial, Balanza de pagos, Déficit y superávit externo, Sostenibilidad externa"
  ),

  list(
    term       = "Balanza de pagos",
    category   = "Sector externo",
    definition = paste0(
      "Registro de todas las transacciones económicas entre un país y el resto del mundo durante ",
      "un período: el comercio de bienes y servicios, pero también ingresos, transferencias, ",
      "inversiones y préstamos. Es la herramienta principal para analizar la sostenibilidad ",
      "externa: si un país puede sostener sus relaciones económicas con el resto del mundo sin ",
      "acumular una vulnerabilidad creciente."
    ),
    example    = "Una empresa extranjera que instala una fábrica en el país no aparece en la balanza comercial, pero sí en la balanza de pagos.",
    related    = "Sector externo, Balanza comercial, Saldo comercial, Cuenta corriente, Sostenibilidad externa"
  ),

  list(
    term       = "Cuenta corriente",
    category   = "Sector externo",
    definition = paste0(
      "Parte de la balanza de pagos que registra el comercio de bienes y servicios, los ",
      "ingresos (como intereses y utilidades) y las transferencias con el resto del mundo. ",
      "Un déficit de cuenta corriente significa que el país paga al exterior más de lo que ",
      "recibe por esos conceptos, y tiene que financiarse con ingresos de capital: ",
      "inversiones o préstamos del exterior, o con reservas."
    ),
    example    = "Un país puede tener superávit comercial y aun así déficit de cuenta corriente si paga muchos intereses de deuda externa.",
    related    = "Balanza de pagos, Saldo comercial, Inversión extranjera directa"
  ),

  list(
    term       = "Inversión extranjera directa",
    category   = "Sector externo",
    definition = paste0(
      "Inversión de empresas o personas del exterior para instalar, comprar o ampliar ",
      "empresas en el país, con intención de largo plazo. Queda registrada en la balanza de ",
      "pagos y es una de las formas de financiar un déficit de cuenta corriente, en general ",
      "más estable que los préstamos de corto plazo."
    ),
    example    = "Una empresa extranjera que construye una fábrica en el país es inversión extranjera directa.",
    related    = "Cuenta corriente, Balanza de pagos, Sostenibilidad externa"
  ),

  list(
    term       = "Sostenibilidad externa",
    category   = "Sector externo",
    definition = paste0(
      "Capacidad de una economía para mantener sus relaciones y compromisos económicos con el ",
      "exterior sin generar una vulnerabilidad creciente. Se analiza con la balanza de pagos y ",
      "otros indicadores externos: un déficit externo tiene que financiarse, por ejemplo, con ",
      "inversiones o préstamos del exterior."
    ),
    example    = "Un país que importa maquinaria para ampliar su capacidad productiva puede tener un déficit comercial durante algunos años y, gracias a esa inversión, producir y exportar más en el futuro.",
    related    = "Sector externo, Balanza de pagos, Déficit y superávit externo, Saldo comercial"
  ),

  list(
    term       = "Sostenibilidad",
    category   = "Conceptos generales",
    definition = paste0(
      "Capacidad de mantener una situación económica en el tiempo sin acumular desequilibrios ",
      "que terminen haciendo imposible sostenerla. Los objetivos centrales preguntan qué está ",
      "ocurriendo; los de sostenibilidad (fiscal y externa) preguntan si puede sostenerse. ",
      "Una evaluación completa mira los dos grupos."
    ),
    example    = "Una economía puede crecer, crear empleo y mantener la inflación baja mientras acumula déficits fiscales o externos cada vez más difíciles de financiar.",
    related    = "Sostenibilidad fiscal, Sostenibilidad externa, Objetivo macroeconómico"
  ),

  list(
    term       = "Disyuntiva (trade-off)",
    category   = "Conceptos generales",
    definition = paste0(
      "Situación en la que mejorar un objetivo hace más difícil alcanzar otro: los objetivos ",
      "macroeconómicos no siempre evolucionan en la misma dirección, y pueden aparecer ",
      "tensiones entre ellos. Una tensión clásica es la que plantea la curva de Phillips ",
      "entre inflación y desempleo: bajar el desempleo podría subir la inflación, y viceversa. ",
      "Pero esa relación no es estable en todos los países ni en todos los períodos."
    ),
    example    = "Una economía puede aumentar su producción y reducir el desempleo, pero mantener una inflación elevada; o reducir la inflación y atravesar una desaceleración de la actividad.",
    related    = "Política monetaria, Objetivo macroeconómico"
  ),

  list(
    term       = "Ciclo económico",
    category   = "Conceptos generales",
    definition = paste0(
      "Alternancia de fases de expansión y de contracción (recesión) alrededor de la tendencia ",
      "de crecimiento de largo plazo. Los ciclos varían en duración e intensidad. Ayudan a ",
      "entender por qué en las recesiones suelen empeorar a la vez el crecimiento, el empleo y ",
      "el resultado fiscal."
    ),
    example    = "La crisis financiera global de 2008–09 provocó una fuerte contracción cíclica en la mayoría de las economías.",
    related    = "Crecimiento del PBI, Recesión, Política fiscal"
  ),

  list(
    term       = "Correlación",
    category   = "Estadística",
    definition = paste0(
      "Medida estadística de cuánto se mueven juntas dos variables. Una correlación de +1 ",
      "significa que se mueven exactamente juntas; –1, que se mueven en sentidos exactamente ",
      "opuestos; 0, que no hay relación lineal. Una correlación no prueba que una variable ",
      "cause la otra."
    ),
    example    = "El crecimiento del PBI y la tasa de empleo suelen tener correlación positiva, pero su intensidad varía según el país.",
    related    = "Causalidad"
  ),

  list(
    term       = "Causalidad",
    category   = "Estadística",
    definition = paste0(
      "Una relación causal significa que cambiar una variable produce directamente un cambio ",
      "en otra. Es mucho más difícil de demostrar que una correlación. Dos variables pueden ",
      "estar correlacionadas porque A causa B, porque B causa A, porque una tercera variable C ",
      "causa ambas, o por pura casualidad."
    ),
    example    = "Las ventas de helado y los ahogamientos están correlacionados (ambos aumentan en verano), pero ninguno causa el otro.",
    related    = "Correlación"
  ),

  list(
    term       = "Política monetaria",
    category   = "Políticas",
    definition = paste0(
      "Acciones del banco central para influir sobre la cantidad de dinero y las tasas de ",
      "interés, principalmente para controlar la inflación y sostener la actividad. Cuando la ",
      "inflación es alta, los bancos centrales suelen subir la tasa de interés (política ",
      "contractiva); cuando amenaza una recesión, la bajan (política expansiva)."
    ),
    example    = "La Reserva Federal de Estados Unidos subió fuertemente las tasas de interés en 2022–23 para combatir la inflación.",
    related    = "Inflación, Política fiscal"
  ),

  list(
    term       = "Política fiscal",
    category   = "Políticas",
    definition = paste0(
      "Decisiones del gobierno sobre el gasto público y los impuestos para influir sobre la ",
      "economía. Una política fiscal expansiva (más gasto o menos impuestos) puede impulsar el ",
      "crecimiento, pero puede aumentar el déficit. Una política contractiva (ajuste) reduce el ",
      "déficit, pero puede frenar el crecimiento y aumentar el desempleo."
    ),
    example    = "Los paquetes de estímulo durante la pandemia de COVID-19 fueron política fiscal expansiva y generaron grandes déficits fiscales.",
    related    = "Resultado fiscal, Política monetaria"
  )
)

# Order of the notes' glossary: general concepts, then each objective with its
# indicator and the concepts needed to read it; what the notes do not cover yet
# (policies, statistics) goes last
GLOSSARY_ORDER <- c(
  # Conceptos generales
  "Macroeconomía", "Objetivo macroeconómico", "Indicador", "Sostenibilidad",
  "Disyuntiva (trade-off)", "Ciclo económico",
  # Crecimiento económico
  "Crecimiento económico", "PBI (Producto Bruto Interno)", "PBI nominal", "PBI real",
  "Crecimiento del PBI", "Recesión",
  # Pleno empleo
  "Pleno empleo", "Empleo", "Desempleo", "Población económicamente activa",
  "Tasa de desempleo", "Tasa de empleo",
  # Estabilidad de precios
  "Estabilidad de precios", "Nivel general de precios", "Inflación", "Deflación",
  "IPC (Índice de Precios al Consumidor)", "Hiperinflación",
  # Sostenibilidad fiscal
  "Sostenibilidad fiscal", "Resultado fiscal", "Déficit fiscal", "Superávit fiscal",
  "Deuda pública",
  # Sostenibilidad externa
  "Sostenibilidad externa", "Sector externo", "Balanza de pagos", "Balanza comercial",
  "Saldo comercial", "Déficit y superávit externo", "Cuenta corriente",
  "Inversión extranjera directa",
  # Más allá del apunte
  "Política monetaria", "Política fiscal", "Correlación", "Causalidad"
)
GLOSSARY_TERMS <- GLOSSARY_TERMS[order(match(sapply(GLOSSARY_TERMS, `[[`, "term"), GLOSSARY_ORDER))]

# Categories in display order, with their colours
GLOSSARY_CATEGORY_COLORS <- c(
  "Conceptos generales" = "#db2777",
  "Producción"          = "#2563eb",
  "Empleo"              = "#16a34a",
  "Precios"             = "#dc2626",
  "Sector público"      = "#7c3aed",
  "Sector externo"      = "#d97706",
  "Políticas"           = "#0891b2",
  "Estadística"         = "#475569"
)

# =============================================================================
# GLOSSARY MODAL UI
# =============================================================================
glossary_modal <- function() {
  modalDialog(
    title = tags$span("📖 Glosario de macroeconomía"),
    size  = "xl",
    easyClose = TRUE,
    tags$div(
      style = "margin-bottom:14px;",
      tags$p(
        style = "color:#555; margin:0;",
        "Pasá el mouse sobre los íconos ", tags$code("📖"), " de la aplicación para ver definiciones breves.",
        " Este glosario tiene las explicaciones completas, con ejemplos. ",
        "Los términos siguen el orden del apunte \"La mirada macroeconómica\": primero los ",
        "conceptos generales y luego cada objetivo con su indicador."
      )
    ),
    # Filter by category
    tags$div(
      style = "margin-bottom:16px;",
      radioGroupButtons(
        inputId  = "glossary_filter",
        label    = NULL,
        choices  = c("Todos", names(GLOSSARY_CATEGORY_COLORS)),
        selected = "Todos",
        size     = "sm",
        status   = "outline-primary"
      )
    ),
    # Glossary entries
    uiOutput("glossary_content"),
    footer = modalButton("Cerrar")
  )
}

#' Render glossary entries (called from server)
render_glossary <- function(filter_cat = "Todos") {
  terms <- if (filter_cat == "Todos") {
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
          tags$span(style = "font-weight:600; color:#0369a1;", "Ejemplo: "),
          tags$span(style = "color:#334155;", t$example)
        ),
        if (!is.null(t$related)) {
          tags$div(
            style = "margin-top:6px; font-size:0.78rem; color:#64748b;",
            tags$span(style = "font-weight:600;", "Relacionado: "),
            t$related
          )
        }
      )
    })
  )
}

category_color <- function(cat) {
  unname(GLOSSARY_CATEGORY_COLORS[cat])
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
    filter_val <- if (!is.null(input$glossary_filter)) input$glossary_filter else "Todos"
    render_glossary(filter_val)
  })
}
