#let layout_header(entry, primary_element: none, secondary_element: none, tertiary_element: none, settings: none, isbreakable: true) = {
    // Get default settings from the main file
    let default_settings = (
        font_heading: "Libertinus Serif",
        font_body: "Libertinus Serif",
        size_heading: 1.1em,
        size_section_heading: 1em,
        size_primary: 10pt,
        size_secondary: 10pt,
        size_tertiary: 8pt,
        spacing_element: 2pt,
        style_heading: "normal",
        color_hyperlink: rgb(0, 0, 255)
    )
    
    // Default settings if none provided
    let settings = if settings == none { default_settings } else { settings }
    
    // Get spacing settings with defaults - ensure it's a length
    let element_spacing = if "spacing_element" in settings {
        if type(settings.spacing_element) == length {
            settings.spacing_element
        } else {
            default_settings.spacing_element
        }
    } else {
        default_settings.spacing_element
    }
    
    // Convert single elements to arrays for consistent handling
    let primary = if primary_element != none and type(primary_element) == array { primary_element } else { (primary_element,) }
    let secondary = if secondary_element != none and type(secondary_element) == array { secondary_element } else { (secondary_element,) }
    let tertiary = if tertiary_element != none and type(tertiary_element) == array { tertiary_element } else { (tertiary_element,) }
    
    // Helper function to safely check if a field exists
    let has_field(entry, field) = {
        if entry == none {
            return false
        }
        if field not in entry {
            return false
        }
        return entry.at(field) != none
    }
    
    // Setup a block for the header
    block(width: 100%, breakable: isbreakable)[
        #align(center)[
            // PRIMARY ELEMENTS SECTION
            #for (i, field) in primary.enumerate() {
                if has_field(entry, field) {
                    if field == "name" {
                        // Display name as a heading
                        [= #entry.at(field)]
                    } 
                    // else if field == "title" and entry.at("title") != none and type(entry.at("title")) == array {
                    //     // Display titles in semibold
                    //     block(width: 100%)[
                    //         #text(weight: "semibold", entry.title.join("  /  "))
                    //         #v(-4pt)
                    //     ]
                    // } else if field == "location" and entry.at("location") != none and type(entry.at("location")) == dictionary {
                    //     // Handle location fields display
                    //     if "city" in entry.location or "region" in entry.location or "country" in entry.location {
                    //         let location_parts = ()
                            
                    //         if "city" in entry.location and entry.location.city != none {
                    //             location_parts.push(entry.location.city)
                    //         }
                    //         if "region" in entry.location and entry.location.region != none {
                    //             location_parts.push(entry.location.region)
                    //         }
                    //         if "country" in entry.location and entry.location.country != none {
                    //             location_parts.push(entry.location.country)
                    //         }
                            
                    //         let location = location_parts.join(", ")
                            
                    //         block(width: 100%)[
                    //             #location
                    //             #v(-4pt)
                    //         ]
                    //     }
                    // } else {
                    //     // Display other primary elements
                    //     [#entry.at(field)]
                    // }
                    
                    // Add spacing between primary elements if needed
                    if i < primary.len() - 1 {
                        v(4pt)
                    }
                }
            }
            
            // SECONDARY ELEMENTS SECTION
            #if secondary.len() > 0 {
                v(element_spacing) // Add spacing between primary and secondary
                
                block(width: 100%)[
                    #let contacts = ()
                    
                    // Process each secondary element
                    #for field in secondary {
                        if field == "email" and has_field(entry, "email") {
                            contacts.push(box(link("mailto:" + entry.email)[#entry.email]))
                        } else if field == "phone" and has_field(entry, "phone") {
                            contacts.push(box(link("tel:" + entry.phone)[#entry.phone]))
                        } else if field == "url" and has_field(entry, "url") {
                            let display_url = entry.url.split("//").at(1, default: entry.url)
                            contacts.push(box(link(entry.url)[#display_url]))
                        } else if field == "website" and has_field(entry, "website") {
                            let display_url = entry.website.split("//").at(1, default: entry.website)
                            contacts.push(box(link(entry.website)[#display_url]))
                        } else if field == "profiles" and has_field(entry, "profiles") and type(entry.profiles) == array {
                            for profile in entry.profiles {
                                if type(profile) == dictionary and "url" in profile and profile.url != none {
                                    let display_url = if type(profile.url) == str { 
                                        profile.url.split("//").at(1, default: profile.url)
                                    } else {
                                        "URL"
                                    }
                                    contacts.push(box(link(profile.url)[#display_url]))
                                }
                            }
                        } else if has_field(entry, field) {
                            // Generic handling for other secondary elements
                            contacts.push(box(entry.at(field)))
                        }
                    }
                    
                    // Display contacts joined with separators
                    #set text(font: if "font_body" in settings { settings.font_body } else { default_settings.font_body }, 
                           weight: "medium", 
                           size: if "size_secondary" in settings { 
                               if type(settings.size_secondary) == length {
                                   settings.size_secondary
                               } else {
                                   default_settings.size_secondary
                               }
                           } else { 
                               default_settings.size_secondary 
                           })
                    #if contacts.len() > 0 {
                        pad(x: 0em)[
                            #contacts.join([#sym.space.en | #sym.space.en])
                        ]
                    }
                ]
            }
            
            // TERTIARY ELEMENTS SECTION
            #if tertiary.len() > 0 {
                let tertiary_content = ()
                for field in tertiary {
                    if has_field(entry, field) {
                        tertiary_content.push(entry.at(field))
                    }
                }
                
                if tertiary_content.len() > 0 {
                    v(element_spacing) // Add spacing before tertiary
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
            }
        ]
    ]
}