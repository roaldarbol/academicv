// Merge with defaults for any missing settings
#let convert_string_to_length(string) = {
  if type(string) == str {
    if string.ends-with("pt") {
      return float(string.replace("pt", "")) * 1pt
    } else if string.ends-with("em") {
      return float(string.replace("em", "")) * 1em
    } else if string.ends-with("cm") {
      return float(string.replace("cm", "")) * 1cm
    } else if string.ends-with("mm") {
      return float(string.replace("mm", "")) * 1mm
    } else {
      return string
    }
  } else {
    return string
  }
}

#let convert_string_to_color(string_value) = {
  if type(string_value) == str {
    if string_value.starts-with("rgb(") and string_value.ends-with(")") {
      let rgb_str = string_value.slice(4, string_value.len() - 1)
      let components = rgb_str.split(",").map(s => int(float(s.trim())))
      if components.len() == 3 {
        return rgb(components.at(0), components.at(1), components.at(2))
      }
    } else if string_value.starts-with("rgba(") and string_value.ends-with(")") {
      let rgba_str = string_value.slice(5, string_value.len() - 1)
      let components = rgba_str.split(",")
      if components.len() == 4 {
        let r = int(float(components.at(0).trim()))
        let g = int(float(components.at(1).trim()))
        let b = int(float(components.at(2).trim()))
        let a = float(components.at(3).trim())
        return rgba(r, g, b, a)
      }
    } else if string_value.starts-with("#") {
      // Convert hex color to rgb
      let hex = string_value.slice(1)
      if hex.len() == 6 {
        let r = int(hex.slice(0, 2), base: 16)
        let g = int(hex.slice(2, 4), base: 16)
        let b = int(hex.slice(4, 6), base: 16)
        return rgb(r, g, b)
      } else if hex.len() == 3 {
        let r = int(hex.at(0) + hex.at(0), base: 16)
        let g = int(hex.at(1) + hex.at(1), base: 16)
        let b = int(hex.at(2) + hex.at(2), base: 16)
        return rgb(r, g, b)
      }
    }
  }
  
  // Default to blue if conversion fails
  return rgb(0, 0, 255)  // Using integer values now
}