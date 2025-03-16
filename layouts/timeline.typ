#let layout_timeline(data, primary_element: none, secondary_element: none, tertiary_element: none, settings: none, isbreakable: true) = {
  // Get default settings for this layout
  let default_settings = (
    font_body: "Libertinus Serif",
    size_tertiary: 8pt,
    spacing_entry: 0.5em,
    spacing_element: 2pt
  )
  
  // Default settings if none provided
  let settings = if settings == none { default_settings } else { settings }
  
  // Get the global settings
  let year_column_width = 7em
  
  // Get spacing settings with defaults - ensure it's a length
  let entry_spacing = if "spacing_entry" in settings {
    if type(settings.spacing_entry) == length {
      settings.spacing_entry
    } else {
      default_settings.spacing_entry
    }
  } else {
    default_settings.spacing_entry
  }
  
  let element_spacing = -1em + (if "spacing_element" in settings {
    if type(settings.spacing_element) == length {
      settings.spacing_element
    } else {
      default_settings.spacing_element
    }
  } else {
    default_settings.spacing_element
  })
  
  // Convert single elements to arrays for consistent handling
  let primary = if primary_element != none and type(primary_element) == array { primary_element } else { (primary_element,) }
  let secondary = if secondary_element != none and type(secondary_element) == array { secondary_element } else { (secondary_element,) }
  let tertiary = if tertiary_element != none and type(tertiary_element) == array { tertiary_element } else { (tertiary_element,) }
  
  // List of mentor types for special handling
  let mentor_types = (
    (key: "advisors", singular: "Advisor", plural: "Advisors"),
    (key: "professors", singular: "Professor", plural: "Professors"),
    (key: "supervisors", singular: "Supervisor", plural: "Supervisors")
  )
  
 // Helper function to check if a field is a mentor type
  let is_mentor_type(field) = {
    for type in mentor_types {
      if field == type.key {
        return true
      }
    }
    return false
  }
  
  // Helper function to format mentor lists
  let format_mentors(entry, key) = {
    if entry == none { return none }
    
    let mentor_type = mentor_types.find(t => t.key == key)
    if mentor_type == none { return none }
    
    let mentors = entry.at(key, default: none)
    if mentors == none or mentors.len() == 0 { return none }
    
    // Create the label part in italic
    let label = if mentors.len() == 1 { mentor_type.singular + ":" } else { mentor_type.plural + ":" }
    
    // Format the mentor names
    let names = if mentors.len() == 1 {
      mentors.at(0)
    } else if mentors.len() == 2 {
      [#mentors.at(0) and #mentors.at(1)]
    } else {
      let result = []
      for (i, mentor) in mentors.enumerate() {
        if i == mentors.len() - 1 {
          result = result + [and #mentor]
        } else if i == mentors.len() - 2 {
          result = result + [#mentor ]
        } else {
          result = result + [#mentor, ]
        }
      }
      result
    }
    
    // Combine the label and names
    [#text(style: "italic")[#label] #names]
  }
  
  // Safely check if a field exists in an entry
  let has_field(entry, field) = {
    if entry == none {
      return false
    }
    if field != none and field not in entry {
      return false
    }
    return entry.at(field) != none
  }
  
  // Create the container block
  block(width: 100%, breakable: isbreakable, inset: 0pt, outset: 0pt)[
    // Process each entry
    #for (i, entry) in data.enumerate() {
      // Make sure entry is not none before proceeding
      if entry != none {
        // Format year text
        let year_text = if has_field(entry, "end_date") {
          if has_field(entry, "start_date") {
            if entry.end_date == "present" or entry.end_date == "Present" {
              [#entry.start_date - Present]
            } else if entry.start_date == entry.end_date {
              [#entry.start_date]
            } else {
              [#entry.start_date - #entry.end_date]
            }
          } else {
            [#entry.end_date]
          }
        } else if has_field(entry, "start_date") {
          [#entry.start_date]
        } else {
          []
        }
        
        // Create grid for this entry
        grid(
          columns: (year_column_width, 1fr),
          gutter: 1em,
          
          // Year column
          align(right)[#year_text],
          
          grid.vline(),
          
          // Entry details with configurable spacing
          pad(left: 0.5em)[
            // PRIMARY ELEMENTS SECTION
            
            // First primary element (bold)
            #let first_primary_found = false
            #let first_primary_field = none
            #let first_primary_content = none
            
            // Find the first available primary element
            #for field in primary {
              if has_field(entry, field) and not first_primary_found {
                first_primary_field = field
                first_primary_content = entry.at(field)
                first_primary_found = true
                break
              }
            }
            
            // Display first primary element in bold if found
            #if first_primary_found {
              text(weight: "bold")[#first_primary_content]
              
              // Handle location specially for institution
              if first_primary_field == "institution" and has_field(entry, "location") {
                [, #entry.location]
              }
              
              // Check for other primary elements to display in normal weight
              let additional_primary = ()
              for field in primary {
                if field != first_primary_field and has_field(entry, field) {
                  additional_primary.push(entry.at(field))
                }
              }
              
              // Add additional primary elements if any
              if additional_primary.len() > 0 {
                [, #additional_primary.join(", ")]
              }
            }
            
            // SECONDARY ELEMENTS SECTION
            
            // Collect all secondary elements
            #let secondary_content = ()
            
            // Regular secondary elements
            #for field in secondary {
              if not is_mentor_type(field) and has_field(entry, field) {
                secondary_content.push(entry.at(field))
              }
            }
            
            // Add mentor fields from secondary
            #for field in secondary {
              if is_mentor_type(field) {
                let mentor_text = format_mentors(entry, field)
                if mentor_text != none {
                  secondary_content.push(mentor_text)
                }
              }
            }
            
            // Add mentor types not explicitly in secondary
            #for type in mentor_types {
              if type.key not in secondary and has_field(entry, type.key) {
                let mentor_text = format_mentors(entry, type.key)
                if mentor_text != none {
                  secondary_content.push(mentor_text)
                }
              }
            }
            
            // Display secondary content if exists
            #if secondary_content.len() > 0 and first_primary_found {
              v(element_spacing) // Add spacing between primary and secondary
              
              // We need to handle secondary content differently
              // For regular secondary elements (not advisor/professor), use italic
              // For advisor/professor elements, they are already formatted correctly
              let regular_secondary = ()
              let special_secondary = ()
              
              for item in secondary_content {
                if type(item) == str {
                  regular_secondary.push(item)
                } else {
                  special_secondary.push(item)
                }
              }
              
              // Display regular secondary elements in italic if any exist
              if regular_secondary.len() > 0 {
                text(style: "italic")[#regular_secondary.join(", ")]
              }
              
              // Display special secondary elements (already formatted) if any exist
              if special_secondary.len() > 0 {
                if regular_secondary.len() > 0 { [, ] }
                special_secondary.join(", ")
              }
            }
            
            // TERTIARY ELEMENTS SECTION
            
            // Collect tertiary elements
            #let tertiary_content = ()
            #for field in tertiary {
              if has_field(entry, field) {
                tertiary_content.push(entry.at(field))
              }
            }
            
            // Display tertiary content if exists
            #if tertiary_content.len() > 0 {
              if first_primary_found or secondary_content.len() > 0 {
                v(element_spacing) // Add spacing before tertiary
              }
              
              text(size: if "size_tertiary" in settings { 
                if type(settings.size_tertiary) == length {
                  settings.size_tertiary
                } else {
                  default_settings.size_tertiary
                }
              } else { 
                default_settings.size_tertiary 
              })[
                #tertiary_content.join(", ")
              ]
            }
          ]
        )
      }
      
      // Add configurable space between entries
      if i < data.len() - 1 {
        v(entry_spacing)
      }
    }
  ]
}