//c2t ascend relay
//c2t

//relay script for c2t_ascend settings

import <c2t_ascend.ash>

string [string] POST = form_fields();
boolean postError = false;

void c2t_ascend_writeText(string tag,string s);
void c2t_ascend_writeInput(string name,string value,string desc,int size,int max);
void c2t_ascend_writeSelect(string name,string desc,string [int] options,int value);
void c2t_ascend_writeFailSuccess();
void c2t_ascend_writeTh(string a, string b, string c);

void main() {
	int [string] settings;

	//handle things submitted
	if (POST.count() > 1) {
		foreach i,x in c2t_ascend_data
			settings[x.name] = POST[x.name].to_int();
		if (!c2t_ascend_check(settings))
			postError = true;
		if (!postError)
			c2t_ascend_setSettings(settings);
	}
	else if (c2t_ascend_check())
		settings = c2t_ascend_getSettings();
	else
		foreach i,x in c2t_ascend_data
			settings[x.name] = 0;

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
	foreach i,x in c2t_ascend_data {
		if (x.name == "Karma")
			c2t_ascend_writeInput(x.name,settings[x.name],x.desc,10,10);
		else
			c2t_ascend_writeSelect(x.name,x.desc,x.data,settings[x.name]);
	}
	write("</tbody></table>");

	//submit
	write('<input type="submit" value="save changes" class="submit" />');
	c2t_ascend_writeFailSuccess();
	write("</form>");

	//footer
	write("</body></html>");
}

void c2t_ascend_writeText(string tag,string s) {
	write(`<{tag}>{s}</{tag.split_string(" ")[0]}>`);
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

