# c2t_ascend

Kolmafia script written in ASH to automate valhalla, to include entering valhalla, buying astral items, perming skills, and leaving valhalla.

## Usage

* All configuration is done via the relay script.
* When you want to jump the gash and go through valhalla, run `c2t_ascend.ash` on the CLI.
* There are no checks for combinations of values that may not be valid server input, so don't choose things you don't have access to, or try to enter an Ed run as a Seal Clubber as an example. I have no idea what will happen.
* It is suggested to have a pre-ascension script of some sort set to run on ascension that checks to make sure you are in a state you want to be in for ascension, so, for example, you don't accidentally just blow through valhalla without running any turns for the day.
* The auto-perm skills in valhalla feature will perm skills from the top of the list down without regard with how good or useful a skill is, so if that is not a behavior you want, just set the `Karma` setting to something much higher than your banked karma to not buy skills.

## Installation / Removal

To install, run the following on the kolmafia CLI:

`git checkout https://github.com/C2Talon/c2t_ascend.git master`

To remove, run the following:

`git remove C2Talon-c2t_ascend-master`

