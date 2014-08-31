Sub TestIsBusinessDay()
    ' tests the function isBusinessDay(aDate As Date)
    ' sends a date
    ' returns true or false for the question "is this a business day"
    Dim someValue As Date
    someValue = Date ' This is today's date
    'someValue = "1/1/2013" ' alter this to check other dates
    Dim testValue As Boolean

    ' note, there is no check here to see if the value you hand in is a valid date.
    testValue = isBusinessDay(someValue)
    MsgBox testValue, vbOKOnly

End Sub

Function isBusinessDay(aDate As Date) As Boolean
    ' check if input is a business day
    ' recieves a date to check
    ' return true/false

    If isWeekend(aDate) = True Then
        isBusinessDay = False
    ElseIf isNewYearsDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isBusinessNewYearsDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isGoodFriday(aDate) = True Then
        isBusinessDay = False
    ElseIf isMemorialDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isIndependenceDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isBusinessIndependenceDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isLaborDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isThanksgivingDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isDayAfterThanksgiving(aDate) = True Then
        isBusinessDay = False
    ElseIf isChristmasEve(aDate) = True Then
        isBusinessDay = False
    ElseIf isBusinessChristmasEve(aDate) = True Then
        isBusinessDay = False
    ElseIf isChristmasDay(aDate) = True Then
        isBusinessDay = False
    ElseIf isBusinessChristmasDay(aDate) = True Then
        isBusinessDay = False
    Else
        isBusinessDay = True
    End If
End Function

Function isWeekend(aDate As Date) As Boolean
    ' check if input date is saturday or sunday
    ' recieves a date to check
    ' return true/false

    ' if the input day is sunday or the input day is saturday then
    If (Weekday(aDate) = 0 Or Weekday(aDate) = 6) Then

        isWeekend = True ' it is a weekend day
    Else
        isWeekend = False 'otherwise it is not a weekend day
    End If

End Function

Function isNewYearsDay(aDate As Date) As Boolean
    ' check if input date is new years day
    ' recieves a date to check
    ' return true/false

    ' if the input day is the first and the input month is January then
    If Day(aDate) = 1 And Month(aDate) = 1 Then
        isNewYearsDay = True ' it is new years day
    Else
        isNewYearsDay = False ' otherwise it is not new years day
    End If

End Function

Function isBusinessNewYearsDay(aDate As Date) As Boolean
    ' check if input date is new years day
    '   or if it's the nearest weekday when
    '   new years is on a weekend
    '
    ' recieves a date to check
    ' return true/false

    ' need to know yesterdays and tomorrows dates
    Dim yesterdayDate
    yesterdayDate = DateAdd("d", -1, aDate)
    Dim tomorrowDate
    tomorrowDate = DateAdd("d", 1, aDate)

    ' if today is monday and yesterday was the first of the month and
    '     yesterday's month was january then
    If Weekday(aDate) = 1 And Day(yesterdayDate) = 1 And Month(yesterdayDate) = 1 Then
        isBusinessNewYearsDay = True  ' then this is the monday new years rolls onto

    ' otherwise, if today is friday and tommorrow is the first of the month
    '     and tomorrow's month is january then
    ElseIf Weekday(aDate) = 5 And Day(tomorrowDate) = 1 And Month(tomorrowDate) = 1 Then
        isBusinessNewYearsDay = True  ' then this is the friday new years rolls onto

    ' otherwise, if the input day is the first and the input month is January
    ElseIf Day(aDate) = 1 And Month(aDate) = 1 Then
       isBusinessNewYearsDay = True  ' then it is new years day

    Else
        isBusinessNewYearsDay = False ' otherwise it is not new years day or a roll over day
    End If

End Function

Function isGoodFriday(aDate As Date) As Boolean
    ' check if input date is good friday
    ' recieves a date to check
    ' return true/false

    ' easter is two days after good friday
    Dim twoDaysLater As Date
    twoDaysLater = DateAdd("d", 2, aDate)

    ' If the date two days after the input date is easter of that year then
    If twoDaysLater = easterIn(Year(twoDaysLater)) Then
        isGoodFriday = True  ' it is good friday
    Else
        isGoodFriday = False  ' otherwise it is not good friday
    End If
End Function

Function easterIn(aYear As Integer) As Date
    ' determines day of easter in aYear
    ' recieves a year integer to find easter within
    ' returns a date object
    '
    ' credit: http:'en.wikipedia.org/wiki/Computus#Software
    '         http:'stackoverflow.com/questions/1284314/easter-date-in-javascript
    '         http:'www.ptb.de/cms/en/fachabteilungen/abt4/fb-44/ag-441/realisation-of-legal-time-in-germany/the-date-of-easter.html
    '         http://www.classanytime.com/mis333k/sjdatetime.html
    ' modified from the javascript sample code at wikipedia

    Dim moonShift As Single
    Dim daysToSpringMoon As Single
    Dim moonCycleCorrection As Single
    Dim dateOfFullMoon As Single
    Dim firstMarchSundayDate As Single
    Dim easterOffset As Single
    Dim firstSundayInMarch As Date
    Dim i As Integer
    Dim easterDate As Date

    ' Secular Moon shift
    moonShift = 15 + _
                mathFloor((3 * mathFloor(aYear / 100) + 3) / 4) - _
                mathFloor((8 * mathFloor(aYear / 100) + 13) / 25)

    ' Seed for 1st full Moon in spring
    daysToSpringMoon = (19 * (aYear Mod 19) + moonShift) Mod 30

    ' Calendarian correction quantity
    moonCycleCorrection = mathFloor(daysToSpringMoon / 29) + _
                          (mathFloor(daysToSpringMoon / 28) - _
                          mathFloor(daysToSpringMoon / 29)) * _
                          mathFloor((aYear Mod 19) / 11)

    ' Easter limit the day of the first Paschal full moon in Spring (as a date in March)
    '   Paschal full moon is not the same as the real full moon
    '   Easter has to be after this date (if it is on sunday, then easter is the following sunday).
    '   if the date is larger than the days in march, then later calculations roll it over to April
    dateOfFullMoon = 21 + daysToSpringMoon - moonCycleCorrection

    ' get first sunday in march
    '   there are some 'pure math' ways to get this, but this is easier to follow
    For i = 1 To 7                                   ' for the first week of march
        firstSundayInMarch = DateSerial(aYear, 3, i) ' check each day, starting with march 1st
        If Weekday(firstSundayInMarch) = 1 Then      ' until you find sunday
            Exit For                                 ' then get out of the loop
        End If
    Next i
    firstMarchSundayDate = Day(firstSundayInMarch)   ' save the date

    ' Distance Easter sunday from Easter limit in days
    easterOffset = 6 - (dateOfFullMoon - firstMarchSundayDate) Mod 7

    ' Find Easter
    easterDate = DateSerial(aYear, 3, 1)                      ' first day of march
    easterDate = DateAdd("d", dateOfFullMoon, easterDate)     ' add earliest date easter could be
    easterDate = DateAdd("d", easterOffset, easterDate)       ' add days after full moon to get easter

    ' return date object
    easterIn = easterDate
End Function

Function isMemorialDay(aDate As Date) As Boolean
    ' check if input date is memorial day
    ' recieves a date to check
    ' return true/false

    Dim aWeekLater As Date
    aWeekLater = DateAdd("d", 7, aDate)

    ' if the input month is may and the input day is monday and a week from the input day is in the next month then
    If Weekday(aDate) = 1 And Month(aDate) = 5 And Month(aWeekLater) = 6 Then
        isMemorialDay = True ' it is memorial day
    Else
        isMemorialDay = False ' otherwise it is not memorial day
    End If
End Function

Function isIndependenceDay(aDate As Date) As Boolean
    ' check if input date is independence day
    ' recieves a date to check
    ' return true/false

    ' if the input day is the fourth and the input month is July then
    If Day(aDate) = 4 And Month(aDate) = 7 Then
        isIndependenceDay = True ' it is independence day
    Else
        isIndependenceDay = False ' otherwise it is not independence day
    End If
End Function

Function isBusinessIndependenceDay(aDate As Date) As Boolean
    ' check if input date is independence day
    '     or if it's the nearest weekday when
    '     independence day is on a weekend
    '
    ' recieves a date to check
    ' return true/false

    ' need to know yesterdays and tomorrows dates
    Dim yesterdayDate
    yesterdayDate = DateAdd("d", -1, aDate)
    Dim tomorrowDate
    tomorrowDate = DateAdd("d", 1, aDate)

    ' if today is monday and yesterday was the 4th of the month
    '     and yesterday's month was july then
    If Weekday(aDate) = 1 And Day(yesterdayDate) = 4 And Month(yesterdayDate) = 7 Then
       isBusinessIndependenceDay = True  ' then this is the monday independence day rolls onto

    ' otherwise, if today is friday and tomorrow is the 4th of the month
    '     and tomorrow's month is july
    ElseIf Weekday(aDate) = 5 And Day(tomorrowDate) = 4 And Month(tomorrowDate) = 7 Then

    ' otherwise, if the input day is the 4th and the input month is july then
    ElseIf Day(tomorrowDate) = 4 And Month(tomorrowDate) = 7 Then
       isBusinessIndependenceDay = True  ' then it is independence day
    Else
        isBusinessIndependenceDay = False  ' it is not independence day or a roll over day
    End If
End Function

Function isLaborDay(aDate As Date) As Boolean
    ' check if input date is labor day
    ' recieves a date to check
    ' return true/false

    Dim aWeekEarlier As Date
    aWeekEarlier = DateAdd("d", -7, aDate)

    ' if the input month is September and the input day is monday
    '     and the previous monday was in the previous month then
    If Weekday(aDate) = 1 And Month(aDate) = 9 And Month(aWeekEarlier) = 8 Then
        isLaborDay = True ' it is labor day
    Else
        isLaborDay = False ' otherwise it is not labor day
    End If

End Function

Function isThanksgivingDay(aDate As Date) As Boolean
    ' check if input date is thanksgiving
    ' recieves a date to check
    ' return true/false

    ' the input month is november and the input day is thursday
    '     and the day of the week is the 4th of it's kind in the month
    If Month(aDate) = 11 And Weekday(aDate) = 4 And mathCeiling(Day(aDate) / 7) = 4 Then
        isThanksgivingDay = True ' it is thanksgiving day
    Else
        isThanksgivingDay = False ' otherwise it is not thanksgiving day
    End If
End Function

Function isDayAfterThanksgiving(aDate As Date) As Boolean
    ' check if input date is the day after thanksgiving
    ' recieves a date to check
    ' return true/false

    Dim previousDay As Date
    previousDay = DateAdd("d", -1, aDate)

    ' if previous day is thanksgiving
    If isThanksgivingDay(previousDay) = True Then
        isDayAfterThanksgiving = True ' it is the day after thanksgiving
    Else
        isDayAfterThanksgiving = False ' otherwise it is not the day after thanksgiving
    End If
End Function

Function isChristmasEve(aDate As Date) As Boolean
    ' check if input date is the day before christmas
    ' recieves a date to check
    ' return true/false

    ' if the input day is the 24th and the input month is December then
    If Day(aDate) = 24 And Month(aDate) = 12 Then
        isChristmasEve = True  ' it is christmas eve
    Else
        isChristmasEve = False  ' otherwise it is not christmas eve
    End If
End Function

Function isBusinessChristmasEve(aDate As Date) As Boolean
    ' check if input date is christmas eve
    '     or if it's the nearest weekday when
    '     christmas eve is on a weekend
    '
    ' recieves a date to check
    ' return true/false

    ' need to know the next two days dates
    Dim tomorrowDate As Date
    tomorrowDate = DateAdd("d", 1, aDate)
    Dim dayAfterTomorrowDate As Date
    dayAfterTomorrowDate = DateAdd("d", 2, aDate)


    ' if today is friday and tomorrow is the 24th and tomorrow is in december then
    If Weekday(aDate) = 5 And Day(tomorrowDate) = 24 And Month(tomorrowDate) = 12 Then
        isBusinessChristmasEve = True  ' then this is the friday christmas eve rolls onto

    ' Otherwise, if today is friday and day after tomorrow is the 24th and day after tomorrow is in december then
    ElseIf Weekday(aDate) = 5 And Day(dayAfterTomorrowDate) = 24 And Month(dayAfterTomorrowDate) = 12 Then
        isBusinessChristmasEve = True  ' then this is the friday christmas eve rolls onto

    ' Otherwise, if the input day is the 24th and the input month is December then
    ElseIf Day(aDate) = 24 And Month(aDate) = 12 Then
        isBusinessChristmasEve = True ' then it is christmas eve
    Else
        isBusinessChristmasEve = False ' otherwise it is not christmas eve or a roll over day
    End If
End Function

Function isChristmasDay(aDate As Date) As Boolean
    ' check if input date is the day before christmas
    ' recieves a date to check
    ' return true/false

    ' if the input day is the 24th and the input month is December then
    If Day(aDate) = 25 And Month(aDate) = 12 Then
        isChristmasDay = True  ' it is christmas day
    Else
        isChristmasDay = False  ' otherwise it is not christmas day
    End If

End Function

Function isBusinessChristmasDay(aDate As Date) As Boolean
    ' check if input date is christmas day
    '     or if it's the nearest weekday when
    '     christmas day is on a weekend
    '
    ' recieves a date to check
    ' return true/false

    ' need to know the previous two days dates
    Dim yesterdayDate As Date
    yesterdayDate = DateAdd("d", -1, aDate)
    Dim dayBeforeYesterdayDate As Date
    dayBeforeYesterdayDate = DateAdd("d", -2, aDate)

    ' if today is monday and yesterday is the 25th and yesterday is in december then
    If Weekday(aDate) = 1 And Day(yesterdayDate) = 25 And Month(yesterdayDate) = 12 Then
        isBusinessChristmasDay = True  ' then this is the monday christmas day rolls onto

    ' Otherwise, if today is monday and day before yesterday is the 25th and day before yesterday is in december then
    ElseIf Weekday(aDate) = 1 And Day(dayBeforeYesterdayDate) = 25 And Month(dayBeforeYesterdayDate) = 12 Then
        isBusinessChristmasDay = True  ' then this is the monday christmas day rolls onto

    ' Otherwise, if the input day is the 25th and the input month is December then
    ElseIf Day(aDate) = 25 And Month(aDate) = 12 Then
        isBusinessChristmasDay = True ' then it is christmas day
    Else
        isBusinessChristmasDay = False ' otherwise it is not christmas day or a roll over day
    End If
End Function

Function mathCeiling(aNumber As Variant) As Integer
    ' vba does not have a built in ceiling function
    ' recieves any number
    ' returns the nearest whole integer greater than or equal to the input
    ' this version does not handle negative numbers or other wierdness

    Dim aCopy As Integer
    aCopy = Int(aNumber) ' still have to use the int() function because direct assignment rounds off

    ' if input is already a whole integer
    If aCopy = aNumber Then
        mathCeiling = aCopy ' return it without comment
    Else
        aCopy = Int(aNumber + 1) ' add one to it and truncate the fraction
        mathCeiling = aCopy
    End If

End Function

Function mathFloor(aNumber As Variant) As Integer
    ' vba does not have a built in floor function
    ' recieves any number
    ' returns the nearest whole integer less than or equal to the input
    ' this version does not handle negative numbers or other wierdness

    ' return a truncated version of the input number
    mathFloor = Int(aNumber)
End Function


