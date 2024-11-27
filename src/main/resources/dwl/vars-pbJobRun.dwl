%dw 2.0
import * from dw::core::Strings

// Function to extract the year from the date
fun year(date) =
  (date as DateTime).year
  
fun C_value(date) =
  floor((year(date) - 1900) / 100)

// Function to extract the day of the year from the date
fun dayOfYear(date) =
  (date as DateTime).dayOfYear

// Function to extract time from DateTime as a string, remove milliseconds and timezone, and select first 6 digits
fun extractTime(date) =
  do {
    var dateTimeStr = (date as String)
    var timePart = (dateTimeStr splitBy "T")[1] // Extract the time part after 'T'
    var timeWithoutMilliseconds = (timePart splitBy "\\.")[0] // Remove milliseconds
    var timeWithoutTimezone = (timeWithoutMilliseconds splitBy "\\+")[0] // Remove timezone
    var cleanTime = (timeWithoutTimezone replace ":" with "") // Remove colons
    ---
    cleanTime[0 to 5] // Select only the first 6 characters (HHmmss)
  }

// Function to compute the Julian date and time
fun JulianDate(date) =
  {
    // Julian date calculation: full year + day of year padded to 3 digits
    date: C_value(date) ++(year(date) as String)[2 to 3] ++ leftPad(dayOfYear(date), 3, "0"),
    
    // Julian time calculation: extract and format time
    time: extractTime(date)
  }

// Main output as JSON
output application/json  
---
JulianDate(now() as DateTime >> "EST")
