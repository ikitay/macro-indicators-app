# =============================================================================
# SPANISH NAMES FOR COUNTRIES, REGIONS AND INCOME GROUPS
# The World Bank publishes names in English; the app shows them in Spanish.
# Applied when the data is loaded (see clean_wdi_dataframe in data_utils.R).
# Countries missing from this table keep their World Bank name.
# =============================================================================

COUNTRY_NAMES_ES <- c(
  AF = "Afganistán", AL = "Albania", DZ = "Argelia", AS = "Samoa Americana",
  AD = "Andorra", AO = "Angola", AG = "Antigua y Barbuda", AR = "Argentina",
  AM = "Armenia", AW = "Aruba", AU = "Australia", AT = "Austria",
  AZ = "Azerbaiyán", BS = "Bahamas", BH = "Baréin", BD = "Bangladés",
  BB = "Barbados", BY = "Bielorrusia", BE = "Bélgica", BZ = "Belice",
  BJ = "Benín", BM = "Bermudas", BT = "Bután", BO = "Bolivia",
  BA = "Bosnia y Herzegovina", BW = "Botsuana", BR = "Brasil",
  VG = "Islas Vírgenes Británicas", BN = "Brunéi", BG = "Bulgaria",
  BF = "Burkina Faso", BI = "Burundi", CV = "Cabo Verde", KH = "Camboya",
  CM = "Camerún", CA = "Canadá", KY = "Islas Caimán",
  CF = "República Centroafricana", TD = "Chad", CL = "Chile", CN = "China",
  CO = "Colombia", KM = "Comoras", CD = "República Democrática del Congo",
  CG = "República del Congo", CR = "Costa Rica", CI = "Costa de Marfil",
  HR = "Croacia", CU = "Cuba", CW = "Curazao", CY = "Chipre",
  CZ = "Chequia", DK = "Dinamarca", DJ = "Yibuti", DM = "Dominica",
  DO = "República Dominicana", EC = "Ecuador", EG = "Egipto",
  SV = "El Salvador", GQ = "Guinea Ecuatorial", ER = "Eritrea",
  EE = "Estonia", SZ = "Esuatini", ET = "Etiopía", FO = "Islas Feroe",
  FJ = "Fiyi", FI = "Finlandia", FR = "Francia", PF = "Polinesia Francesa",
  GA = "Gabón", GM = "Gambia", GE = "Georgia", DE = "Alemania",
  GH = "Ghana", GI = "Gibraltar", GR = "Grecia", GL = "Groenlandia",
  GD = "Granada", GU = "Guam", GT = "Guatemala", GN = "Guinea",
  GW = "Guinea-Bisáu", GY = "Guyana", HT = "Haití", HN = "Honduras",
  HK = "Hong Kong (China)", HU = "Hungría", IS = "Islandia", IN = "India",
  ID = "Indonesia", IR = "Irán", IQ = "Irak", IE = "Irlanda",
  IM = "Isla de Man", IL = "Israel", IT = "Italia", JM = "Jamaica",
  JP = "Japón", JO = "Jordania", KZ = "Kazajistán", KE = "Kenia",
  KI = "Kiribati", KP = "Corea del Norte", KR = "Corea del Sur",
  XK = "Kosovo", KW = "Kuwait", KG = "Kirguistán", LA = "Laos",
  LV = "Letonia", LB = "Líbano", LS = "Lesoto", LR = "Liberia",
  LY = "Libia", LI = "Liechtenstein", LT = "Lituania", LU = "Luxemburgo",
  MO = "Macao (China)", MG = "Madagascar", MW = "Malaui", MY = "Malasia",
  MV = "Maldivas", ML = "Malí", MT = "Malta", MH = "Islas Marshall",
  MR = "Mauritania", MU = "Mauricio", MX = "México", FM = "Micronesia",
  MD = "Moldavia", MC = "Mónaco", MN = "Mongolia", ME = "Montenegro",
  MA = "Marruecos", MZ = "Mozambique", MM = "Myanmar", NR = "Nauru",
  NP = "Nepal", NL = "Países Bajos", NC = "Nueva Caledonia",
  NZ = "Nueva Zelanda", NI = "Nicaragua", NE = "Níger", NG = "Nigeria",
  MK = "Macedonia del Norte", MP = "Islas Marianas del Norte",
  NO = "Noruega", OM = "Omán", PK = "Pakistán", PW = "Palaos",
  PA = "Panamá", PG = "Papúa Nueva Guinea", PY = "Paraguay", PE = "Perú",
  PH = "Filipinas", PL = "Polonia", PT = "Portugal", PR = "Puerto Rico",
  QA = "Catar", RO = "Rumania", RU = "Rusia", RW = "Ruanda", WS = "Samoa",
  SM = "San Marino", ST = "Santo Tomé y Príncipe", SA = "Arabia Saudita",
  SN = "Senegal", RS = "Serbia", SC = "Seychelles", SL = "Sierra Leona",
  SG = "Singapur", SX = "San Martín (Países Bajos)", SK = "Eslovaquia",
  SI = "Eslovenia", SB = "Islas Salomón", SO = "Somalia",
  ZA = "Sudáfrica", SS = "Sudán del Sur", ES = "España", LK = "Sri Lanka",
  KN = "San Cristóbal y Nieves", LC = "Santa Lucía",
  MF = "San Martín (Francia)", VC = "San Vicente y las Granadinas",
  SD = "Sudán", SR = "Surinam", SE = "Suecia", CH = "Suiza", SY = "Siria",
  TJ = "Tayikistán", TZ = "Tanzania", TH = "Tailandia",
  TL = "Timor Oriental", TG = "Togo", TO = "Tonga",
  TT = "Trinidad y Tobago", TN = "Túnez", TR = "Turquía",
  TM = "Turkmenistán", TC = "Islas Turcas y Caicos", TV = "Tuvalu",
  UG = "Uganda", UA = "Ucrania", AE = "Emiratos Árabes Unidos",
  GB = "Reino Unido", US = "Estados Unidos", UY = "Uruguay",
  UZ = "Uzbekistán", VU = "Vanuatu", VE = "Venezuela", VN = "Vietnam",
  VI = "Islas Vírgenes (EE. UU.)", PS = "Cisjordania y Gaza",
  YE = "Yemen", ZM = "Zambia", ZW = "Zimbabue"
)

REGION_NAMES_ES <- c(
  "East Asia & Pacific"        = "Asia oriental y Pacífico",
  "Europe & Central Asia"      = "Europa y Asia central",
  "Latin America & Caribbean"  = "América Latina y el Caribe",
  "Middle East & North Africa" = "Medio Oriente y Norte de África",
  "North America"              = "América del Norte",
  "South Asia"                 = "Asia meridional",
  "Sub-Saharan Africa"         = "África subsahariana"
)

INCOME_NAMES_ES <- c(
  "Low income"          = "Ingreso bajo",
  "Lower middle income" = "Ingreso mediano bajo",
  "Upper middle income" = "Ingreso mediano alto",
  "High income"         = "Ingreso alto"
)

# Replace English values by their Spanish names; unknown values are kept
translate_values <- function(x, table) {
  out <- unname(table[x])
  ifelse(is.na(out), x, out)
}

# Spanish country, region and income names for a data frame from the World Bank
translate_country_fields <- function(df) {
  if ("iso2c"  %in% names(df)) {
    es <- unname(COUNTRY_NAMES_ES[df$iso2c])
    df$country <- ifelse(is.na(es), df$country, es)
  }
  if ("region" %in% names(df)) df$region <- translate_values(df$region, REGION_NAMES_ES)
  if ("income" %in% names(df)) df$income <- translate_values(df$income, INCOME_NAMES_ES)
  df
}
