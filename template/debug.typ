#import "../cv.typ": *

// Simple debug function
#let debug(label, value) = {
  [*DEBUG #label:* #repr(value)]
  linebreak()
}

// Import your CV data
#let cv_data = yaml("template.yml")

// Debug the personal section
#let personal_section = cv_data.sections.find(s => s.key == "personal")
debug("personal_section", personal_section)

// Debug the settings
debug("settings", cv_data.settings)

// Debug the personal entry
#let personal_entry = personal_section.entries.at(0)
debug("personal_entry", personal_entry)

// Debug the primary element
debug("primary_element", personal_section.primary_element)

// Debug the secondary element
debug("secondary_element", personal_section.secondary_element)

// Try a simple test to render just the name
#block[
  = #personal_entry.name
]

// Try a simple test to render the personal section directly
#block[
  #heading(level: 1)[#personal_entry.name]
  
  // Show title if exists
  #if "title" in personal_entry and personal_entry.title != none {
    text(weight: "semibold")[
      #if type(personal_entry.title) == array {
        personal_entry.title.join("  /  ")
      } else {
        personal_entry.title
      }
    ]
  }
  
  // Contact info
  #let contacts = ()
  
  #if "email" in personal_entry {
    contacts.push(link("mailto:" + personal_entry.email)[#personal_entry.email])
  }
  
  #if "website" in personal_entry {
    let display_url = personal_entry.website.split("//").at(1, default: personal_entry.website)
    contacts.push(link(personal_entry.website)[#display_url])
  }
  
  #if contacts.len() > 0 {
    contacts.join([#sym.space.en | #sym.space.en])
  }
]