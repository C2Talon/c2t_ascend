//c2t ascend
//c2t

record c2t_ascend_field {
	string name;
	string desc;
	string [int] data;
};

string [int] c2t_ascend_type() {
	string [int] out = {
		1:"casual",
		2:"normal",
		3:"hardcore"
		};
	return out;
}

string [int] c2t_ascend_class() {
	string [int] out;
	foreach x in $classes[]
		out[x.id] = x;
	return out;
}

string [int] c2t_ascend_gender() {
	string [int] out = {
		1:"male",
		2:"female"
		};
	return out;
}

string [int] c2t_ascend_path() {
	string [int] out;
	out[0] = "no path";
	foreach x in $paths[]
		out[x.id] = x.name;
	return out;
}

string [int] c2t_ascend_moon() {
	string [int] out = {
		1:"The Mongoose",
		2:"The Wallaby",
		3:"The Vole",
		4:"The Platypus",
		5:"The Opossum",
		6:"The Marmot",
		7:"The Wombat",
		8:"The Blender",
		9:"The Packrat"
		};
	return out;
}

string [int] c2t_ascend_deli() {
	string [int] out;
	out[0] = "none";
	foreach x in $items[
		astral hot dog dinner,
		astral six-pack,
		[10882]carton of astral energy drinks
		]
	{
		out[x.id] = x.name;
	}
	return out;
}

string [int] c2t_ascend_pet() {
	string [int] out;
	out[0] = "none";
	for (int i = 5028;i <= 5042;i++)
		out[i] = i.to_item().name;
	return out;
}

string [int] c2t_ascend_permType() {
	string [int] out = {
		0:"none",
		1:"softcore",
		2:"hardcore"
		};
	return out;
}

c2t_ascend_field [int] c2t_ascend_data = {
	new c2t_ascend_field(
		"Type",
		"Ascension type; reminder: paths cannot be done in casual",
		c2t_ascend_type()),
	new c2t_ascend_field(
		"Class",
		"What are you?",
		c2t_ascend_class()),
	new c2t_ascend_field(
		"Gender",
		"Be what you want to be",
		c2t_ascend_gender()),
	new c2t_ascend_field(
		"Path",
		"Path to tread. Make sure to pick a valid class for this as well",
		c2t_ascend_path()),
	new c2t_ascend_field(
		"Moon",
		"Moon sign to play under",
		c2t_ascend_moon()),
	new c2t_ascend_field(
		"Deli",
		"Astral consumable to bring",
		c2t_ascend_deli()),
	new c2t_ascend_field(
		"Pet",
		"Astral equipment to bring",
		c2t_ascend_pet()),
	new c2t_ascend_field(
		"Perm",
		"Perm softcore, hardcore, or no skills automatically",
		c2t_ascend_permType()),
	new c2t_ascend_field(
		"Karma",
		"The amount of karma that will not be used to perm skills and stay banked",
		)
};

boolean c2t_ascend_check(string [string] map) {
	for (int i = 0;i < c2t_ascend_data.count()-1;i++)
		if (!(c2t_ascend_data[i].data contains map[c2t_ascend_data[i].name].to_int()))
			return false;
	if (map["Karma"].to_int() < 0)
		return false;
	return true;
}
boolean c2t_ascend_check(string [int] map) {
	for (int i = 0;i < c2t_ascend_data.count()-1;i++)
		if (!(c2t_ascend_data[i].data contains map[i].to_int()))
			return false;
	if (map[c2t_ascend_data.count()-1].to_int() < 0)
		return false;
	return true;
}
boolean c2t_ascend_check(string s) {
	return c2t_ascend_check(s.split_string(","));
}
boolean c2t_ascend_check() {
	return c2t_ascend_check(get_property("c2t_ascend"));
}

string [string] c2t_ascend_getSettings() {
	string [string] out;
	if (!c2t_ascend_check())
		abort("c2t_ascend: property set up incorrectly; configure in the relay script to fix");
	string [int] spli = split_string(get_property("c2t_ascend"),",");
	foreach i,x in c2t_ascend_data
		out[x.name] = spli[i];
	return out;
}

boolean c2t_ascend_setSettings(string [string] map) {
	if (!c2t_ascend_check(map))
		return false;
	string temp = "";
	foreach i,x in c2t_ascend_data
		temp += temp == ""?map[x.name]:`,{map[x.name]}`;
	set_property("c2t_ascend",temp);
	return true;
}
boolean c2t_ascend_setSettings(string [int] map) {
	if (!c2t_ascend_check(map))
		return false;
	string temp;
	foreach i,x in map
		temp += (i == 0?x:`,{x}`);
	set_property("c2t_ascend",temp);
	return true;
}

void main() {
	string [string] a = c2t_ascend_getSettings();
	int permMult = a["Perm"].to_int();
	string permAll = permMult == 1?"sc":permMult == 2?"hc":"";
	int thresh = a["Karma"].to_int();

	if (get_property("kingLiberated").to_boolean()) {
		print("c2t_ascend: attempting to enter valhalla");

		//get to ascend button
		if (get_property("csServicesPerformed") != "")
			visit_url("ascend.php?alttext=communityservice",false,true);
		else
			visit_url("ascend.php",false,true);

		//press ascend button
		//TODO log and decline trade offers
		if (visit_url("ascend.php?pwd&action=ascend&confirm=on&confirm2=on",true,true)
			.contains_text("You may not ascend while you have pending trade offers."))
		{
			abort("c2t_ascend: trade offers are pending; cannot ascend until those are dealt with");
		}
	}

	if (!visit_url("charpane.php").contains_text("Astral Spirit"))
		abort("c2t_ascend: failed to get to valhalla");

	//visit_url("afterlife.php?realworld=1",false,true);
	visit_url("afterlife.php?action=pearlygates",false,true);

	//buy things
	if (a["Deli"].to_int() > 0)
		visit_url(`afterlife.php?action=buydeli&whichitem={a["Deli"]}`,true,true);
	if (a["Pet"].to_int() > 0)
		visit_url(`afterlife.php?action=buyarmory&whichitem={a["Pet"]}`,true,true);

	//hc perm all the skills; assumes enough karma to cover costs
	if (permAll == "hc" || permAll == "sc") {
		buffer buf = visit_url("afterlife.php?place=permery",false,true);
		string [int] hcsc = xpath(buf,'//form[@action="afterlife.php"]//input[@name="action"]/@value');
		string [int] skil = xpath(buf,'//form[@action="afterlife.php"]//input[@name="whichskill"]/@value');
		int size = skil.count();
		if (size > 0) {
			print(`Perming all {permAll.to_upper_case()} skills:`,"blue");
			for i from 0 to size-1 {
				if (get_property("bankedKarma").to_int() - 100 * permMult < thresh) {
					print("c2t_ascend: perming another skill would put karma below the threshold, so stopping");
					break;
				}
				if (hcsc[i] == `{permAll}perm`)
					visit_url(`afterlife.php?action={hcsc[i]}&whichskill={skil[i]}`,true,true);
			}
		}
	}

	//ascend
	visit_url(`afterlife.php?pwd&action=ascend&confirmascend=1&whichsign={a["Moon"]}&gender={a["Gender"]}&whichclass={a["Class"]}&whichpath={a["Path"]}&asctype={a["Type"]}&nopetok=1&noskillsok=1&lamesignok=1&lamepatok=1`,true,true);
}

