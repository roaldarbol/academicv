#import "../cv.typ": *

// Custom function for debugging
#let debug_cvsection(data, layout, section, title, settings) = {
  [*DEBUG: Calling cvsection*]
  [
    *Layout:* #layout
    *Section:* #section
    *Title:* #title
    *Data keys:* #data.keys().join(", ")
  ]

  if section in data {
    [*Entries:* #data.at(section).len() entries]
    
    // Show the first entry as a sample
    if data.at(section).len() > 0 {
      [*First entry:* #repr(data.at(section).at(0))]
    }
  } else {
    [*WARNING:* Section "#section" not found in data]
  }
  
  // Log primary/secondary/tertiary elements
  [
    *Has primary_element:* #("primary_element" in data)
    *Has secondary_element:* #("secondary_element" in data)
    *Has tertiary_element:* #("tertiary_element" in data)
  ]
  
  if "primary_element" in data {
    [*primary_element:* #repr(data.primary_element)]
  }
  
  // Now actually call the function
  [*ACTUAL OUTPUT:*]
  
  cvsection(data, layout: layout, section: section, settings: settings, title: title)
}

// Import your CV data
#let cv_data = yaml("template.yml")

// Get settings from YAML file
#let settings = cv_data.settings

// Function to create data for a section that uses the new structure
#let get_section_data(section, cv_data) = {
  // Create a dictionary that will hold all relevant section data
  let result = (:)
  
  // First check if this section has entries in it
  if section != none and "entries" in section {
    // Add entries to result
    result.insert("entries", section.entries)
  } else if section != none and section.key in cv_data {
    // If the section doesn't have entries, use the existing top-level data
    result.insert("entries", cv_data.at(section.key))
  } else {
    // Set empty array if data is not found
    result.insert("entries", [])
  }
  
  // Add layout configuration if present
  if section != none {
    if "primary_element" in section {
      result.insert("primary_element", section.primary_element)
    }
    if "secondary_element" in section {
      result.insert("secondary_element", section.secondary_element)
    }
    if "tertiary_element" in section {
      result.insert("tertiary_element", section.tertiary_element)
    }
  }
  
  return result
}

// Initialize the document with the settings
#set page(
  paper: "a4",
  margin: 3.5cm
)

// Find the personal section and debug it
#let personal_section = cv_data.sections.find(s => s.key == "personal")
#if personal_section != none {
  [== Debugging Personal Section]
  v(1em)
  
  // Get the data for this section
  let section_data = get_section_data(personal_section, cv_data)
  
  // Create a temporary dictionary with just this section's data
  let temp_data = (
    (personal_section.key): section_data.entries,  // Add this section's entries
  )
  
  // Add layout configuration if present
  if "primary_element" in section_data {
    temp_data.insert("primary_element", section_data.primary_element)
  }
  if "secondary_element" in section_data {
    temp_data.insert("secondary_element", section_data.secondary_element)
  }
  if "tertiary_element" in section_data {
    temp_data.insert("tertiary_element", section_data.tertiary_element)
  }
  
  // Debug the call to cvsection
  debug_cvsection(
    temp_data, 
    layout: personal_section.layout, 
    section: personal_section.key, 
    title: if "title" in personal_section { personal_section.title } else { none }, 
    settings: settings
  )
}