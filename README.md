# Datetime for RouterOS
This is a script that creates a global function called `datetime`. You can use the function to get the current day of the week, the month as an integer, the timezone offset, and much more. It's all the basic date components you expect from most programming languages.

Once the variable has been created, you can call it from the command line like `:put [$datetime]`. See below for an example of a script that can use the function.

## Install
The create-datetime-function script only needs to run once per boot. You can make a scheduled task that runs this script at startup to make sure the `$datetime` global function is always available to you.

## Example Script
```
# make this script aware of the global variable named "datetime"
:global datetime

# assign this instant into a variable. All follow-up calls to $currentTime will be from this point in time.
:local currentTime [$datetime]

# get the day of the week as a number (0 is Sunday, 1 is Monday, ..., 6 is Saturday)
:put ($currentTime->"w")

# get the day of the week as a string ("Sunday", "Monday", ... "Saturday")
:put ($currentTime->"A")

# get the current month as a 0-padded 2-digit integer (01 for January, 02 for February, ... 12 for December)
:put ($currentTime->"m")

# get the current hour on a 12-hour clock (1am = 01, 5am = 05, 12pm = 12, 5pm = 05)
:put ($currentTime->"I")

# get either "am" or "pm" as a string
:put ($currentTime->"p")

# get the "seconds" component of the clock right now
:put ([$datetime]->"S")
```

## Reference
The variable names are taken from strftime/strptime function in C, Python, and PHP. Here is what is currently implemented:
  * **w** day of the week as an integer (Sunday=**0**, Monday=**1**, Saturday=**6**)
  * **A** full day of the week name (**Sunday**, **Monday**, **Saturday**)
  * **a** abbreviated day of the week name (**Sun**, **Mon**, **Sat**)
  * **b** abbreviated month name (**jan**, **feb**, **dec**)
  * **Y** 4-digit year (**1990**, **2000**, **2019**)
  * **y** 2-digit year (**90**, **00**, **19**)
  * **m** 2-digit, zero-padded month (jan=**01**, feb=**02**, dec=**12**)
  * **d** 2-digit, zero-padded day (**01**, **02**, **29**, **31**)
  * **H** current hour as a 2-digit, zero-padded, 24-hour integer (2am=**02**, 2pm=**14**, 5pm=**17**)
  * **I** current hour as a 2-digit, zero-padded, 12-hour integer (2am=**02**, 2pm=**02**, 5pm=**05**)
  * **M** current minutes as a 2-digit, zero-padded integer (**00**, **24**, **50**)
  * **S** current seconds as a 2-digit, zero-padded integer (**00**, **30**, **59**)
  * **ymd** a convenient date string in the format "YYYY-mm-dd", great for filenames
  * **Z** time zone name (**America/Chicago**, **Asia/Manila**, **Australia/Adelaide**)
  * **z** timezone offset from UTC in the format of +HHMM or -HHMM (**-0500**, **+0800**, **+0930**)
  * **p** "am" or "pm" depending on morning or evening (**am**, **pm**)
  * **time** the normal time output you get from [/system clock get time] (**HH:MM:SS**)
  * **date** the normal date output you get from [/system clock get date] (**mmm/dd/yyyy**)
  