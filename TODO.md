# TODO

* documentation
  * add lots of docs ;)
  * explain __dispatch(), __main() and __init() functions (and alternative usage of bashinator without them)
    * also explain __prepare() and __cleanup() functions

* new features
  * implement more basic helper functions, like ltrim/rtrim/trim
    * affects: library, examples, docs
  * implement user interaction/input handling functions, e.g. using dialog(1)
    * see also: http://mywiki.wooledge.org/BashFAQ/040
    * affects: library, examples, docs
  * implement __requireCommand() to check for required commands/programs on startup/in __boot()
    * see also: http://www.bash-hackers.org/wiki/doku.php/scripting/style#availability_of_commands
    * affects: library, examples, docs

* improvements and fixes
  * improve FHS compliance: move bashinator library from /usr/lib to /usr/share
    * affects: examples, docs
  * locale: add LC_*=C to relevant lines to ensure calculations are done correctly (e.g. with . instead of ,)
    * affects: library
  * colors: convert ANSI sequences to tput
    * see also: http://wiki.bash-hackers.org/scripting/terminalcodes#colors_using_tput
    * affects: library
  * lockfile handling: make locking atomic
    * see also: http://mywiki.wooledge.org/BashFAQ/040
    * affects: library
