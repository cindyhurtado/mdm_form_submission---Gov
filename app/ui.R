
library(shiny)
library(bslib)
library(shinythemes)

sidebar = sidebar(
  width = '20%',
  h6("*You have 10 minutes to complete this submission before the system times out*"),
  HTML("<br>"),
  h5("Templates"),
  downloadButton('download_cam_template','Download Camera Data Template'),
  downloadButton('download_dna_template','Download DNA Template'),
  downloadButton('download_information','Download More information'),
  # h3("Mesocarnivore Biologist", style = 'text-align:center;'),
  HTML("<br><br><br><br><br><br><br><br><br><br>"),
  h6("Reminder: BC Government staff and Wildlife Act Permit holders, where conditions require, must submit their data to Provincial Data Systems (i.e. SPI)*"),tags$a(href="https://www2.gov.bc.ca/gov/content/environment/plants-animals-ecosystems/wildlife/wildlife-data-information/submit-wildlife-data-information", "Submit to Provincial Data Systems"),
  actionButton(
    'download_users_data',
    'Collect Submissions'
  )
)

main = div(
  fluidRow(
    bslib::card(
    #h5('Mesocarnivore database - Scientists'),
    HTML("<br><br><br><br><br><br><br><br>"),
    #h5('Thank you for participating in the Mesocarnivore Distribution Modelling Project'),
    style = 'background: url(Marten_name.jpg); 
             background-size: cover;
             background-position-y: -150px;
             width: 90%; text-align:center;
             color: white;
             margin-left: 5%;
             margin-right: 5%')),
  fluidRow(
    column(
      width = 6, 
      #bslib::card(
      textInput('name_input','Name'),
      textInput('proj_id_input','Project Name') |> 
        tooltip(
          'Unique name for the project. E.g., Enterprise Fisher Survey'
        ),
        textInput('survey_id_input','Survey ID') |> 
          tooltip("The Survey level includes information on different surveys completed within the same Project or Study Area. In some cases, a Project or Study Area will consist of more than one type of Survey. E.g., Enterprise Fisher Survey - Camera 2023."),
      textInput('study_area_input','Study Area')|> 
        tooltip("The Study Area level includes information on unique research or monitoring areas that occurred within a Project. In some cases, a Project will consist of more than one Study Area. In those cases, the Study Area fields can be used to provide information about each unique area. The Project and Study Area will be the same in cases where only one area was surveyed. E.g., Enterprise.")
      #)
    ),
    column(
      width = 6,
      textInput('email_input','Email'),
      textInput('focal_species_input','Focal Species') |> 
        tooltip('Indicate the target species of the project. E.g. multispecies, medium carnivores, bear, badger'),
        selectInput('privacy_options_input','Privacy Options',
                    choices = c('Project scale use' = 'proj',
                                'Secured [Managed as secured datasets within government data systems]' = 'secured',
                                'Publicly accessible [Open data]' = 'public',
                                'Other')) |> 
          tooltip(HTML('<br>Project scale use: Raw contributed data will only be used for the purpose of distribution maps and modelling. Data will be used for this objective only and will not be shared outside of the Conservation Science Section of the Ministry of Water Land and Resource Stewardship (WLRS). 
                       <br>Secured: Contributed data will be incorporated into provincial scale data systems but managed as secure proprietary data under the Species and Ecosystems Data and Information Security policy. <br>
                       Publicly accessible: Contributed data will be incorporated into provincial scale data systems and managed as open data. Data will be publicly accessible. 
                  <br>Other: Other options are possible, contact us if you want to develop a data information sharing agreement')),
      textInput('other_security_input','Other Privay Details')
    )
  ),
  fluidRow(
    div(
      fileInput('data_submission_input',label = 'Your Data', accept = c('.csv','.xlsx')),
      p(HTML('Please upload your data (.csv, .xlsx). 
      Use the template that corresponds to the data type you have. 
      If you do not use our template, your data should at least include:
      <br>• Project name: Unique ID that identifies the project. 
      <br>• Type of record: This can be photographs, hair sampling, sightings, etc. 
      <br>• Lat and Lon: Two columns with coordinates preferably in decimal degrees. 
      <br>• Sampling effort: Two columns with the start date and end date of the survey. 
      <br>• Date and time of the observation: Depending on the type of record only date might be available. 
      <br>• Species name.')) |> htmltools::tagAppendAttributes(class = 'tips')
    ),
    actionButton('submit_form','Submit')
  )
)

my_theme <- bs_theme(
  bg = 'white',
  fg= "black",
  #primary = 'pink',
  secondary = '#d5d7db'
)

#my_theme <- shinytheme("cosmo")

ui = page_sidebar(
  title = "Thank you for participating in the Mesocarnivore Distribution Modelling Project",
  theme = my_theme,
  tags$head(tags$style(
    "
.body {
    font-family: Arial, sans-serif;
}"
  )),
  shinyFeedback::useShinyFeedback(),
  # includeCSS('www/my_style.css'),
  # includeScript('www/my_js.js'),
  sidebar = sidebar,
  main
)

# Change p() to hover text.
# Make sure that log book doesn't get updated (and success alert box) don't 
#   show up when they submit a file that is not of .csv or .xlsx type.
# Name data files with Sys.Time() and make sure there is a column in log_book
#   with that name.