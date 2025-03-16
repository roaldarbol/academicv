// #import "@preview/imprecv:1.0.1": *

// Import the CV library
#import "../cv.typ": *

// Import your CV data
#let cv_data = yaml("template.yml")

// Validate that required fields exist in each section
// #for section in cv_data.sections {
//   if section != none {
//     if "key" not in section {
//       panic("Missing 'key' in section: " + str(section))
//     }
//     if "layout" not in section {
//       panic("Missing 'layout' in section with key: " + section.key)
//     }
//     if "title" not in section and section.key != "personal" {
//       warn("Missing 'title' in section with key: " + section.key)
//     }
//   }
// }

// Get settings from YAML file
#let settings = cv_data.settings

// Initialize the document with the settings and process CV sections
#show: doc => {
  let doc = cvinit(settings, doc)
  process_cv(cv_data, settings)
  doc
}