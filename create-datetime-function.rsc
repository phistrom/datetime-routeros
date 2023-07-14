:global datetime do={

    # PART 1 - THE BASICS

    :local months {
        "jan"="01"
        "feb"="02"
        "mar"="03"
        "apr"="04"
        "may"="05"
        "jun"="06"
        "jul"="07"
        "aug"="08"
        "sep"="09"
        "oct"="10"
        "nov"="11"
        "dec"="12"
    }
	
	:local monthsN {
        "01"="jan"
        "02"="feb"
        "03"="mar"
        "04"="apr"
        "05"="may"
        "06"="jun"
        "07"="jul"
        "08"="aug"
        "09"="sep"
        "10"="oct"
        "11"="nov"
        "12"="dec"
    }
	
	

    :local dNames {"Sunday"; "Monday"; "Tuesday"; "Wednesday"; "Thursday"; "Friday"; "Saturday"}

    :local dt
    :local ti

    # this loop protects in the rare event we hit midnight between getting the date and time
    :do {
        :set dt [/system clock get date]
        :set ti [/system clock get time]
    } while=($dt != [/system clock get date])


		:local b
		:local m
		:local Y
		:local y
		:local d

    :if ([ :pick $dt 4 5 ] != "-") do={
    # Pre Ros 7.10
		:set b [:pick $dt 0 3 ]
		:set m ($months->$b)
		:set Y [:pick $dt 7 11 ]
		:set y [:pick $dt 9 11]
		:set d [:pick $dt 4 6]
		#:log warning "<=7.9 : $b - $m - $Y - $y - $d"
	} else={ 
	# Post Ros 7.10
		:set m [:pick $dt 5 7 ]
		:set b ($monthsN->$m)
		:set Y [:pick $dt 0 4]
		:set y [:pick $dt 2 4]
		:set d [:pick $dt 8 10]		
		#:log warning "7.10+ : $b - $m - $Y - $y - $d"

	}


    :local H [:pick $ti 0 2]
    # :local M [:pick $ti 3 5]
    # :local S [:pick $ti 6 8]
    # :local ymd "$Y-$m-$d"
    :local I ($H % 12)

    :if ($I = 0) do={
        :set I 12
    }

    :if ([:len $I] < 2) do={
        :set I ("0$I")
    }

    :local p
    :if ($H < 12) do={
        :set p "am"
    } else={
        :set p "pm"
    }

    # PART 2 - CREATE GMT OFFSET STRING

    :local oInt [/system clock get gmt-offset]
    :local oSign

    # GMT offset is returned as an unsigned integer containing a signed integer
    # so for negative numbers, it comes out as 4 billion instead of, say -18000
    # Additionally, the bitwise NOT operator doesn't work for numbers so we 
    # have to do this ugly thing here
    :if ($oInt > 2147483647) do={
        :set oInt (4294967296 - $oInt)
        :set oSign "-"
    } else={
        :set oSign "+"
    }

    # GMT Offset Hours
    :local oHrs ($oInt / 3600)
    # GMT Offset Minutes
    :local oMin (($oInt % 3600) / 60)

    :if ([:len $oHrs] < 2) do={
        :set oHrs ("0$oHrs")
    }

    :if ([:len $oMin] < 2) do={
        :set oMin ("0$oMin")
    }

    :local z "$oSign$oHrs$oMin"

    # PART 3 - DAY OF THE WEEK CALCULATION
    # this entire section inspired by https://cs.uwaterloo.ca/~alopez-o/math-faq/node73.html

    :local leapYear ( (($Y % 4) = 0) && ( (($Y % 100) != 0) || (($Y % 400) = 0) ) )

    :local monthKeyVal {1; 4; 4; 0; 2; 5; 0; 3; 6; 1; 4; 6}

    :local mkv ($monthKeyVal->($m-1))

    # January and February of a leap year get special treatment
    :if ( $leapYear && ( $m <= 2 ) ) do={
        :set mkv ($mkv - 1)
    }
    
    :local w ( (($y / 4) + $d) + $mkv )
    :if ($Y >= 2000) do={
        :set w ($w + 6)
    }
    :set w ((($w + $y) - 1) % 7)

    :local A ($dNames->w)
    :local a [:pick $A 0 3]

    # PART 4 - RETURN the results as an dictionary/array

    :local dtobject {
        "b"=$b
        "m"=$m
        "d"=$d
        "Y"=$Y
        "y"=$y
        "time"=$ti
        "H"=$H
        "M"=[:pick $ti 3 5]
        "S"=[:pick $ti 6 8]
        "date"=$dt
        "ymd"="$Y-$m-$d"
        "I"=$I
        "p"=$p
        "z"=$z
        "w"=$w
        "A"=$A
        "a"=$a
        "Z"=[/system clock get time-zone-name]
    }

    :return $dtobject
}
