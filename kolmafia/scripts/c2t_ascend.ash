//c2t ascend
//c2t


void main() {
	int deli = $item[astral six-pack].to_int();
	//int pet = $item[astral pet sweater].to_int();
	int pet = $item[none].to_int();
	int type = 2;//normal difficulty
	int pathId = $path[community service].id;
	int moonId = 3;//vole
	int classId = $class[accordion thief].to_int();
	string permAll = "hc";//"hc" or "sc" for perming hc or sc; "" to skip

	if (get_property("kingLiberated").to_boolean()) {
		//not sure if visit_url() will bypass pre-ascension script, so just run it
		cli_execute("c2t_pre-ascension.ash");

		//get to ascend button
		if (get_property("csServicesPerformed") != "")
			visit_url("ascend.php?alttext=communityservice",false,true);
		else
			visit_url("ascend.php",false,true);

		print("c2t_ascend: attempting to enter valhalla");

		//press ascend button
		//TODO log and decline trade offers
		if (visit_url("ascend.php?pwd&action=ascend&confirm=on&confirm2=on",true,true)
			.contains_text("You may not ascend while you have pending trade offers."))
		{
			abort("trade offers are pending");
		}
	}

	if (!visit_url("charpane.php").contains_text("Astral Spirit"))
		abort("c2t_ascend: failed to get to valhalla");

	//visit_url("afterlife.php?realworld=1",false,true);
	visit_url("afterlife.php?action=pearlygates",false,true);

	//hc perm all the skills; assumes enough karma to cover costs
	if (permAll == "hc" || permAll == "sc") {
		buffer buf = visit_url("afterlife.php?place=permery");
		string [int] hcsc = xpath(buf,'//form[@action="afterlife.php"]//input[@name="action"]/@value');
		string [int] skil = xpath(buf,'//form[@action="afterlife.php"]//input[@name="whichskill"]/@value');
		int size = skil.count();
		if (size > 0) {
			print(`Perming all {permAll.to_upper_case()} skills:`,"blue");
			for i from 0 to size-1
				if (hcsc[i] == `{permAll}perm`)
					visit_url(`afterlife.php?action={hcsc[i]}&whichskill={skil[i]}`,true,true);
		}
	}

	//buy things
	if (deli > 0)
		visit_url(`afterlife.php?action=buydeli&whichitem={deli}`,true,true);
	if (pet > 0)
		visit_url(`afterlife.php?action=buyarmory&whichitem={pet}`,true,true);
	//ascend
	visit_url(`afterlife.php?pwd&action=ascend&confirmascend=1&whichsign={moonId}&gender=2&whichclass={classId}&whichpath={pathId}&asctype={type}&nopetok=1&noskillsok=1&lamesignok=1&lamepatok=1`,true,true);
}

