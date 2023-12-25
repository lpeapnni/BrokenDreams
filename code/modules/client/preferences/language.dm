/datum/preference/choiced/language
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "language"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/language/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Bilingual" in preferences.all_quirks

/datum/preference/choiced/language/init_possible_values()
	var/list/values = list()

// NOVA EDIT ADDITION START
	if(!GLOB.roundstart_languages.len)
// NOVA EDIT ADDITION END
		generate_selectable_species_and_languages()

	values += "Random"

	//we add uncommon as it's foreigner-only.
	var/datum/language/uncommon/uncommon_language = /datum/language/uncommon
	values += initial(uncommon_language.name)

// NOVA EDIT ADDITION START
	for(var/datum/language/language_type as anything in GLOB.roundstart_languages)
// NOVA EDIT ADDITION END
		if(initial(language_type.name) in values)
			continue
		values += initial(language_type.name)

	return values

/datum/preference/choiced/language/apply_to_human(mob/living/carbon/human/target, value)
	return
