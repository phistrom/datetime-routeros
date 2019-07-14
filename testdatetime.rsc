# This script is for testing the datetime.rsc script for correctness during development.
# WARNING: This script will make changes to your device's clock.
# Probably best not to run this on production equipment.

/system ntp client set enabled=no

:global datetime
:local time [$datetime]
:local fails 0

:put "Right now..."
:put $time

# DOW Test 1

:put "December 13, 1987 should be a Sunday"
/system clock set date=dec/13/1987 time=13:00:00
:set time [$datetime]
:put $time

:if ( (($time->"w") = 0) && (($time->"A") = "Sunday") ) do={
    :put "PASS"
} else={
    :put ("FAIL. Expected Sunday but got " . ($time->"A") . " instead.")
    :set fails ($fails + 1)
}

:put "October 1, 2020 should be a Thursday"
/system clock set date=oct/1/2020
:set time [$datetime]
:put $time

:if ( (($time->"w") = 4) && (($time->"A") = "Thursday") ) do={
    :put "PASS"
} else={
    :put ("FAIL. Expected Thursday but got " . ($time->"A") . " instead.")
    :set fails ($fails + 1)
}

:put "Feb 29, 2036 should be a Friday"
/system clock set date=feb/29/2036
:set time [$datetime]
:put $time

:if ( (($time->"w") = 5) && (($time->"A") = "Friday") ) do={
    :put "PASS"
} else={
    :put ("FAIL. Expected Friday but got " . ($time->"A") . " instead.")
    :set fails ($fails + 1)
}

:for i from=1 to=30 do={
    /system clock set date="jun/$i/2020"
    :set $time [$datetime]
    :put $time
    :if ( (($time->"w") = ($i % 7))) do={
        :put "PASS"
    } else={
        :put ("FAIL. Expected " . ($i % 7) . " but got " . ($time->"w") . " instead.")
        :set fails ($fails + 1)
    }
}

:for i from=1 to=30 do={
    /system clock set date="jan/$i/1990"
    :set $time [$datetime]
    :put $time
    :if ( (($time->"w") = ($i % 7))) do={
        :put "PASS"
    } else={
        :put ("FAIL. Expected " . ($i % 7) . " but got " . ($time->"w") . " instead.")
        :set fails ($fails + 1)
    }
}

# TIMEZONE TEST
:local previousTZ [/system clock get time-zone-name]

:do {
    :local offset
    :local comp
    /system clock set date=jul/1/2010
    :local zones {"Asia/Manila";"Australia/Adelaide";"America/El_Salvador"}
    :local offsets {"+0800";"+0930";"-0600"}
    

    :for i from=0 to=([:len $zones] - 1) do={
        :put ($zones->$i)
        /system clock set time-zone-name=($zones->$i)
        :set time [$datetime]
        :put $time
        :set offset ($time->"z")
        :set comp ($offsets->$i)
        :if ("$offset" = "$comp") do={
            :put "PASS"
        } else={
            :put $offset
            :put ("FAIL. Expected $comp but got $offset instead.")
            :set fails ($fails + 1)
        }
    }
} on-error={
    :put $previousTZ
    /system clock set time-zone-name=$previousTZ
}

:put $previousTZ
/system clock set time-zone-name=$previousTZ

/system ntp client set enabled=yes

:if ($fails = 0) do={
    :put "All tests passed"
} else={
    :put "Failed $fails test(s)."
}
