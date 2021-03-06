#' Create Seurat App
#'
#' @param preset_project A preloaded project to start the app with
#' @param appTitle A title of the App
#' @param futureMb amount of Mb allocated to future package
#' @param preset_project
#' @param feature_types
#' @param organism_type
#' @loom_path
#'
#' @return
#' @export
#'
#' @examples
minimalSeuratApp <- function(seu_list, appTitle = NULL, feature_types = "gene",
                             organism_type = "human", loom_path = NULL, futureMb = 13000) {
  print(feature_types)
  future::plan(strategy = "multicore", workers = 6)
  future_size <- futureMb * 1024^2
  options(future.globals.maxSize = future_size)
  options(shiny.maxRequestSize = 40 * 1024^2)
  options(DT.options = list(
    pageLength = 2000, paging = FALSE,
    info = TRUE, searching = TRUE, autoWidth = F, ordering = TRUE,
    scrollX = TRUE, language = list(search = "Filter:")
  ))
  header <- shinydashboard::dashboardHeader(title = appTitle)
  sidebar <- shinydashboard::dashboardSidebar(
    uiOutput("featureType"),
    shinyWidgets::prettyRadioButtons("organism_type",
      inline = TRUE,
      "Organism", choices = c("human", "mouse"), selected = organism_type
    ),
    shinydashboard::sidebarMenu(
      shinydashboard::menuItem("Plot Data",
        tabName = "comparePlots", icon = icon("chart-bar"), selected = TRUE
      ), shinydashboard::menuItem("Violin/Heatmap Plots",
        tabName = "violinPlots", icon = icon("sort")
      ), shinydashboard::menuItem("Differential Expression",
        tabName = "diffex", icon = icon("magnet")
      ), shinydashboard::menuItem("Find Markers",
        tabName = "findMarkers", icon = icon("bullhorn")
      ),  shinydashboard::menuItem("Pathway Enrichment Analysis",
        tabName = "pathwayEnrichment", icon = icon("sitemap")
      ), shinydashboard::menuItem("Subset Seurat Input",
        tabName = "subsetSeurat", icon = icon("filter")
      ), shinydashboard::menuItem("All Transcripts",
        tabName = "allTranscripts", icon = icon("sliders-h")
      ), shinydashboard::menuItem("RNA Velocity",
        tabName = "plotVelocity", icon = icon("tachometer-alt")
      ), shinydashboard::menuItem("Monocle",
        tabName = "monocle", icon = icon("bullseye")
      ), shinydashboard::menuItem("Regress Features",
        tabName = "regressFeatures", icon = icon("eraser")
      )
    ),
    actionButton("changeEmbedAction",
                 label = "Change Embedding Parameters"
    ), changeEmbedParamsui("changeembed"),
    width = 250
  )
  body <- shinydashboard::dashboardBody(
    waiter::use_waiter(),
    waiter::waiter_show_on_load(),
    waiter::waiter_hide_on_render("plotreadcount1-rcplot"),
    shinydashboard::tabItems(
      shinydashboard::tabItem(
        tabName = "violinPlots",
        fluidRow(
          plotViolinui("violinPlot"),
          plotHeatmapui("heatMap")
        )
      ), shinydashboard::tabItem(
        tabName = "comparePlots",
        h2("Compare Plots") %>%
          default_helper(type = "markdown", content = "comparePlots"),
        fluidRow(
          column(
            plotDimRedui("plotdimred1"),
            width = 6
          ),
          column(
            plotDimRedui("plotdimred2"),
            width = 6
          )
        ),
        fluidRow(
          plotReadCountui("plotreadcount1"),
          plotReadCountui("plotreadcount2")
        ), fluidRow(seuratToolsBox(
          title = "Selected Cells",
          tableSelectedui("tableselected"), width = 6
        ), plotClustree_UI("clustreePlot"))
      ),
      shinydashboard::tabItem(
        tabName = "reformatMetadata",
        h2("Reformat Metadata") %>%
          default_helper(type = "markdown", content = "reformatMetadata"),
        fluidRow((reformatMetadataui("reformatmetadata")))
      ), shinydashboard::tabItem(
        tabName = "subsetSeurat",
        h2("Subset Seurat Input") %>%
          default_helper(type = "markdown", content = "subsetSeurat"),
        fluidRow(
          column(
            plotDimRedui("subset"),
            width = 6),
          column(
            seuratToolsBox(
            title = "Subset Settings",
            shinyWidgets::actionBttn(
              "subsetAction",
              "subset seurat by selected cells"
            ), shinyWidgets::actionBttn(
              "subsetCsv",
              "subset seurat by uploaded csv"
            ), fileInput("uploadCsv",
                         "Upload .csv file with cells to include",
                         accept = c(".csv")),
            shinyjs::useShinyjs(),
            textOutput("subsetMessages"),
            width = 12
          ),
          seuratToolsBox(
            title = "Selected Cells", tableSelectedui("subset"),
            width = 12
          ),
          width = 6)
        )
      ), shinydashboard::tabItem(
        tabName = "findMarkers",
        h2("Find Markers") %>%
          default_helper(type = "markdown", content = "findMarkers"),
        fluidRow(
          column(
            findMarkersui("findmarkers"),
            width = 6
          ),
          column(
            plotDimRedui("markerScatter"),
            width = 6
          )
        )
      ),  shinydashboard::tabItem(
        tabName = "pathwayEnrichment",
        h2("Pathway Enrichment"),
        fluidRow(
          pathwayEnrichmentui("pathwayEnrichment")
        )
      ), shinydashboard::tabItem(
        tabName = "allTranscripts",
        h2("All Transcripts") %>%
          default_helper(type = "markdown", content = "allTranscripts"),
        fluidRow(column(allTranscriptsui("alltranscripts1"),
          width = 6
        ), column(allTranscriptsui("alltranscripts2"),
          width = 6
        ))
      ),
      shinydashboard::tabItem(
        tabName = "plotVelocity",
        h2("RNA Velocity") %>%
          default_helper(type = "markdown", content = "plotVelocity"),
        fluidRow(
          seuratToolsBox(
            plotVelocityui("plotvelocity"),
            width = 12
          )
        )
      ),
      shinydashboard::tabItem(
        tabName = "diffex",
        h2("Differential Expression") %>%
          default_helper(type = "markdown", content = "diffex"),
        fluidRow(
          column(plotDimRedui("diffex"),
                 seuratToolsBox(tableSelectedui("diffex"),
                                width = 12
                 ), width = 6),
          column(diffexui("diffex"), width = 6)
        )
      ), shinydashboard::tabItem(
        tabName = "regressFeatures",
        fluidRow(
          seuratToolsBox(
            title = "Regress Features",
            actionButton("regressAction", "Regress Seurat Objects By Genes") %>%
              default_helper(type = "markdown", content = "regressFeatures"),
            checkboxInput("runRegression",
              "Run Regression?",
              value = FALSE
            ),
            radioButtons("priorGeneSet",
              "Choose a marker gene set:",
              choices = c(
                "Apoptosis",
                "Cell Cycle",
                "Mitochondrial",
                "Ribosomal"
              )
            ), selectizeInput("geneSet",
              "List of genes",
              choices = NULL, multiple = TRUE
            ),
            textInput("geneSetName", "Name for Gene Set"),
            width = 12
          )
        )
      ), shinydashboard::tabItem(
        tabName = "monocle",
        h2("Monocle") %>%
          default_helper(type = "markdown", content = "monocle"),
        fluidRow(monocleui("monocle"))
      )
    )
  )

  ui <- function(request) {
    ui <- dashboardPage(
      header = header, sidebar = sidebar,
      body = body
    )
  }
  server <- function(input, output, session) {
    w <- waiter::Waiter$new()

    shinyhelper::observe_helpers(help_dir = system.file("helpers", package = "seuratTools", lib.loc = "/dataVolume/storage/rpkgs/devel_install/"))
    options(warn = -1)
    # shinylogs::track_usage(storage_mode = shinylogs::store_json(path = "logs/"))
    # projects_db <- "/dataVolume/storage/single_cell_projects/single_cell_projects.db"

    seu <- reactiveValues()

    observe({
      seu_names <- names(seu_list)[!names(seu_list) %in% c("monocle", "active")]
      for (i in seu_names) {
        seu[[i]] <- seu_list[[i]]
      }
      seu$active <- seu[["gene"]]
    })

    organism_type <- reactive({
      input$organism_type
    })

    loom_path <- reactive({
      loom_path
    })

    plot_types <- reactive({
      list_plot_types(seu$active)
    })

    output$featureType <- renderUI({
      req(seu)
      seu_names <- names(seu)[!(names(seu) %in% c("monocle", "active"))]
      shinyWidgets::prettyRadioButtons("feature_type",
        "Feature for Display",
        choices = seu_names,
        selected = "gene", inline = TRUE
      )
    })
    observeEvent(input$feature_type, {
      seu$active <- seu[[input$feature_type]]
    })
    featureType <- reactive({
      featureType <- input$feature_type
    })

    integrationResults <- callModule(
      integrateProj, "integrateproj",
      proj_matrices, seu, proj_dir, con
    )
    newprojList <- reactive({
      req(integrationResults())
      integration_path <- paste0(integrationResults())
      proj_dir(integration_path)
      newintegrated_project <- purrr::set_names(
        integration_path,
        fs::path_file(integration_path)
      )
      newprojList <- c(projList(), newintegrated_project)
    })

    seu <- callModule(reformatMetadata, "reformatmetadata", seu)

    reductions <- reactive({
      req(seu$active)
      names(seu$active@reductions)
      # c("pca", "tsne", "umap")
    })

    observe({
      req(seu$active)

      callModule(plotDimRed, "plotdimred1", seu, plot_types, featureType,
        organism_type = organism_type, reductions
      )
      callModule(plotDimRed, "plotdimred2", seu, plot_types, featureType,
        organism_type = organism_type, reductions
      )
      callModule(plotDimRed, "diffex", seu, plot_types, featureType,
        organism_type = organism_type, reductions
      )
      callModule(plotDimRed, "subset", seu, plot_types, featureType,
        organism_type = organism_type, reductions
      )
      callModule(plotDimRed, "markerScatter", seu, plot_types, featureType,
        organism_type = organism_type, reductions
      )
    })

    callModule(plotReadCount, "plotreadcount1", seu, plot_types)
    callModule(plotReadCount, "plotreadcount2", seu, plot_types)
    callModule(
      plotViolin, "violinPlot", seu, featureType,
      organism_type
    )
    callModule(
      plotHeatmap, "heatMap", seu, featureType,
      organism_type
    )
    callModule(plotClustree, "clustreePlot", seu)
    callModule(tableSelected, "tableselected", seu)
    diffex_selected_cells <- callModule(
      tableSelected, "diffex",
      seu
    )
    subset_selected_cells <- callModule(
      tableSelected, "subset",
      seu
    )
    observeEvent(input$subsetAction, {
      req(subset_selected_cells())
      withCallingHandlers(
        {
          shinyjs::html("subsetMessages", "")
          message("Beginning")
          for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
            seu[[i]] <- seu[[i]][, colnames(seu[[i]]) %in% subset_selected_cells()]
          }
          if (length(unique(seu$gene[[]]$batch)) > 1) {
            print(names(seu)[!(names(seu) %in% c("monocle", "active"))])
            for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
              message(paste0("reintegrating ", i, " expression"))
              seu[[i]] <- reintegrate_seu(seu[[i]],
                feature = i,
                resolution = seq(0.2, 2, by = 0.2)
              )
            }
          }
          else {
            for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
              seu[[i]] <- seurat_pipeline(seu[[i]], resolution = seq(0.2,
                2,
                by = 0.2
              ))
            }
          }
          seu$active <- seu[[input$feature_type]]
          message("Complete!")
        },
        message = function(m) {
          shinyjs::html(id = "subsetMessages", html = paste0(
            "Subsetting Seurat Object: ",
            m$message
          ), add = FALSE)
        }
      )
    })
    observeEvent(input$subsetCsv, {
      req(input$subsetCsv)
      req(input$uploadCsv)
      withCallingHandlers(
        {
          shinyjs::html("subsetMessages", "")
          message("Beginning")
          for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
            seu[[i]] <- subset_by_meta(
              input$uploadCsv$datapath,
              seu[[i]]
            )
          }
          if (length(unique(seu$gene[[]]$batch)) > 1) {
            for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
              message(paste0("reintegrating ", i, " expression"))
              seu[[i]] <- reintegrate_seu(seu[[i]],
                feature = i,
                resolution = seq(0.2, 2, by = 0.2)
              )
            }
          }
          else {
            for (i in names(seu)[!(names(seu) %in% c("monocle", "active"))]) {
              seu[[i]] <- seurat_pipeline(seu[[i]], resolution = seq(0.2,
                2,
                by = 0.2
              ))
            }
          }
          seu$active <- seu[[input$feature_type]]
          message("Complete!")
        },
        message = function(m) {
          shinyjs::html(id = "subsetMessages", html = paste0(
            "Subsetting Seurat Object: ",
            m$message
          ), add = FALSE)
        }
      )
    })
    observeEvent(input$changeEmbedAction, {
      showModal(modalDialog(
        title = "Recalculating Embedding",
        "This process may take a minute or two!"
      ))
      seu <- callModule(
        changeEmbedParams, "changeembed",
        seu
      )
      removeModal()
    })
    callModule(findMarkers, "findmarkers", seu)

    callModule(pathwayEnrichment, "pathwayEnrichment", seu)

    diffex_results <- callModule(
      diffex, "diffex", seu, featureType,
      diffex_selected_cells
    )

    observe({
      req(featureType())
      if("transcript" %in% req(featureType())){
        callModule(
          allTranscripts, "alltranscripts1", seu, featureType,
          organism_type
        )
        callModule(
          allTranscripts, "alltranscripts2", seu, featureType,
          organism_type
        )
      }
    })

    prior_gene_set <- reactive({
      # req(input$priorGeneSet)
      req(seu$active)

      if (is.null(input$priorGeneSet)) {
        ""
      } else if (input$priorGeneSet == "Apoptosis") {
        marker_genes <- c(
          "CASP3", "CASP7", "BAX", "BAK1", "BID", "BBC3",
          "BCL2", "MCL1"
        )

        marker_genes[marker_genes %in% rownames(seu$active)]
      }
      else if (input$priorGeneSet == "Cell Cycle") {
        marker_genes <- c(
          "MCM5", "PCNA", "TYMS", "FEN1", "MCM2", "MCM4",
          "RRM1", "UNG", "GINS2", "MCM6", "CDCA7", "DTL",
          "PRIM1", "UHRF1", "MLF1IP", "HELLS", "RFC2",
          "RPA2", "NASP", "RAD51AP1", "GMNN", "WDR76",
          "SLBP", "CCNE2", "UBR7", "POLD3", "MSH2",
          "ATAD2", "RAD51", "RRM2", "CDC45", "CDC6",
          "EXO1", "TIPIN", "DSCC1", "BLM", "CASP8AP2",
          "USP1", "CLSPN", "POLA1", "CHAF1B", "BRIP1",
          "E2F8"
        )

        marker_genes[marker_genes %in% rownames(seu$active)]
      } else if (input$priorGeneSet == "Mitochondrial") {
        marker_genes <- mito_features[[organism_type()]][["gene"]]

        marker_genes[marker_genes %in% rownames(seu$active)]
      } else if (input$priorGeneSet == "Ribosomal") {
        marker_genes <- ribo_features[[organism_type()]][["gene"]]

        marker_genes[marker_genes %in% rownames(seu$active)]
      }
    })

    observe({
      updateSelectizeInput(session, "geneSet",
        choices = rownames(seu$active),
        selected = prior_gene_set(),
        server = TRUE
      )
    })
    observeEvent(input$regressAction, {
      req(seu$active)
      showModal(modalDialog(
        title = "Regressing out provided list of features",
        "This process may take a minute or two!"
      ))
      seu$gene <- seuratTools::regress_by_features(seu$gene,
        feature_set = list(input$geneSet), set_name = janitor::make_clean_names(input$geneSetName),
        regress = input$runRegression
      )
      seu$active <- seu[[input$feature_type]]
      removeModal()
    })

    observe({
      req(reductions())
      callModule(
        monocle, "monocle", seu, plot_types, featureType,
        organism_type, reductions
      )
    })


    observe({
      req(seu)
      req(input$feature_type)
      req(loom_path())

      seu$active <- callModule(plotVelocity, "plotvelocity", seu, loom_path(), featureType)
    })
  }
  shinyApp(ui, server, enableBookmarking = "server")
}
