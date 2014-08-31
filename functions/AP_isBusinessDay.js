function testIsBusinessDay(){
    // tests the function isBusinessDay(aDate As Date)
    // sends a date
    // returns true or false for the question "is this a business day"

    var aDate = new Date(); // This is today's date
    //var aDate = new Date(aYear, aMonth, aDay) //alter this to check other dates
    alert("Sending #" + aDate + "# to isBusinessDay() returns:\t" + isBusinessDay(aDate));
}

function isBusinessDay(aDate){
    // check if input is a business day
    // return true/false

    if     (isWeekend(aDate)                 === true){return false}
    else if(isNewYearsDay(aDate)             === true){return false}
    else if(isBusinessNewYearsDay(aDate)     === true){return false}
    else if(isGoodFriday(aDate)              === true){return false}
    else if(isMemorialDay(aDate)             === true){return false}
    else if(isIndependenceDay(aDate)         === true){return false}
    else if(isBusinessIndependenceDay(aDate) === true){return false}
    else if(isLaborDay(aDate)                === true){return false}
    else if(isThanksgivingDay(aDate)         === true){return false}
    else if(isDayAfterThanksgiving(aDate)    === true){return false}
    else if(isChristmasEve(aDate)            === true){return false}
    else if(isBusinessChristmasEve(aDate)    === true){return false}
    else if(isChristmasDay(aDate)            === true){return false}
    else if(isBusinessChristmasDay(aDate)    === true){return false}
    else                                              {return true};
}

function isWeekend(aDate){
    // check if input date is saturday or sunday
    // return true/false

    if(                     // if
        aDate.getDay() == 0 // the input day is sunday
        ||                  // or
        aDate.getDay() == 6 // the input day is saturday
    ){                      // then
        return true         // it is a weekend day
    }else{                  // otherwise
        return false        // it is not a weekend day
    };
}

function isNewYearsDay(aDate){
    // check if input date is new years day
    // return true/false

    if(                       // if
        aDate.getDate() == 1  // the input day is the first
        &&                    // and
        aDate.getMonth() == 0 // the input month is January
    ){                        // then
        return true           // it is new years day
    }else{                    // otherwise
        return false          // it is not new years day
    };
}

function isBusinessNewYearsDay(aDate){
    // check if input date is new years day
    //   or if it's the nearest weekday when
    //   new years is on a weekend
    //
    // return true/false

    // need to know yesterdays and tomorrows dates
    var yesterdayDate = new Date(aDate);
        yesterdayDate.setDate(yesterdayDate.getDate()-1);
    var tomorrowDate = new Date(aDate);
        tomorrowDate.setDate(tomorrowDate.getDate()+1);

    if(                                 // if
        aDate.getDay() == 1             // today is monday
        &&                              // and
        yesterdayDate.getDate() == 1    // yesterday was the first of the month
        &&                              // and
        yesterdayDate.getMonth() == 0   // yesterday's month was january
       ){ return true }                 // then this is the monday new years rolls onto
    else if(                            // otherwise, if
        aDate.getDay() == 5             // today is friday
        &&                              // and
        tomorrowDate.getDate() == 1     // tommorrow is the first of the month
        &&                              // and
        tomorrowDate.getMonth() == 0    // tomorrow's month is january
       ){ return true }                 // then this is the friday new years rolls onto
    else if (                           // otherwise, if
        aDate.getDate() == 1            // the input day is the first
        &&                              // and
        aDate.getMonth() == 0           // the input month is January
       ){ return true }                 // then it is new years day
    else{                               // otherwise
        return false                    // it is not new years day or a roll over day
    }
}

function isGoodFriday(aDate){
    // check if input date is good friday
    // return true/false

    // easter is two days after good friday
    //   need the date strings to compare later
    var twoDaysLater = new Date(aDate);
    twoDaysLater.setDate(twoDaysLater.getDate()+2);
    var easterDate = new Date();
    easterDate = easterIn(aDate.getFullYear());
    var twoDaysLaterString = (twoDaysLater.getMonth()+1) + "/" + twoDaysLater.getDate() + "/" + twoDaysLater.getFullYear();
    var easterDateString = (easterDate.getMonth()+1) + "/" + easterDate.getDate() + "/" + easterDate.getFullYear();
    delete twoDaysLater;
    delete easterDate;

    if(                                      // if
          twoDaysLaterString                 // the date two days after the input date
          ==                                 // is
          easterDateString                   // easter of that year
    ){                                       // then
        return true                          // it is good friday
    }else{                                   // otherwise
        return false                         // it is not good friday
    };
}

function easterIn(aYear){
    // determines day of easter in aYear
    // returns a date object
    //
    // credit: http://en.wikipedia.org/wiki/Computus#Software
    //         http://stackoverflow.com/questions/1284314/easter-date-in-javascript
    //         http://www.ptb.de/cms/en/fachabteilungen/abt4/fb-44/ag-441/realisation-of-legal-time-in-germany/the-date-of-easter.html
    // modified from the javascript sample code at wikipedia

    var moonShift;
    var daysToSpringMoon;
    var moonCycleCorrection;
    var dateOfFullMoon;
    var firstMarchSundayDate;
    var easterOffset;

    // Secular Moon shift
    moonShift =
        15
        + Math.floor(
            (3 * Math.floor(aYear / 100) + 3) / 4
          )
        - Math.floor(
            (8 * Math.floor(aYear / 100) + 13) / 25
          );

    // Seed for 1st full Moon in spring
    daysToSpringMoon  = (19 * (aYear % 19) + moonShift) % 30;

    // Calendarian correction quantity
    moonCycleCorrection  =
        Math.floor(daysToSpringMoon / 29)
        + (
            Math.floor(daysToSpringMoon / 28)
            - Math.floor(daysToSpringMoon / 29)
          )
        * Math.floor((aYear % 19) / 11);

    // Easter limit; the day of the first Paschal full moon in Spring (as a date in March)
    //   Paschal full moon is not the same as the real full moon
    //   Easter has to be after this date (if it is on sunday, then easter is the following sunday).
    //   if the date is larger than the days in march, then later calculations roll it over to April
    dateOfFullMoon = 21 + daysToSpringMoon - moonCycleCorrection;

    // get first sunday in march
    //   there are some 'pure math' ways to get this, but this is easier to follow
    var firstSundayInMarch = new Date(aYear,2,1);        // starting with march 1st
    for (var i=1;i<8;i++){                               // for the first week of march
        firstSundayInMarch.setDate(i);                   // check each day
        if(firstSundayInMarch.getDay() == 0){            // until you find sunday
            i = 8;                                       // then get out of the loop
        }
    }
    firstMarchSundayDate = firstSundayInMarch.getDate(); // save the date
    delete firstSundayInMarch;                           // discard the extra date object

    // Distance Easter sunday from Easter limit in days
    easterOffset = 6 - (dateOfFullMoon - firstMarchSundayDate) % 7;

    // Find Easter
    var easterDate = new Date(aYear, 2, 1);                    // first day of march
    easterDate.setDate(easterDate.getDate() + dateOfFullMoon); // add earliest date easter could be
    easterDate.setDate(easterDate.getDate() + easterOffset);   // add days after full moon to get easter
    easterDate.setDate(easterDate.getDate())                   // previous day

    // return date object
    return easterDate;

}

function isMemorialDay(aDate){
    // check if input date is memorial day
    // return true/false
    // final monday of May

    var aWeekLater = new Date(aDate);
    aWeekLater.setDate(aWeekLater.getDate() + 7);
    if(                            // if
        aDate.getMonth() == 4      // the input month is may
        &&                         // and
        aDate.getDay() == 1        // the input day is monday
        &&                         // and
        aWeekLater.getMonth() == 5 // a week from the input day is in the next month
    ){                             // then
        return true                // it is memorial day
    }else{                         // otherwise
        return false               // it is not memorial day
    };

}

function isIndependenceDay(aDate){
    // check if input date is independence day
    // return true/false

    if(                       // if
        aDate.getDate() == 4  // the input day is the fourth
        &&                    // and
        aDate.getMonth() == 6 // the input month is July
    ){                        // then
        return true           // it is independence day
    }else{                    // otherwise
        return false          // it is not independence day
    };

}

function isBusinessIndependenceDay(aDate){
    // check if input date is independence day
    //   or if it's the nearest weekday when
    //   independence day is on a weekend
    //
    // return true/false

    // need to know yesterdays and tomorrows dates
    var yesterdayDate = new Date(aDate);
        yesterdayDate.setDate(yesterdayDate.getDate()-1);
    var tomorrowDate = new Date(aDate);
        tomorrowDate.setDate(tomorrowDate.getDate()+1);

    if(                                 // if
        aDate.getDay() == 1             // today is monday
        &&                              // and
        yesterdayDate.getDate() == 4    // yesterday was the 4th of the month
        &&                              // and
        yesterdayDate.getMonth() == 6   // yesterday's month was july
       ){ return true }                 // then this is the monday independence day rolls onto
    else if(                            // otherwise, if
        aDate.getDay() == 5             // today is friday
        &&                              // and
        tomorrowDate.getDate() == 4     // tommorrow is the 4th of the month
        &&                              // and
        tomorrowDate.getMonth() == 6    // tomorrow's month is july
       ){ return true }                 // then this is the friday independence day rolls onto
    else if (                           // otherwise, if
        aDate.getDate() == 4            // the input day is the 4th
        &&                              // and
        aDate.getMonth() == 6           // the input month is July
       ){ return true }                 // then it is independence day
    else{                               // otherwise
        return false                    // it is not independence day or a roll over day
    }
}

function isLaborDay(aDate){
    // check if input date is labor day
    // return true/false

    if(                        // if
        aDate.getMonth() == 8  // the input month is September
        &&                     // and
        aDate.getDay() == 1    // the input day is monday
        &&                     // and
        Math.ceil(             //
          aDate.getDate()/7    // the day of the week
          ) == 1               // is the 1st of it's kind in the month
    ){                         // then
        return true            // it is labor day
    }else{                     // otherwise
        return false           // it is not labor day
    };

}

function isThanksgivingDay(aDate){
    // check if input date is thanksgiving
    // return true/false

    if(                        // if
        aDate.getMonth() == 10 // the input month is november
        &&                     // and
        aDate.getDay() == 4    // the input day is thursday
        &&                     // and
        Math.ceil(             //
          aDate.getDate()/7    // the day of the week
          ) == 4               // is the 4th of it's kind in the month
    ){                         // then
        return true            // it is thanksgiving day
    }else{                     // otherwise
        return false           // it is not thanksgiving day
    };

}

function isDayAfterThanksgiving(aDate){
    // check if input date is the day after thanksgiving
    // return true/false

    var previousDay = new Date(aDate -1);
    if(                          // if
        isThanksgivingDay(       // thanksgiving day
          previousDay            // is the day before
        ) == true                // the input day
    ){                           // then
        return true              // it is the day after thanksgiving
    }else{                       // otherwise
        return false             // it is not the day after thanksgiving
    };

}

function isChristmasEve(aDate){
    // check if input date is the day before christmas
    // return true/false

    if(                        // if
        aDate.getDate() == 24  // the input day is the 24th
        &&                     // and
        aDate.getMonth() == 11 // the input month is December
    ){                         // then
        return true            // it is christmas eve
    }else{                     // otherwise
        return false           // it is not christmas eve
    };

}

function isBusinessChristmasEve(aDate){
    // check if input date is christmas eve
    //   or if it's the nearest weekday when
    //   christmas eve is on a weekend
    //
    // return true/false

    // need to know the next two days dates
    var tomorrowDate = new Date(aDate);
        tomorrowDate.setDate(tomorrowDate.getDate()+1);
    var dayAfterTomorrowDate = new Date(aDate);
        dayAfterTomorrowDate.setDate(dayAfterTomorrowDate.getDate()+2);

    if(                                         // if
        aDate.getDay() == 5                     // today is friday
        &&                                      // and
        (                                       // either
        (tomorrowDate.getDate() == 24           //   tommorrow is the 24th of the month
        &&                                      //   and
        tomorrowDate.getMonth() == 11)          //   tomorrow's month is december
        ||                                      // or
        (dayAfterTomorrowDate.getDate() == 24   //   the day after tommorrow is the 24th of the month
        &&                                      //   and
        dayAfterTomorrowDate.getMonth() == 11)  //   the day after tomorrow's month is december
        )                                       //
       ){ return true }                         // then this is the friday christmas eve rolls onto
    else if (                                   // otherwise, if
        aDate.getDate() == 24                   // the input day is the 24th
        &&                                      // and
        aDate.getMonth() == 11                  // the input month is december
       ){ return true }                         // then it is christmas eve
    else{                                       // otherwise
        return false                            // it is not christmas eve or a roll over day
    }
}

function isChristmasDay(aDate){
    // check if input date is christmas day
    // return true/false

    if(                        // if
        aDate.getDate() == 25  // the input day is the 25th
        &&                     // and
        aDate.getMonth() == 11 // the input month is December
    ){                         // then
        return true            // it is christmas day
    }else{                     // otherwise
        return false           // it is not christmas day
    };

}

function isBusinessChristmasDay(aDate){
    // check if input date is christmas day
    //   or if it's the nearest weekday when
    //   christmas day is on a weekend
    //
    // return true/false

    // need to know the previous two days dates
    var yesterdayDate = new Date(aDate);
        yesterdayDate.setDate(yesterdayDate.getDate()-1);
    var dayBeforeYesterdayDate = new Date(aDate);
        dayBeforeYesterdayDate.setDate(dayBeforeYesterdayDate.getDate()-2);

    if(                                           // if
        aDate.getDay() == 1                       // today is monday
        &&                                        // and
        (                                         // either
          (
          yesterdayDate.getDate() == 25           //   yesterday is the 25th of the month
          &&                                      //   and
          yesterdayDate.getMonth() == 11          //   yesterday's month is december
          )
          ||                                      // or
          (
          dayBeforeYesterdayDate.getDate() == 25  //   the day before yesterday is the 25th of the month
          &&                                      //   and
          dayBeforeYesterdayDate.getMonth() == 11 //   the day before yesterday 's month is december
          )
        )                                         //
       ){ return true }                           // then this is the monday christmas day rolls onto
    else if (                                     // otherwise, if
        aDate.getDate() == 25                     // the input day is the 25th
        &&                                        // and
        aDate.getMonth() == 11                    // the input month is december
       ){ return true }                           // then it is christmas day
    else{                                         // otherwise
        return false                              // it is not christmas day or a roll over day
    }
}
