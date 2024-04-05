//c2t ascend
//c2t

//automates entering and leaving valhalla, as well as choosing options within

boolean c2t_ascend_CLI = false;

//record for the data
record c2t_ascend_field {
	string name;
	string desc;
	string [int] data;
};

//check input
boolean c2t_ascend_check();
boolean c2t_ascend_check(string s);
boolean c2t_ascend_check(string [int] map);
boolean c2t_ascend_check(int [string] map);

//get/set settings
int [string] c2t_ascend_getSettings();
boolean c2t_ascend_setSettings(int [string] map);

//all the maps
string [int] c2t_ascend_type();
string [int] c2t_ascend_class();
string [int] c2t_ascend_gender();
string [int] c2t_ascend_path();
string [int] c2t_ascend_moon();
string [int] c2t_ascend_deli();
string [int] c2t_ascend_pet();
string [int] c2t_ascend_perm();

//skill perm blocklist
boolean [string] c2t_ascend_blocklist();

//data
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
		"Path to tread; make sure to pick a valid class for this as well",
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
		c2t_ascend_perm()),
	new c2t_ascend_field(
		"Karma",
		"The amount of karma that will not be used to perm skills and stay banked",
		)
};

//handles errors with aborting if done via CLI or returning false otherwise
boolean c2t_ascend_error(string s);

//for importing
//returns true if successfully navigated valhalla
boolean c2t_ascend();

//for the CLI
void main() {
	c2t_ascend_CLI = true;
	c2t_ascend();
}

boolean c2t_ascend() {
	int [string] a = c2t_ascend_getSettings();
	int multi = a["Perm"];
	string perm = multi == 1?"sc":multi == 2?"hc":"";
	int threshold = a["Karma"];
	buffer buf;

	print("c2t_ascend: attempting to enter Valhalla");

	//get to ascend button
	if (get_property("csServicesPerformed") != "")
		buf = visit_url("ascend.php?alttext=communityservice",false,true);
	else
		buf = visit_url("ascend.php",false,true);

	//result is empty
	if (buf == "".to_buffer())
		return c2t_ascend_error("The ascend page is empty. Did you free the king yet?");

	//ascending too soon
	if (buf.contains_text("You may not enter the Astral Gash again until tomorrow."))
		return c2t_ascend_error("You may not enter the Astral Gash again until tomorrow.");

	//check if already in Valhalla, and get there if not
	if (!buf.contains_text("<b>Beyond the Pale</b>")) {
		//press ascend button
		buf = visit_url("ascend.php?pwd&action=ascend&confirm=on&confirm2=on",true,true);

		//trade offers
		if (buf.contains_text("You may not ascend while you have pending trade offers."))
			return c2t_ascend_error("You may not ascend while you have pending trade offers.");

		//are we there yet?
		if (!buf.contains_text("<b>Beyond the Pale</b>"))
			return c2t_ascend_error("failed to enter Valhalla");
	}

	//click link and enter
	if (buf.contains_text("afterlife.php?action=pearlygates"))
		visit_url("afterlife.php?action=pearlygates",false,true);

	//buy things
	if (a["Deli"] > 0)
		visit_url(`afterlife.php?action=buydeli&whichitem={a["Deli"]}`,true,true);
	if (a["Pet"] > 0)
		visit_url(`afterlife.php?action=buyarmory&whichitem={a["Pet"]}`,true,true);

	//perm skills
	if (multi > 0) {
		buf = visit_url("afterlife.php?place=permery",false,true);
		string [int] hcsc = xpath(buf,'//form[@action="afterlife.php"]//input[@name="action"]/@value');
		string [int] skil = xpath(buf,'//form[@action="afterlife.php"]//input[@name="whichskill"]/@value');
		string [int] button = xpath(buf,'//form[@action="afterlife.php"]//input[@type="submit"]/@value');
		matcher m;
		int cost;

		int size = skil.count();
		boolean [string] blocklist = c2t_ascend_blocklist();
		if (size > 0) {
			print(`c2t_ascend: perming all {c2t_ascend_data[7].data[multi]} skills`);
			for i from 0 to size-1 {
				m = create_matcher('Permanent\\s+\\((\\d+)\\s+Karma\\)',button[i]);
				m.find();
				cost = m.group(1).to_int();

				if (get_property("bankedKarma").to_int() - cost < threshold) {
					print(`c2t_ascend: perming another skill would put karma below the threshold of {threshold}, so stopping`);
					break;
				}
				if (hcsc[i] == `{perm}perm`
					&& !(blocklist contains skil[i]))
				{
					visit_url(`afterlife.php?action={hcsc[i]}&whichskill={skil[i]}`,true,true);
				}
			}
		}
	}

	print("c2t_ascend: leaving Valhalla");

	//ascend
	buf = visit_url(`afterlife.php?pwd&action=ascend&confirmascend=1&whichsign={a["Moon"]}&gender={a["Gender"]}&whichclass={a["Class"]}&whichpath={a["Path"]}&asctype={a["Type"]}&nopetok=1&noskillsok=1&lamesignok=1&lamepatok=1`,true,true);

	//check if still in Valhalla
	if (buf.contains_text("<p>&quot;Okay, kid, lemme see if I've got this straight:"))
		return c2t_ascend_error("still stuck in Valhalla");

	return true;
}

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

string [int] c2t_ascend_perm() {
	string [int] out = {
		0:"none",
		1:"softcore",
		2:"hardcore"
		};
	return out;
}

boolean c2t_ascend_check() {
	return c2t_ascend_check(get_property("c2t_ascend"));
}
boolean c2t_ascend_check(string s) {
	return c2t_ascend_check(s.split_string(","));
}
boolean c2t_ascend_check(string [int] map) {
	for (int i = 0;i < c2t_ascend_data.count()-1;i++)
		if (!(c2t_ascend_data[i].data contains map[i].to_int()))
			return false;
	return true;
}
boolean c2t_ascend_check(int [string] map) {
	for (int i = 0;i < c2t_ascend_data.count()-1;i++)
		if (!(c2t_ascend_data[i].data contains map[c2t_ascend_data[i].name]))
			return false;
	return true;
}

int [string] c2t_ascend_getSettings() {
	int [string] out;
	if (!c2t_ascend_check())
		abort("c2t_ascend: property set up incorrectly; configure in the relay script to fix");
	string [int] spli = split_string(get_property("c2t_ascend"),",");
	foreach i,x in c2t_ascend_data
		out[x.name] = spli[i].to_int();
	return out;
}

boolean c2t_ascend_setSettings(int [string] map) {
	if (!c2t_ascend_check(map))
		return false;
	string temp = "";
	foreach i,x in c2t_ascend_data
		temp += temp == ""?`{map[x.name]}`:`,{map[x.name]}`;
	set_property("c2t_ascend",temp);
	return true;
}

boolean [string] c2t_ascend_blocklist() {
	boolean [string] out;
	if (!get_property("c2t_ascend_useBlocklist").to_boolean())
		return out;

	foreach x in $skills[
		seal clubbing frenzy,
		clobber,
		patience of the tortoise,
		toss,
		manicotti meditation,
		spaghetti spear,
		sauce contemplation,
		salsaball,
		disco aerobics,
		suckerpunch,
		moxie of the mariachi,
		sing,
		cleesh,
		mild curse
		]
	{
		out[x.id.to_string()] = true;
	}
	return out;
}

boolean c2t_ascend_error(string s) {
	string out = `c2t_ascend: {s}`;
	if (c2t_ascend_CLI)
		abort(out);
	print(out,"red");
	return false;
}

