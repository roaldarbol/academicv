#import "utils.typ": convert_string_to_length, convert_string_to_color

// Import layouts
#import "layouts/header.typ": layout_header
#import "layouts/timeline.typ": layout_timeline
#import "layouts/numbered_list.typ": layout_numbered_list
#import "layouts/prose.typ": layout_prose
#import "layouts/skills.typ": layout_skills

// Define default settings
#let default_settings = (
    font_heading: "Libertinus Serif",
    font_body: "Libertinus Serif",
    size_heading: 1.1em,
    size_section_heading: 1em,
    size_primary: 10pt,
    size_secondary: 10pt,
    size_tertiary: 8pt,
    style_heading: "normal", // normal, smallcaps, allcaps
    color_heading: black,
    color_body: black,
    color_hyperlink: rgb(0, 0, 255),
    spacing_section: 12pt,
    spacing_entry: 0.5em,
    spacing_element: 2pt,
    spacing_line: 6pt,
    page: (
        paper: "a4",
        numbering: "1 / 1",
        number_align: "center",
        margin: 3.5cm
    )
)

// Process user settings with defaults
#let process_settings(user_settings) = {
  // Create a new dictionary for processed settings
  let processed = (:)
  
  // Copy all default settings first
  for (key, value) in default_settings.pairs() {
    if key == "page" {
      // Special handling for the page settings dictionary
      let page_dict = (:)
      for (pk, pv) in default_settings.page.pairs() {
        page_dict.insert(pk, pv)
      }
      processed.insert("page", page_dict)
    } else {
      processed.insert(key, value)
    }
  }
  
  // Process user settings if they exist
  if user_settings != none {
    for (key, value) in user_settings.pairs() {
      // Skip empty values
      if value == none or value == "" {
        continue
      }
      
      if key == "page" {
        // Process page settings
        for (pk, pv) in value.pairs() {
          if pv == none or pv == "" {
            continue
          }
          
          if pk == "margin" {
            processed.page.insert(pk, convert_string_to_length(pv))
          } else {
            processed.page.insert(pk, pv)
          }
        }
      } else if key.starts-with("size_") or key.starts-with("spacing_") {
        // Process length values - ensure they are actually length values
        let converted = convert_string_to_length(value)
        
        // If conversion returned the original string, try to force a valid length
        if type(converted) == str {
          if key == "size_heading" { processed.insert(key, 1.1em) }
          else if key == "size_section_heading" { processed.insert(key, 1em) }
          else if key == "size_primary" { processed.insert(key, 10pt) }
          else if key == "size_secondary" { processed.insert(key, 10pt) }
          else if key == "size_tertiary" { processed.insert(key, 8pt) }
          else if key == "spacing_section" { processed.insert(key, 12pt) }
          else if key == "spacing_entry" { processed.insert(key, 0.5em) }
          else if key == "spacing_element" { processed.insert(key, 2pt) }
          else if key == "spacing_line" { processed.insert(key, 6pt) }
        } else {
          processed.insert(key, converted)
        }
      } else if key.starts-with("color_") {
        // Process color values
        processed.insert(key, convert_string_to_color(value))
      } else {
        // Copy other values
        processed.insert(key, value)
      }
    }
  }
  
  return processed
}

// Set rules
#let setrules(settings, doc) = {
  set text(
    font: settings.font_body,
    size: settings.size_primary,
    hyphenate: false,
  )

  set list(
    spacing: settings.spacing_line
  )

  set par(
    leading: settings.spacing_line,
    justify: true,
  )

  show link: it => {
    text(
      fill: settings.color_hyperlink,
    )[#it]
  }

  doc
}

// Show rules
#let showrules(settings, doc) = {
  // Uppercase section headings
  show heading.where(
    level: 2,
  ): it => block(width: 100%)[
    #v(settings.spacing_section)
    #set align(left)
    #set text(font: settings.font_heading, 
            size: settings.size_section_heading, 
            weight: "semibold")
    #if (settings.style_heading == "smallcaps") {
      smallcaps(it.body)
    } else if (settings.style_heading == "allcaps") {
      upper(it.body)
    } else {
      it.body
    }
    #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // draw a line
  ]

  // Name title/heading
  show heading.where(
    level: 1,
  ): it => block(width: 100%)[
    #set text(font: settings.font_heading, 
            size: settings.size_heading, 
            weight: "semibold")
    #if (settings.style_heading == "smallcaps") {
      smallcaps(it.body)
    } else if (settings.style_heading == "allcaps") {
      upper(it.body)
    } else {
      it.body
    }
    #v(2pt)
  ]

  doc
}

// Set page layout
#let customrules(settings, doc) = {
  set page(
    paper: settings.page.paper,
    numbering: settings.page.numbering,
    number-align: {
      let align = settings.page.number_align
      if align == "center" { center } 
      else if align == "left" { left } 
      else if align == "right" { right }
      else { center }  // Default
    },
    margin: settings.page.margin,
  )
  
  doc
}

// Initialize CV with settings
#let cvinit(user_settings, doc) = {
  // Process user settings with defaults
  let settings = process_settings(user_settings)
  
  doc = setrules(settings, doc)
  doc = showrules(settings, doc)
  doc = customrules(settings, doc)
  doc
}

// Function to extract section data from configuration
#let get_section_data(section, cv_data) = {
  // Create a dictionary that will hold all relevant section data
  let result = (:)
  
  // First check if this section has entries in it
  if section != none and "entries" in section {
    // Add entries to result
    result.insert("entries", section.entries)
  } else {
    // If the section doesn't have entries, use the existing top-level data
    if section != none and section.key in cv_data {
      result.insert("entries", cv_data.at(section.key))
    } else {
      // Set empty array if data is not found
      result.insert("entries", [])
    }
  }
  
  // Add layout configuration if present
  if "primary_element" in section {
    result.insert("primary_element", section.primary_element)
  }
  if "secondary_element" in section {
    result.insert("secondary_element", section.secondary_element)
  }
  if "tertiary_element" in section {
    result.insert("tertiary_element", section.tertiary_element)
  }
  
  return result
}

// Main section rendering function
#let cv_section(info, layout: none, section: none, title: none, settings: none, isbreakable: true) = {
    // Use the provided section
    let section_key = section
    
    // Set default title
    let section_title = title

    // Only render the section if it exists in the info data (skip title check for heading layout)
    if ((section_key in info) and (info.at(section_key) != none)) {
        // For heading layout, don't add a section title
        if layout == "header" {
            // Get the primary, secondary, tertiary elements from the section if they exist
            let primary = if "primary_element" in info { info.primary_element } else { none }
            let secondary = if "secondary_element" in info { info.secondary_element } else { none }
            let tertiary = if "tertiary_element" in info { info.tertiary_element } else { none }
            
            // For the heading layout, use the entries data format
            layout_header(info.at(section_key), 
                          primary_element: primary, 
                          secondary_element: secondary, 
                          tertiary_element: tertiary, 
                          settings: settings,
                          isbreakable: isbreakable)
        } else {
            block[
                == #section_title
                
                // Use the appropriate layout function based on layout
                #if layout == "prose" {
                    layout_prose(info.at(section_key), isbreakable: isbreakable)
                } else if layout == "timeline" {
                    // Get the primary, secondary, tertiary elements from the section if they exist
                    let primary = if "primary_element" in info { info.primary_element } else { none }
                    let secondary = if "secondary_element" in info { info.secondary_element } else { none }
                    let tertiary = if "tertiary_element" in info { info.tertiary_element } else { none }
                    
                    layout_timeline(info.at(section_key), 
                                   primary_element: primary, 
                                   secondary_element: secondary, 
                                   tertiary_element: tertiary, 
                                   settings: settings,
                                   isbreakable: isbreakable)
                } else if layout == "numbered_list" {
                    layout_numbered_list(info.at(section_key), isbreakable: isbreakable)
                } else if layout == "skills" {
                    layout_skills(info.at(section_key), info.at("languages", default: none), info.at("interests", default: none), isbreakable: isbreakable)
                } else {
                    [No layout function defined for "#layout"]
                }
            ]
        }
    } else {
        none
    }
}

// Process CV sections dynamically based on configuration
#let process_cv(cv_data, settings) = {
  if "sections" in cv_data {
    for section in cv_data.sections {
      if section.at("show", default: true) == true {
        // Declare these variables outside the if/else blocks so they're available in the entire scope
        let layout = section.layout
        let key = section.key
        let title = if "title" in section { section.title } else { none }
          
        // Get the data for this section
        let section_data = get_section_data(section, cv_data)
        
        // Create a temporary dictionary with just this section's data
        let temp_data = (
          (key): section_data.entries,  // Add this section's entries
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

        // Call cvsection with the appropriate data
        cv_section(temp_data, layout: layout, section: key, settings: settings, title: title)
      }
    }
  }
}