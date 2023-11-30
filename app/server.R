
library(shiny)
library(bslib)
library(tidyverse)

server <- function(input, output, session) {
  
  # Adjust working directory for testing purposes
  # before publishing Shiny app to shinyapps.io
  if(!stringr::str_detect(getwd(),'/www$')){
    setwd(paste0(getwd(),'/www'))
  }
  
  # If no log-book currently, create the project 'log-book'
  if(!file.exists('project_logbook.xlsx')){
    openxlsx::write.xlsx(
      data.frame(
        Date = c('a'),
        Name = c('a'),
        Email = c('a'),
        Project_ID = c('a'),
        Focal_Species = c('a'),
        Survey_ID = c('a'),
  #      Privacy_Options = c('a'),
  #      Other_Detail = c('a'),
        Study_Area = c('a'),
        Data_File = c('a')
      ),
      'project_logbook.xlsx'
    )
  }
  
  # Open the project 'log-book'
  log_book = openxlsx::read.xlsx(
    'project_logbook.xlsx'
  ) |> 
    dplyr::filter(Date != 'a')
  
  # User data
  
  # user_data = reactive({
  #   list(
  #     list.files(path = './data/', pattern = '.csv', full.names = T) |> 
  #       lapply(readr::read_csv),
  #     list.files(path = './data/', pattern = '.xlsx', full.names = T) |> 
  #       lapply(openxlsx::read.xlsx)
  #   )
  # })
  
  # Set up download handlers for template forms.
  
  output$download_cam_template <- downloadHandler(
    filename = function() {
      "Camera_data_MDB_share_template.xlsx"
    },
    content = function(file) {
      file.copy(from = 'Camera_data_MDB_share.xlsx',
                to = file)
    }
  )
  
  output$download_dna_template <- downloadHandler(
    filename = function() {
      "DNA_data_MDB_share.xlsx"
    },
    content = function(file) {
      file.copy(from = 'DNA_data_MDB_share.xlsx',
                to = file)    
      }
  )
  
  output$download_information <- downloadHandler(
    filename = function() {
      "Mesocarnivore distribution project_WLRS.pdf"
    },
    content = function(file) {
      file.copy(from = 'Mesocarnivore distribution project_WLRS.pdf',
                to = file)    
    }
  )
  
  observeEvent(input$submit_form, {
    
    log_book = openxlsx::read.xlsx('project_logbook.xlsx')
    
    # Clear any shinyFeedback from prior rounds of submission attempts
    shinyFeedback::hideFeedback('name_input')
    shinyFeedback::hideFeedback('proj_id_input')
    shinyFeedback::hideFeedback('study_area_input')
    shinyFeedback::hideFeedback('email_input')
    shinyFeedback::hideFeedback('survey_id_input')
    shinyFeedback::hideFeedback('data_submission_input')
    
    # Check that all fields have something entered in them.
    
    if(input$survey_id_input == "" | 
       input$email_input == "" | 
       input$study_area_input == "" | 
       input$proj_id_input == "" | 
       input$name_input == "" | 
       is.null(input$data_submission_input)){
      
      if(input$survey_id_input == ''){
        shinyFeedback::showFeedback('survey_id_input',
                                    color = '#d9534f',
                                    text = 'Please fill in this field.')
      }
      if(input$email_input == ''){
        shinyFeedback::showFeedback('email_input',
                                    color = '#d9534f',
                                    text = 'Please fill in this field.')
      }
      if(input$study_area_input == ''){
        shinyFeedback::showFeedback('study_area_input',
                                    color = '#d9534f',
                                    text = 'Please fill in this field.')
      }
      if(input$proj_id_input == ''){
        shinyFeedback::showFeedback('proj_id_input',
                                    color = '#d9534f',
                                    text = 'Please fill in this field.')
      }
      if(input$name_input == ''){
        shinyFeedback::showFeedback('name_input',
                                    color = '#d9534f',
                                    text = 'Please fill in this field.')
      }
      if(is.null(input$data_submission_input)){
        shinyFeedback::showFeedback('data_submission_input',
                                    color = '#d9534f',
                                    text = 'Please upload one file.')
      }
      
    } else {
      # Double check that the submitted file is either .csv or .xlsx format.
      if(stringr::str_detect(input$data_submission_input$datapath,'.(csv|xlsx)')){
      
    # Add details to an excel 'log-book' of projects.
    log_book = log_book |> 
      dplyr::bind_rows(
        data.frame(
              Date = as.character(Sys.Date()),
              Name = input$name_input,
              Email = input$email_input,
              Project_ID = input$proj_id_input,
              Focal_Species = input$focal_species_input,
              Survey_ID = input$survey_id_input,
  #            Privacy_Options = input$privacy_options_input,
  #            Other_Detail = input$other_security_input,
              Study_Area = input$study_area_input,
              Data_File = paste0(input$proj_id_input, '-',Sys.Date(),'.csv')
        )
      )
    
    # Update the log-book form in the www/ folder with this
    # new entry.
    openxlsx::write.xlsx(log_book, 'project_logbook.xlsx', overwrite = T)
    
    cat(paste0("\nJust updated excel logbook with row for ",input$proj_id_input))
    
    if(stringr::str_detect(input$data_submission_input$datapath,'.csv')){
      
      # Read in the file that the user has uploaded.
      content = readr::read_csv(input$data_submission_input$datapath)
      
      # And write that file to our data folder, inside the app's www/ folder.
      readr::write_csv(content, paste0('data/',input$proj_id_input, '-',Sys.Date(),'.csv'))
    }
    
    if(stringr::str_detect(input$data_submission_input$datapath,'.xls(x)?')){
      
      file.copy(
        from = input$data_submission_input$datapath,
        to = paste0('data/',input$proj_id_input,'-',Sys.Date(),stringr::str_extract(input$data_submission_input$name,'.xls(x)?$'))
      )
      
    }
    
    showModal(
      modalDialog(
        title = 'Submission Successful!',
        h5('Thank you!'),
        easyClose = T
      )
    )
    
    shiny::updateTextInput(session = session, 'name_input', value = '')
    shiny::updateTextInput(session = session, 'email_input', value = '')
    shiny::updateTextInput(session = session, 'survey_id_input', value = '')
    shiny::updateTextInput(session = session, 'proj_id_input', value = '')
    shiny::updateTextInput(session = session, 'study_area_input', value = '')
    shiny::updateSelectInput(session = session, 'focal_species_input', selected = 'Multispecies')
#    shiny::updateSelectInput(session = session, 'privacy_options_input', selected = 'proj')
    
      } else {
        showModal(
          modalDialog(
            title = 'Submission Unsuccessful!',
            h5('File Format not .csv or .xlsx'),
            easyClose = T
          )
        )
      }
    }
  })
  
  observeEvent(input$download_users_data, {
    showModal(
      modalDialog(
      title = 'Log-in Credentials',
      fluidRow(
        column(width = 6,
               textInput('username_input',
                         'Username')
        ),
        column(width = 6,
               textInput('password_input',
                         'Password'))
      ),
      fluidRow(
        downloadButton('submit_login_creds',
                     'Submit Log-in Credentials')
      ))
      )
  })
  
  # Create a 'downloadHandler' - this allows the user to download
  # things from the Shiny app to their computer's download folder, 
  # via their internet browser.
  output$submit_login_creds <- downloadHandler(
    
    filename = function() {
      paste0("user_data_download-", Sys.Date(), ".zip")
      # paste0("user_data_download-", Sys.Date(), ".Rdata")
    },
    content = function(file) {
      if(input$username_input == 'mesocarnivoresBC' & input$password_input == 'Lynxcanadensis'){
        
        # Read in most up-to-date log book.
        log_book = openxlsx::read.xlsx('project_logbook.xlsx') |> 
          dplyr::filter(Date != 'a')
        
        temp_directory <- file.path(tempdir(), as.integer(Sys.time()))
        dir.create(temp_directory)
        dir.create(paste0(temp_directory,'/csv'))
        dir.create(paste0(temp_directory,'/excel'))
        
        # Write the excel 'log-book' file out to download folder.
        openxlsx::write.xlsx(log_book, file.path(temp_directory, "log_book.xlsx"))
        
        # Write the user-submitted excel documents to the excel folder.
        
        list.files(path = 'data/', pattern = '.xls(x)?', full.names = T) |> 
          lapply(\(x) file.copy(from = x,
                                to = paste0(temp_directory, "/excel/",stringr::str_remove(x,'data/'))))
                 
        # Write the user-submitted csv documents to the csv folder.
        list.files(path = 'data/', pattern = '.csv', full.names = T) |> 
          lapply(\(x) file.copy(from = x,
                                to = paste0(temp_directory, "/csv/",stringr::str_remove(x,'data/'))))
        
        zip::zip(
          zipfile = file,
          files = dir(temp_directory),
          root = temp_directory
        )
        
      }
    }
  )
}