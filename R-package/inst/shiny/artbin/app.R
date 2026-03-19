library(shiny)
library(artbin)

ui <- fluidPage(
  titlePanel("ART \u2013 Binary Outcomes: Sample Size and Power"),

  sidebarLayout(
    sidebarPanel(
      ## ---- Set-up ----
      wellPanel(
        h4("Set-up"),
        textInput("pr", "Anticipated probabilities",
                  placeholder = "e.g. 0.2 0.3   or   0.1 0.2 0.3 0.4"),
        fluidRow(
          column(6, textInput("margin", "Margin (NI/SS only)",
                              placeholder = "e.g. 0.1")),
          column(6, textInput("aratios", "Allocation ratios",
                              placeholder = "e.g. 1 2"))
        ),
        radioButtons("fav_dir", "Outcome direction",
                     choices = list(
                       "Infer automatically" = "auto",
                       "Favourable"          = "fav",
                       "Unfavourable"        = "unfav"),
                     selected = "auto"),
        radioButtons("mode", "Calculate:",
                     choices = list(
                       "Sample size for given power" = "power_mode",
                       "Power for given N"           = "n_mode"),
                     selected = "power_mode"),
        conditionalPanel(
          condition = "input.mode == 'power_mode'",
          numericInput("power_val", "Power", value = 0.8,
                       min = 0.01, max = 0.9999, step = 0.05)
        ),
        conditionalPanel(
          condition = "input.mode == 'n_mode'",
          numericInput("n_val", "Total N", value = 100, min = 1, step = 1)
        ),
        fluidRow(
          column(6, numericInput("alpha", "Alpha", value = 0.05,
                                 min = 0.001, max = 0.5, step = 0.005)),
          column(6, numericInput("ltfu", "Loss to follow-up",
                                 value = NA, min = 0, max = 0.999, step = 0.05))
        ),
        checkboxInput("onesided", "One-sided test", value = FALSE),
        fluidRow(
          column(6, checkboxInput("trend", "Trend test", value = FALSE)),
          column(6, conditionalPanel(
            condition = "input.trend == true",
            textInput("doses", "Doses", placeholder = "e.g. 1 2 3")
          ))
        )
      ),

      ## ---- Options ----
      wellPanel(
        h4("Options"),
        checkboxInput("wald",      "Wald test",              value = FALSE),
        checkboxInput("local_alt", "Local alternatives",     value = FALSE),
        checkboxInput("condit",    "Conditional test (Peto)", value = FALSE),
        checkboxInput("ccorrect",  "Continuity correction",  value = FALSE),
        checkboxInput("noround",   "Do not round",           value = FALSE)
      ),

      actionButton("calculate", "Calculate",
                   class = "btn-primary btn-block")
    ),

    mainPanel(
      conditionalPanel(
        condition = "output.has_error == true",
        div(class = "alert alert-danger",
            strong("Error: "), textOutput("error_msg", inline = TRUE))
      ),
      conditionalPanel(
        condition = "output.has_result == true",
        h4("Results"),
        tableOutput("result_table"),
        hr(),
        verbatimTextOutput("result_call")
      )
    )
  )
)

server <- function(input, output, session) {

  ## Mutual exclusion of test options (mirrors artbin.dlg scripts)
  observeEvent(input$wald, {
    if (isTRUE(input$wald)) {
      updateCheckboxInput(session, "local_alt", value = FALSE)
      updateCheckboxInput(session, "condit",    value = FALSE)
    }
  })
  observeEvent(input$local_alt, {
    if (isTRUE(input$local_alt)) {
      updateCheckboxInput(session, "wald", value = FALSE)
    }
  })
  observeEvent(input$condit, {
    if (isTRUE(input$condit)) {
      updateCheckboxInput(session, "wald", value = FALSE)
    }
  })
  observeEvent(input$trend, {
    if (isTRUE(input$trend)) {
      updateCheckboxInput(session, "condit", value = FALSE)
    }
  })

  ## Parse helpers
  parse_numvec <- function(s) {
    s <- trimws(s)
    if (nchar(s) == 0) return(NULL)
    vals <- suppressWarnings(as.numeric(strsplit(s, "[[:space:]]+")[[1]]))
    if (any(is.na(vals))) return(NA)
    vals
  }

  result <- eventReactive(input$calculate, {
    pr_vec <- parse_numvec(input$pr)
    if (is.null(pr_vec) || any(is.na(pr_vec)))
      return(list(error = "Invalid anticipated probabilities."))

    margin_val  <- parse_numvec(input$margin)
    if (isTRUE(any(is.na(margin_val)))) return(list(error = "Invalid margin."))

    aratios_val <- parse_numvec(input$aratios)
    if (isTRUE(any(is.na(aratios_val)))) return(list(error = "Invalid allocation ratios."))

    doses_val <- if (isTRUE(input$trend)) parse_numvec(input$doses) else NULL
    if (isTRUE(any(is.na(doses_val)))) return(list(error = "Invalid doses."))

    ltfu_val   <- if (is.na(input$ltfu)) NULL else input$ltfu
    n_val      <- if (input$mode == "n_mode") as.integer(input$n_val) else 0L
    power_val  <- if (input$mode == "power_mode") input$power_val else NULL

    tryCatch(
      artbin(
        pr           = pr_vec,
        margin       = margin_val,
        alpha        = input$alpha,
        aratios      = aratios_val,
        favourable   = (input$fav_dir == "fav"),
        unfavourable = (input$fav_dir == "unfav"),
        condit       = isTRUE(input$condit),
        local_alt    = isTRUE(input$local_alt),
        doses        = doses_val,
        n            = n_val,
        onesided     = isTRUE(input$onesided),
        power        = power_val,
        trend        = isTRUE(input$trend),
        ccorrect     = isTRUE(input$ccorrect),
        wald         = isTRUE(input$wald),
        noround      = isTRUE(input$noround),
        ltfu         = ltfu_val
      ),
      error = function(e) list(error = conditionMessage(e))
    )
  })

  output$has_error  <- reactive(!is.null(result()$error))
  output$has_result <- reactive(is.null(result()$error))
  outputOptions(output, "has_error",  suspendWhenHidden = FALSE)
  outputOptions(output, "has_result", suspendWhenHidden = FALSE)

  output$error_msg <- renderText(result()$error)

  output$result_table <- renderTable({
    r <- result()
    if (!is.null(r$error)) return(NULL)
    narms <- sum(grepl("^n[0-9]+$", names(r)))
    rows <- list(
      data.frame(Quantity = "Total sample size",   Value = format(r$n)),
      data.frame(Quantity = "Power",               Value = formatC(r$power, digits = 4, format = "f")),
      data.frame(Quantity = "Alpha",               Value = formatC(r$alpha, digits = 4, format = "f")),
      data.frame(Quantity = "Total events (D)",    Value = formatC(r$D,     digits = 2, format = "f"))
    )
    for (i in seq_len(narms)) {
      rows <- c(rows, list(
        data.frame(Quantity = paste0("n", i, "  (group ", i, ")"),
                   Value = format(r[[paste0("n", i)]])),
        data.frame(Quantity = paste0("D", i, "  (events, group ", i, ")"),
                   Value = formatC(r[[paste0("D", i)]], digits = 2, format = "f"))
      ))
    }
    do.call(rbind, rows)
  }, striped = TRUE, hover = TRUE, spacing = "s")

  output$result_call <- renderText({
    r <- result()
    if (!is.null(r$error)) return(NULL)
    pr_str <- paste(parse_numvec(input$pr), collapse = ", ")
    paste0("artbin(pr = c(", pr_str, "), ...)")
  })
}

shinyApp(ui = ui, server = server)
