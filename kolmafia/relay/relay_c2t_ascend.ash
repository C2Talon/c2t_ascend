//c2t ascend relay
//c2t

//relay script for c2t_ascend settings

import <c2t_ascend.ash>

string [string] POST = form_fields();
boolean postError = false;

record checkbox {
	string name;
	string desc;
	string prop;
	boolean value;
};

void c2t_ascend_writeText(string tag,string s);
void c2t_ascend_writeCheckbox(checkbox thing);
void c2t_ascend_writeInput(string name,string value,string desc,int size,int max);
void c2t_ascend_writeSelect(string name,string desc,string [int] options,int value);
void c2t_ascend_writeFailSuccess();
void c2t_ascend_writeTh(string a, string b, string c);

void main() {
	int [string] settings;
	checkbox block = new checkbox("skip starter skills","skip perming free 0th-level class skills (and cleesh)","c2t_ascend_useBlocklist");
	checkbox tradeDecline = new checkbox("auto-decline trades","decline all trade offers when ascending","c2t_ascend_tradeDecline");
	checkbox tradeStore = new checkbox("store trades","if trades are declined, store a page of the trade offers in the data folder","c2t_ascend_tradeStore");
	checkbox[int] checkboxes = {
		block,
		tradeDecline,
		tradeStore,
		};

	//handle things submitted
	if (POST.count() > 1) {
		foreach i,x in c2t_ascend_data
			settings[x.name] = POST[x.name].to_int();
		foreach i,x in checkboxes
			x.value = POST[x.name] == "on" ? true : false;
		if (!c2t_ascend_check(settings))
			postError = true;
		if (!postError) {
			c2t_ascend_setSettings(settings);
			foreach i,x in checkboxes
				set_property(x.prop,x.value);
		}
	}
	else if (c2t_ascend_check()) {
		settings = c2t_ascend_getSettings();
		foreach i,x in checkboxes
			x.value = get_property(x.prop).to_boolean();
	}
	else {
		foreach i,x in c2t_ascend_data
			settings[x.name] = 0;
		foreach i,x in checkboxes
			x.value = get_property(x.prop).to_boolean();
	}

	//header
	write('<!DOCTYPE html><html lang="EN"><head><title>c2t_ascend Settings</title>');
	write("<style>p.error {color:#f00;background-color:#000;padding:10px;font-weight:bold;} p.success {color:#00f;} th {font-weight:extra-bold;padding:5px 10px 5px 10px;} thead {background-color:#000;color:#fff;} tr:nth-child(even) {background-color:#ddd;} table {border-style:solid;border-width:1px;} input.submit {margin:12pt;padding:5px;} td {padding:0 5px 0 5px;} td.right,select.right,input.right {text-align:right;} </style>");
	write("</head><body>");

	//body
	c2t_ascend_writeFailSuccess();

	c2t_ascend_writeText("h1","c2t_ascend Settings");
	c2t_ascend_writeText("p",'No changes will be made until the "save changes" button is used at the bottom.');

	//form
	write('<form action="" method="post">');

	//everything else
	write("<table>");
	c2t_ascend_writeTh("value","setting","description");
	write("<tbody>");
	foreach i in $ints[0,3,1,2,4,5,6,7,8] {
		c2t_ascend_field x = c2t_ascend_data[i];
		if (x.name == "Karma")
			c2t_ascend_writeInput(x.name,settings[x.name],x.desc,10,10);
		else
			c2t_ascend_writeSelect(x.name,x.desc,x.data,settings[x.name]);
	}
	foreach i,x in checkboxes
		c2t_ascend_writeCheckbox(x);
	write("</tbody></table>");

	//submit
	write('<input type="submit" value="save changes" class="submit" />');
	write("</form>");
	c2t_ascend_writeFailSuccess();

	//footer
	write("</body></html>");
}

void c2t_ascend_writeText(string tag,string s) {
	write(`<{tag}>{s}</{tag.split_string(" ")[0]}>`);
}

void c2t_ascend_writeCheckbox(checkbox thing) {
	string check = thing.value ? ' checked="checked"' : '';
	write(`<tr><td class="right"><input type="checkbox" name="{thing.name}" id="{thing.name}"{check} /></td><td><label for="{thing.name}"><code>{thing.name}</code></label></td><td>{thing.desc}</td></tr>`);
}

void c2t_ascend_writeInput(string name,string value,string desc,int size,int max) {
	write(`<tr><td class="right"><input type="text" name="{name}" id="{name}" size="{size}" maxlength="{max}" value="{value}" class="right" /></td><td><label for="{name}"><code>{name}</code></label></td>`);
	if (desc != "")
		//should only be karma that uses this function, so add banked karma
		write(`<td>{desc}; banked karma: {get_property("bankedKarma")}</td>`);
	write("</tr>");
}

void c2t_ascend_writeSelect(string name,string desc,string [int] options,int value) {
	write(`<tr><td class="right"><select name="{name}" id="{name}" class="right">`);
	foreach i,x in options {
		write(`<option value="{i}"`);
		if (value == i)
			write(" selected");
		write(`>{x}</option>`);
	}
	write(`</select></td><td><label for="{name}"><code>{name}</code></label></td><td>{desc}</td></tr>`);
}

void c2t_ascend_writeTh(string a, string b, string c) {
	write(`<thead><tr><th>{a}</th><th>{b}</th>`);
	if (c != "")
		write(`<th>{c}</th>`);
	write("</tr></thead>");
}

void c2t_ascend_writeFailSuccess() {
	if (postError)
		c2t_ascend_writeText('p class="error"',"CHANGES NOT SAVED! Error: some values outside boundaries");
	else if (POST.count() > 1)
		c2t_ascend_writeText('p class="success"',"Changes saved!");
}

