/// Middleware to handle quirks
/datum/preference_middleware/quirks
	var/tainted = FALSE

	action_delegations = list(
		"give_quirk" = PROC_REF(give_quirk),
		"remove_quirk" = PROC_REF(remove_quirk),
	)

/datum/preference_middleware/quirks/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/data = list()

	data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_ui_data(mob/user)
	var/list/data = list()

	if (tainted)
		tainted = FALSE
		data["selected_quirks"] = get_selected_quirks()

	return data

/datum/preference_middleware/quirks/get_constant_data()
	var/list/quirk_info = list()

	var/list/quirks = SSquirks.get_quirks()

	var/max_positive_quirks = CONFIG_GET(number/max_positive_quirks)
	var/positive_quirks_disabled = max_positive_quirks == 0
	for (var/quirk_name in quirks)
		var/datum/quirk/quirk = quirks[quirk_name]
		if(positive_quirks_disabled && initial(quirk.value) > 0)
			continue

		var/datum/quirk_constant_data/constant_data = GLOB.all_quirk_constant_data[quirk]
		var/list/datum/preference/customization_options = constant_data?.get_customization_data()

		quirk_info[sanitize_css_class_name(quirk_name)] = list(
			"description" = initial(quirk.desc),
			"icon" = initial(quirk.icon),
			"name" = quirk_name,
			"value" = initial(quirk.value),
			"customizable" = constant_data?.is_customizable(),
			"customization_options" = customization_options,
			//"veteran_only" = initial(quirk.veteran_only), // NOVA EDIT ADDITION - Veteran quirks // DREAMS EDIT REMOVAL - FUCK VETERAN
			"erp_quirk" = initial(quirk.erp_quirk), // NOVA EDIT ADDITION - Purple ERP quirks
		)

	return list(
		"max_positive_quirks" = max_positive_quirks,
		"quirk_info" = quirk_info,
		"quirk_blacklist" = GLOB.quirk_string_blacklist,
		"points_enabled" = !CONFIG_GET(flag/disable_quirk_points),
	)

/datum/preference_middleware/quirks/on_new_character(mob/user)
	tainted = TRUE

/datum/preference_middleware/quirks/proc/give_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	// DREAMS EDIT REMOVAL START - FUCK VETERAN
	/*
	//NOVA EDIT ADDITION
	var/list/quirks = SSquirks.get_quirks()
	var/datum/quirk/quirk = quirks[quirk_name]
	if(initial(quirk.veteran_only) && !SSplayer_ranks.is_veteran(preferences?.parent))
		return FALSE
	//NOVA EDIT END
	*/
	// DREAMS EDIT REMOVAL END

	var/list/new_quirks = preferences.all_quirks | quirk_name
	if (SSquirks.filter_invalid_quirks(new_quirks, preferences.augments) != new_quirks)// NOVA EDIT - AUGMENTS+
		// If the client is sending an invalid give_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks
	preferences.character_preview_view?.update_body()

	return TRUE

/datum/preference_middleware/quirks/proc/remove_quirk(list/params, mob/user)
	var/quirk_name = params["quirk"]

	var/list/new_quirks = preferences.all_quirks - quirk_name
	if (!(quirk_name in preferences.all_quirks) || SSquirks.filter_invalid_quirks(new_quirks, preferences.augments) != new_quirks)// NOVA EDIT - AUGMENTS+
		// If the client is sending an invalid remove_quirk, that means that
		// something went wrong with the client prediction, so we should
		// catch it back up to speed.
		preferences.update_static_data(user)
		return TRUE

	preferences.all_quirks = new_quirks
	preferences.character_preview_view?.update_body()

	return TRUE

/datum/preference_middleware/quirks/proc/get_selected_quirks()
	var/list/selected_quirks = list()

	for (var/quirk in preferences.all_quirks)
		// DREAMS EDIT REMOVAL START - FUCK VETERAN
		/*
		//NOVA EDIT ADDITION
		var/list/quirks = SSquirks.get_quirks()
		var/datum/quirk/quirk_datum = quirks[quirk]
		if(initial(quirk_datum.veteran_only) && !SSplayer_ranks.is_veteran(preferences?.parent))
			preferences.all_quirks -= quirk
			continue
		//NOVA EDIT END
		*/
		// DREAMS EDIT REMOVAL END
		selected_quirks += sanitize_css_class_name(quirk)

	return selected_quirks
