#let layout_skills(data, languages, interests, isbreakable: true) = {
    block(breakable: isbreakable)[
        #if languages != none [
            #let langs = ()
            #for lang in languages {
                langs.push([#lang.language (#lang.fluency)])
            }
            - *Languages*: #langs.join(", ")
        ]
        #if data != none [
            #for group in data [
                - *#group.category*: #group.skills.join(", ")
            ]
        ]
        #if interests != none [
            - *Interests*: #interests.join(", ")
        ]
    ]
}