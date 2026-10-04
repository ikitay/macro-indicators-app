# =============================================================================
# MODULE: DISCOVERY CHALLENGES (Tab 6)
# Purpose: Guided inquiry tasks that lead students to discover macroeconomic
#   patterns, exceptions, and trade-offs through data exploration.
# =============================================================================

challenges_ui <- function(id) {
  ns <- NS(id)
  fluidPage(
    tags$div(
      style = "max-width:1050px; margin:0 auto; padding:16px;",

      # ── Header ──────────────────────────────────────────────────────────────
      tags$div(
        style = "background:linear-gradient(135deg,#1e3a5f,#2563eb); border-radius:10px;
                 padding:22px 28px; margin-bottom:20px; color:white;",
        tags$h4(style="margin:0 0 6px; font-weight:700;", "🎯 Desafíos"),
        tags$p(style="margin:0; opacity:0.88; font-size:0.93rem;",
          "Estos desafíos te proponen descubrir patrones macroeconómicos explorando los datos. ",
          "Investigá con las otras pestañas y volvé acá para comparar lo que encontraste."
        )
      ),

      # ── Controls row ────────────────────────────────────────────────────────
      layout_columns(
        col_widths = c(5, 3, 4),
        card(
          card_body(padding="10px",
            # Attach the dropdown to <body> so the card's overflow doesn't clip it
            selectizeInput(ns("challenge_select"), "Elegí un desafío:",
              choices  = CHALLENGE_CHOICES,
              selected = 1,
              width    = "100%",
              options  = list(dropdownParent = "body")
            )
          )
        ),
        card(
          card_body(padding="10px",
            tags$div(style="padding-top:4px;",
              actionButton(ns("random_challenge"), "🎲 Desafío al azar",
                           class="btn btn-outline-primary btn-sm w-100 mb-2"),
              checkboxInput(ns("instructor_mode"), "🎓 Modo docente", value=FALSE)
            )
          )
        ),
        card(
          card_body(padding="10px",
            tags$div(style="padding-top:4px;",
              actionButton(ns("show_hint"),    "💡 Ver pista",    class="btn btn-outline-warning btn-sm w-100 mb-2"),
              actionButton(ns("show_solution"),"✅ Ver solución", class="btn btn-outline-success btn-sm w-100")
            )
          )
        )
      ),

      # ── Challenge card ───────────────────────────────────────────────────────
      uiOutput(ns("challenge_card")),

      # ── Hint panel (hidden by default) ──────────────────────────────────────
      uiOutput(ns("hint_panel")),

      # ── Solution panel (hidden by default) ──────────────────────────────────
      uiOutput(ns("solution_panel")),

      # ── Instructor panel (shown in instructor mode) ──────────────────────────
      uiOutput(ns("instructor_panel"))
    )
  )
}

challenges_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {

    # State
    show_hint_rv     <- reactiveVal(FALSE)
    show_solution_rv <- reactiveVal(FALSE)

    # Random challenge
    observeEvent(input$random_challenge, {
      new_idx <- sample(seq_along(CHALLENGES), 1)
      updateSelectInput(session, "challenge_select", selected = new_idx)
      show_hint_rv(FALSE)
      show_solution_rv(FALSE)
    })

    # Reset hint/solution when challenge changes
    observeEvent(input$challenge_select, {
      show_hint_rv(FALSE)
      show_solution_rv(FALSE)
    })

    observeEvent(input$show_hint,     { show_hint_rv(TRUE) })
    observeEvent(input$show_solution, { show_solution_rv(TRUE) })

    current_challenge <- reactive({
      req(input$challenge_select)
      idx <- as.integer(input$challenge_select)
      CHALLENGES[[idx]]
    })

    # ── Challenge card ─────────────────────────────────────────────────────────
    output$challenge_card <- renderUI({
      ch <- current_challenge()
      diff_col <- DIFFICULTY_COLORS[ch$difficulty]

      tags$div(
        style="background:#fff; border:1px solid #e2e8f0; border-radius:10px;
               padding:24px; margin-top:14px;",
        # Title row
        tags$div(style="display:flex; align-items:flex-start; justify-content:space-between; margin-bottom:14px;",
          tags$div(
            tags$span(style="font-size:1.8rem; margin-right:10px;", ch$icon),
            tags$span(style="font-size:1.2rem; font-weight:700; color:#1e3a5f;", ch$title)
          ),
          tags$span(
            style=paste0("background:",diff_col,"; color:white; padding:3px 12px; ",
                         "border-radius:12px; font-size:0.8rem; font-weight:600; white-space:nowrap;"),
            ch$difficulty
          )
        ),

        # Description
        tags$div(
          style="background:#f8fafc; border-radius:8px; padding:16px; margin-bottom:16px;",
          tags$p(style="margin:0; color:#334155; line-height:1.7; font-size:0.95rem;",
                 ch$description)
        ),

        # Relevant indicators
        tags$div(
          style="margin-bottom:16px;",
          tags$span(style="font-weight:600; color:#475569; font-size:0.85rem;", "Indicadores para explorar: "),
          tags$div(
            style="display:flex; gap:6px; flex-wrap:wrap; margin-top:6px;",
            lapply(ch$variables, function(v) {
              tags$span(
                style=paste0("background:",var_color(v),"22; color:",var_color(v),
                             "; border:1px solid ",var_color(v),"55; padding:3px 10px; ",
                             "border-radius:12px; font-size:0.82rem; font-weight:600;"),
                var_label(v)
              )
            })
          )
        ),

        # Navigation suggestion
        tags$div(
          style="background:#eff6ff; border:1px solid #bfdbfe; border-radius:8px; padding:12px;",
          tags$span(style="color:#1d4ed8; font-weight:600; font-size:0.85rem;", "🗺️ Dónde explorar: "),
          tags$span(style="color:#1e40af; font-size:0.85rem;",
            if (length(ch$variables) == 1)
              paste0("Usá la pestaña '⚖️ Comparar países' y elegí '", var_label(ch$variables[1]), "'.")
            else if (length(ch$variables) == 2)
              paste0("Probá la pestaña '📊 Correlaciones' con ",
                     var_label(ch$variables[1]), " y ", var_label(ch$variables[2]), ".")
            else
              "Usá '🔍 Explorar un país' para un país, o '⚖️ Comparar países' para varios."
          )
        )
      )
    })

    # ── Hint panel ─────────────────────────────────────────────────────────────
    output$hint_panel <- renderUI({
      req(show_hint_rv())
      ch <- current_challenge()
      tags$div(
        style="background:#fffbeb; border:1px solid #fde68a; border-radius:8px;
               padding:14px 18px; margin-top:12px;",
        tags$span(style="font-weight:700; color:#92400e; font-size:0.9rem;", "💡 Pista"),
        tags$p(style="margin:6px 0 0; color:#78350f; font-size:0.87rem; line-height:1.6;",
               ch$hint)
      )
    })

    # ── Solution panel ─────────────────────────────────────────────────────────
    output$solution_panel <- renderUI({
      req(show_solution_rv())
      ch <- current_challenge()
      tags$div(
        style="background:#f0fdf4; border:1px solid #bbf7d0; border-radius:8px;
               padding:14px 18px; margin-top:12px;",
        tags$div(style="font-weight:700; color:#166534; font-size:0.9rem; margin-bottom:10px;",
                 "✅ Casos sugeridos para analizar"),
        lapply(ch$solution_countries, function(s) {
          tags$div(
            style="background:white; border-radius:6px; padding:10px 12px; margin-bottom:8px;
                   border:1px solid #d1fae5;",
            tags$div(style="display:flex; justify-content:space-between; align-items:baseline;",
              tags$span(style="font-weight:700; color:#1e3a5f;", s$country),
              tags$span(style="color:#64748b; font-size:0.82rem;", s$years)
            ),
            tags$p(style="margin:4px 0 0; color:#475569; font-size:0.83rem;", s$note)
          )
        }),
        tags$div(
          style="background:#dcfce7; border-radius:6px; padding:8px 12px; margin-top:8px;",
          tags$small(style="color:#166534;",
            "⚠️ Son ejemplos: podés encontrar otras respuestas válidas. ",
            "Lo importante es explorar y fundamentar lo que encontrás.")
        )
      )
    })

    # ── Instructor panel ───────────────────────────────────────────────────────
    output$instructor_panel <- renderUI({
      req(input$instructor_mode)
      ch <- current_challenge()
      tags$div(
        style="background:#f5f3ff; border:1px solid #ddd6fe; border-radius:8px;
               padding:16px 18px; margin-top:12px;",
        tags$div(style="font-weight:700; color:#4c1d95; font-size:0.9rem; margin-bottom:10px;",
                 "🎓 Notas para docentes"),
        tags$div(
          style="margin-bottom:12px;",
          tags$span(style="font-weight:600; color:#5b21b6; font-size:0.85rem;", "Contexto pedagógico: "),
          tags$p(style="color:#3b0764; font-size:0.85rem; margin:4px 0 0; line-height:1.6;",
                 ch$pedagogical_note)
        ),
        tags$div(
          tags$span(style="font-weight:600; color:#5b21b6; font-size:0.85rem;", "Preguntas para el debate: "),
          tags$ol(style="color:#3b0764; font-size:0.85rem; margin:6px 0 0; line-height:1.8;",
            lapply(ch$discussion_questions, tags$li)
          )
        )
      )
    })
  })
}
