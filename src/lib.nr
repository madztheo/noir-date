use dep::std::println;

pub struct Date {
    day: u8,
    month: u8,
    year: u32,
}

fn get_number_from_utf8_code(code: u8) -> u8 {
    assert(code >= 48 & code <= 57);
    code - 48
}

fn number_to_utf8_code(number: u8) -> u8 {
    assert(number >= 0 & number <= 9);
    number + 48
}

impl Date {
    pub fn new(year: u32, month: u8, day: u8) -> Self {
        assert(month >= 1 & month <= 12);
        assert(day >= 1 & day <= 31);
        let date = Self { day: day, month: month, year: year };
        assert(day <= date.get_days_in_month(month));
        date
    }

    pub fn from_bytes_short_year(date: [u8; 6], threshold_year: [u8; 2]) -> Self {
        let firstYearDigit = get_number_from_utf8_code(date[0]);
        let secondYearDigit = get_number_from_utf8_code(date[1]);

        let mut year: u32 = firstYearDigit as u32 * 10 + secondYearDigit as u32;

        let firstMonthDigit = get_number_from_utf8_code(date[2]);
        let secondMonthDigit = get_number_from_utf8_code(date[3]);

        let month = firstMonthDigit * 10 + secondMonthDigit;

        let firstDayDigit = get_number_from_utf8_code(date[4]);
        let secondDayDigit = get_number_from_utf8_code(date[5]);

        let day = firstDayDigit * 10 + secondDayDigit;

        let currentYearFirstDigit = get_number_from_utf8_code(threshold_year[0]);
        let currentYearSecondDigit = get_number_from_utf8_code(threshold_year[1]);

        let mut currentYear: u32 =
            currentYearFirstDigit as u32 * 10 + currentYearSecondDigit as u32;

        // This way we have a smooth 100 years period according to a threshold year
        // Taking the current year as threshold year (for birthdates for example)
        // if the current year is 2023, then 24 will be interpreted as 1924
        // while 22 will be interpreted as 2022
        // A bit problematic for people over 100 years old
        if year <= currentYear {
            year += 2000;
        } else {
            year += 1900;
        }

        Self { day: day, month: month, year: year }
    }

    pub fn from_bytes_long_year(date: [u8; 8]) -> Self {
        let firstYearDigit = get_number_from_utf8_code(date[0]);
        let secondYearDigit = get_number_from_utf8_code(date[1]);
        let thirdYearDigit = get_number_from_utf8_code(date[2]);
        let fourthYearDigit = get_number_from_utf8_code(date[3]);

        let year: u32 = firstYearDigit as u32 * 1000
            + secondYearDigit as u32 * 100
            + thirdYearDigit as u32 * 10
            + fourthYearDigit as u32;

        let firstMonthDigit = get_number_from_utf8_code(date[4]);
        let secondMonthDigit = get_number_from_utf8_code(date[5]);

        let month = firstMonthDigit * 10 + secondMonthDigit;

        let firstDayDigit = get_number_from_utf8_code(date[6]);
        let secondDayDigit = get_number_from_utf8_code(date[7]);

        let day = firstDayDigit * 10 + secondDayDigit;

        Self { day: day, month: month, year: year }
    }

    pub fn from_str_short_year(date: str<6>, threshold_year: str<2>) -> Self {
        let date_bytes = date.as_bytes();
        Date::from_bytes_short_year(date_bytes, threshold_year.as_bytes())
    }

    pub fn from_str_long_year(date: str<8>) -> Self {
        let date_bytes = date.as_bytes();
        Date::from_bytes_long_year(date_bytes)
    }

    pub fn get_duration_in_days(self: Self, other: Self, absolute: bool) -> i64 {
        let mut duration_years = self.get_duration_between_years(other);
        let mut duration_months = self.get_duration_between_months(other);
        let mut duration_days = self.day as i64 - other.day as i64;
        if (self.year < other.year) {
            if (other.is_leap_year() & other.month > 2 & self.month > 2) {
                duration_days -= 1;
            }
        } else if (self.year > other.year) {
            if (self.is_leap_year() & self.month > 2 & other.month > 2) {
                duration_days += 1;
            }
        }
        let totalDuration: i64 = duration_years + duration_months + duration_days;

        if (totalDuration < 0) & absolute {
            -1 * totalDuration
        } else {
            totalDuration
        }
    }

    pub fn gt(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) > 0
    }

    pub fn lt(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) < 0
    }

    pub fn eq(self: Self, other: Self) -> bool {
        (self.day == other.day) & (self.month == other.month) & (self.year == other.year)
    }

    pub fn ne(self: Self, other: Self) -> bool {
        !self.eq(other)
    }

    pub fn gte(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) >= 0
    }

    pub fn lte(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) <= 0
    }

    pub fn println(self: Self) {
        let year = self.year;
        let month = self.month;
        let day = self.day;
        // Let's write the date in the YYYY-MM-DD format
        // since people don't agree on which format is best
        // between MM/DD/YYYY and DD/MM/YYYY
        if (month < 10) & (day < 10) {
            println(f"Date: {year}-0{month}-0{day}");
        } else if month < 10 {
            println(f"Date: {year}-0{month}-{day}");
        } else if day < 10 {
            println(f"Date: {year}-{month}-0{day}");
        } else {
            println(f"Date: {year}-{month}-{day}");
        }
    }

    pub fn to_bytes(self: Self) -> [u8; 8] {
        let mut date: [u8; 8] = [0; 8];

        let firstYearDigit = self.year / 1000;
        let secondYearDigit = (self.year - firstYearDigit * 1000) / 100;
        let thirdYearDigit = (self.year - firstYearDigit * 1000 - secondYearDigit * 100) / 10;
        let fourthYearDigit =
            self.year - firstYearDigit * 1000 - secondYearDigit * 100 - thirdYearDigit * 10;

        date[0] = number_to_utf8_code(firstYearDigit as u8);
        date[1] = number_to_utf8_code(secondYearDigit as u8);
        date[2] = number_to_utf8_code(thirdYearDigit as u8);
        date[3] = number_to_utf8_code(fourthYearDigit as u8);

        let firstMonthDigit = self.month / 10;
        let secondMonthDigit = self.month - firstMonthDigit * 10;

        date[4] = number_to_utf8_code(firstMonthDigit as u8);
        date[5] = number_to_utf8_code(secondMonthDigit as u8);

        let firstDayDigit = self.day / 10;
        let secondDayDigit = self.day - firstDayDigit * 10;

        date[6] = number_to_utf8_code(firstDayDigit as u8);
        date[7] = number_to_utf8_code(secondDayDigit as u8);

        date
    }

    pub fn is_leap_year(self: Self) -> bool {
        ((self.year % 4 == 0) & (self.year % 100 != 0)) | (self.year % 400 == 0)
    }

    pub fn leap_year_count(year: u32) -> i32 {
        (year / 4) as i32 - (year / 100) as i32 + (year / 400) as i32
    }

    pub fn get_days_in_month(self: Self, month: u8) -> u8 {
        assert(month >= 1 & month <= 12);
        if month == 2 {
            if self.is_leap_year() {
                29
            } else {
                28
            }
        } else {
            if (month == 1)
                | (month == 3)
                | (month == 5)
                | (month == 7)
                | (month == 8)
                | (month == 10)
                | (month == 12) {
                31
            } else {
                30
            }
        }
    }

    pub fn get_duration_between_months(self: Self, other: Self) -> i64 {
        assert(self.month >= 1 & self.month <= 12);
        assert(other.month >= 1 & other.month <= 12);
        let mut duration: i64 = 0;
        if (self.month < other.month) {
            for month in 1..13 {
                if month >= self.month & month < other.month {
                    duration -= other.get_days_in_month(month) as i64;
                }
            }
        } else {
            for month in 1..13 {
                if month >= other.month & month < self.month {
                    duration += self.get_days_in_month(month) as i64;
                }
            }
        }
        duration
    }

    pub fn get_duration_between_years(self: Self, other: Self) -> i64 {
        let mut duration: i64 = 0;
        if (self.year < other.year) {
            let mut leap_year_count: i32 =
                Date::leap_year_count(other.year - 1) - Date::leap_year_count(self.year);
            if self.is_leap_year() {
                leap_year_count += 1;
            }
            duration -= leap_year_count as i64 * 366;
            duration -=
                (other.year as i64 - self.year as i64 - leap_year_count as i64) as i64 * 365;
        } else if (self.year > other.year) {
            let mut leap_year_count: i32 =
                Date::leap_year_count(self.year - 1) - Date::leap_year_count(other.year);
            if other.is_leap_year() {
                leap_year_count += 1;
            }
            duration += leap_year_count as i64 * 366;
            duration +=
                (self.year as i64 - other.year as i64 - leap_year_count as i64) as i64 * 365;
        }
        duration
    }

    pub fn add_years(self: Self, years: u32) -> Self {
        Self { day: self.day, month: self.month, year: self.year + years }
    }

    pub fn sub_years(self: Self, years: u32) -> Self {
        Self { day: self.day, month: self.month, year: self.year - years }
    }

    pub fn add_months(self: Self, months: u32) -> Self {
        let mut newMonth = self.month as u32 + months;
        let mut newYear = self.year;
        let yearToAdd = (newMonth - 1) / 12;
        if newMonth > 12 {
            newYear += yearToAdd as u32;
            newMonth -= 12 * yearToAdd;
        }
        Self { day: self.day, month: newMonth as u8, year: newYear }
    }

    pub fn sub_months(self: Self, months: u32) -> Self {
        let mut newMonth = self.month as i32 - months as i32;
        let mut newYear = self.year;
        if newMonth < 1 {
            let yearToSub = ((newMonth as i32 - 12 as i32) * -1) / 12;
            newYear -= yearToSub as u32;
            newMonth += 12 * yearToSub;
        }
        Self { day: self.day, month: newMonth as u8, year: newYear }
    }

    pub fn add_days(self: Self, days: u32) -> Self {
        let mut newDay = self.day as u32 + days;
        let mut newMonth = self.month as u32;
        let mut newYear = self.year;
        let mut date = Self { day: newDay as u8, month: newMonth as u8, year: newYear };
        if newDay > self.get_days_in_month(self.month) as u32 {
            let max_months = (newDay / 30) + 1;
            let bound = self.month + max_months as u8;
            for _ in self.month..bound {
                let days_in_month = date.get_days_in_month(newMonth as u8) as u32;
                if newDay > days_in_month {
                    newDay -= days_in_month;
                    newMonth += 1;
                    if newMonth > 12 {
                        newYear += 1;
                        newMonth = 1;
                    }
                    // We need to mutate the date object inside the loop
                    // so we can use get_days_in_month properly
                    date.day = newDay as u8;
                    date.year = newYear;
                    date.month = newMonth as u8;
                }
            }
        }
        date
    }

    // Performance could be improved
    pub fn sub_days(self: Self, days: u32) -> Self {
        let mut newDay = self.day as i32 - days as i32;
        let mut newMonth = self.month as i32;
        let mut newYear = self.year;
        let mut date = Self { day: newDay as u8, month: newMonth as u8, year: newYear };
        if newDay < 1 {
            let max_months = (self.day as u32 + days) / 30 + 1;
            let bound = self.month + max_months as u8;
            for _ in self.month..bound {
                let days_in_month = date.get_days_in_month(newMonth as u8) as i32;
                if newDay < 1 {
                    newDay += days_in_month;
                    newMonth -= 1;
                    if newMonth < 1 {
                        newYear -= 1;
                        newMonth = 12;
                    }
                    // We need to mutate the date object inside the loop
                    // so we can use get_days_in_month properly
                    date.day = newDay as u8;
                    date.year = newYear;
                    date.month = newMonth as u8;
                }
            }
        }
        date
    }
}

#[test]
fn test_date_init() {
    let date = Date::new(2023, 12, 19);

    assert(date.day == 19);
    assert(date.month == 12);
    assert(date.year == 2023);
}

#[test]
fn test_date_from_bytes_short_year() {
    let date = Date::from_bytes_short_year([50, 51, 49, 50, 49, 57], [50, 52]);

    assert(date.day == 19);
    assert(date.month == 12);
    assert(date.year == 2023);
}

#[test]
fn test_date_from_bytes_long_year() {
    let date = Date::from_bytes_long_year([50, 48, 50, 51, 49, 50, 49, 57]);

    assert(date.day == 19);
    assert(date.month == 12);
    assert(date.year == 2023);
}

#[test]
fn test_date_from_str_short_year() {
    let date = Date::from_str_short_year("231219", "24");

    assert(date.day == 19);
    assert(date.month == 12);
    assert(date.year == 2023);
}

#[test]
fn test_date_from_str_long_year() {
    let date = Date::from_str_long_year("20231219");

    assert(date.day == 19);
    assert(date.month == 12);
    assert(date.year == 2023);
}

#[test]
fn test_date_to_bytes() {
    let date = Date::new(2023, 12, 19);

    let date_bytes = date.to_bytes();

    assert(date_bytes[0] == 50);
    assert(date_bytes[1] == 48);
    assert(date_bytes[2] == 50);
    assert(date_bytes[3] == 51);
    assert(date_bytes[4] == 49);
    assert(date_bytes[5] == 50);
    assert(date_bytes[6] == 49);
    assert(date_bytes[7] == 57);
}

#[test]
fn test_date_is_leap_year() {
    let date = Date::new(2023, 12, 19);

    assert(date.is_leap_year() == false);

    let date = Date::new(2024, 12, 19);

    assert(date.is_leap_year() == true);
}

#[test]
fn test_date_get_days_in_month() {
    let date = Date::new(2023, 1, 1);

    assert(date.get_days_in_month(1) == 31);
    assert(date.get_days_in_month(2) == 28);
    assert(date.get_days_in_month(3) == 31);
    assert(date.get_days_in_month(4) == 30);
    assert(date.get_days_in_month(5) == 31);
    assert(date.get_days_in_month(6) == 30);
    assert(date.get_days_in_month(7) == 31);
    assert(date.get_days_in_month(8) == 31);
    assert(date.get_days_in_month(9) == 30);
    assert(date.get_days_in_month(10) == 31);
    assert(date.get_days_in_month(11) == 30);
    assert(date.get_days_in_month(12) == 31);

    let date = Date::new(2024, 1, 1);

    assert(date.get_days_in_month(1) == 31);
    assert(date.get_days_in_month(2) == 29);
    assert(date.get_days_in_month(3) == 31);
    assert(date.get_days_in_month(4) == 30);
    assert(date.get_days_in_month(5) == 31);
    assert(date.get_days_in_month(6) == 30);
    assert(date.get_days_in_month(7) == 31);
    assert(date.get_days_in_month(8) == 31);
    assert(date.get_days_in_month(9) == 30);
    assert(date.get_days_in_month(10) == 31);
    assert(date.get_days_in_month(11) == 30);
    assert(date.get_days_in_month(12) == 31);
}

#[test]
fn test_date_get_duration_between_months() {
    let date = Date::new(2023, 1, 1);

    assert(Date::new(2023, 1, 1).get_duration_between_months(date) == 0);
    assert(Date::new(2023, 2, 1).get_duration_between_months(date) == 31);
    assert(Date::new(2023, 3, 1).get_duration_between_months(date) == 59);
    assert(Date::new(2023, 4, 1).get_duration_between_months(date) == 90);
    assert(Date::new(2023, 5, 1).get_duration_between_months(date) == 120);
    assert(Date::new(2023, 6, 1).get_duration_between_months(date) == 151);
    assert(Date::new(2023, 7, 1).get_duration_between_months(date) == 181);
    assert(Date::new(2023, 8, 1).get_duration_between_months(date) == 212);
    assert(Date::new(2023, 9, 1).get_duration_between_months(date) == 243);
    assert(Date::new(2023, 10, 1).get_duration_between_months(date) == 273);
    assert(Date::new(2023, 11, 1).get_duration_between_months(date) == 304);
    assert(Date::new(2023, 12, 1).get_duration_between_months(date) == 334);
}

#[test]
fn test_date_get_duration_between_years() {
    let date = Date::new(2023, 1, 1);

    // Positive duration
    assert(Date::new(2023, 1, 1).get_duration_between_years(date) == 0);
    assert(Date::new(2024, 1, 1).get_duration_between_years(date) == 365);
    assert(Date::new(2025, 1, 1).get_duration_between_years(date) == 731);
    assert(Date::new(2026, 1, 1).get_duration_between_years(date) == 1096);
    assert(Date::new(2027, 1, 1).get_duration_between_years(date) == 1461);
    assert(Date::new(2028, 1, 1).get_duration_between_years(date) == 1826);
    assert(Date::new(2029, 1, 1).get_duration_between_years(date) == 2192);
    assert(Date::new(2030, 1, 1).get_duration_between_years(date) == 2557);
    assert(Date::new(2031, 1, 1).get_duration_between_years(date) == 2922);
    assert(Date::new(2032, 1, 1).get_duration_between_years(date) == 3287);
    assert(Date::new(2033, 1, 1).get_duration_between_years(date) == 3653);
    assert(Date::new(2034, 1, 1).get_duration_between_years(date) == 4018);

    // Negative duration
    assert(Date::new(2022, 1, 1).get_duration_between_years(date) == -365);
    assert(Date::new(2021, 1, 1).get_duration_between_years(date) == -730);
    assert(Date::new(2020, 1, 1).get_duration_between_years(date) == -1096);
    assert(Date::new(2019, 1, 1).get_duration_between_years(date) == -1461);
    assert(Date::new(2018, 1, 1).get_duration_between_years(date) == -1826);
    assert(Date::new(2017, 1, 1).get_duration_between_years(date) == -2191);
    assert(Date::new(2016, 1, 1).get_duration_between_years(date) == -2557);
    assert(Date::new(2015, 1, 1).get_duration_between_years(date) == -2922);
    assert(Date::new(2014, 1, 1).get_duration_between_years(date) == -3287);
    assert(Date::new(2013, 1, 1).get_duration_between_years(date) == -3652);
    assert(Date::new(2012, 1, 1).get_duration_between_years(date) == -4018);
}

#[test]
fn test_date_get_duration_in_days() {
    let date = Date::new(2023, 1, 1);

    assert(Date::new(2023, 1, 1).get_duration_in_days(date, false) == 0);
    assert(Date::new(2023, 1, 15).get_duration_in_days(date, false) == 14);
    assert(Date::new(2023, 2, 1).get_duration_in_days(date, false) == 31);
    assert(Date::new(2023, 2, 15).get_duration_in_days(date, false) == 45);
    assert(Date::new(2023, 3, 1).get_duration_in_days(date, false) == 59);
    assert(Date::new(2023, 12, 31).get_duration_in_days(date, false) == 364);
    assert(Date::new(2024, 1, 1).get_duration_in_days(date, false) == 365);
    assert(Date::new(2024, 2, 28).get_duration_in_days(date, false) == 365 + 31 + 27);
    assert(Date::new(2024, 2, 29).get_duration_in_days(date, false) == 365 + 31 + 28);
    assert(Date::new(2024, 3, 1).get_duration_in_days(date, false) == 365 + 31 + 29);
    assert(Date::new(2024, 12, 31).get_duration_in_days(date, false) == 365 + 365);
    assert(Date::new(2025, 1, 1).get_duration_in_days(date, false) == 365 + 366);

    assert(Date::new(2017, 6, 18).get_duration_in_days(Date::new(2000, 1, 1), false) == 6378);
    assert(Date::new(2179, 6, 6).get_duration_in_days(Date::new(2000, 1, 1), false) == 0xffff);
    assert(Date::new(2019, 6, 6).get_duration_in_days(Date::new(2000, 1, 1), false) == 7096);
    assert(Date::new(2001, 1, 1).get_duration_in_days(Date::new(2000, 12, 31), false) == 1);
    assert(Date::new(2001, 1, 1).get_duration_in_days(Date::new(2000, 12, 31), false) == 1);
    assert(Date::new(2001, 1, 1).get_duration_in_days(Date::new(2000, 1, 1), false) == 366);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 0);
    assert(Date::new(2023, 1, 15).get_duration_in_days(Date::new(2023, 1, 1), false) == 14);
    assert(Date::new(2023, 2, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 31);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2023, 1, 1), false) == 364);
    assert(Date::new(2024, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 365);
    assert(Date::new(2024, 1, 1).get_duration_in_days(Date::new(2020, 1, 1), false) == 1461);
    assert(Date::new(2024, 1, 1).get_duration_in_days(Date::new(2020, 3, 1), false) == 1401);
    assert(Date::new(2024, 12, 31).get_duration_in_days(Date::new(2023, 12, 31), false) == 366);
    assert(Date::new(2028, 12, 31).get_duration_in_days(Date::new(2023, 12, 31), false) == 1827);
    assert(Date::new(2029, 12, 31).get_duration_in_days(Date::new(2023, 12, 31), false) == 2192);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2022, 1, 1), false) == 365);
    assert(Date::new(2025, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 731);
    assert(Date::new(2026, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 1096);
    assert(Date::new(2030, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 2557);
    assert(Date::new(2023, 6, 15).get_duration_in_days(Date::new(2023, 1, 1), false) == 165);
    assert(Date::new(2023, 12, 25).get_duration_in_days(Date::new(2023, 6, 15), false) == 193);
    assert(Date::new(2024, 2, 29).get_duration_in_days(Date::new(2023, 12, 31), false) == 60);
    assert(Date::new(2025, 3, 15).get_duration_in_days(Date::new(2023, 9, 1), false) == 561);
    assert(Date::new(2050, 2, 4).get_duration_in_days(Date::new(2000, 1, 1), false) == 18297);
    assert(Date::new(2171, 9, 9).get_duration_in_days(Date::new(2000, 1, 1), false) == 62708);
    assert(Date::new(2142, 2, 24).get_duration_in_days(Date::new(2000, 1, 1), false) == 51919);
    assert(Date::new(2091, 12, 23).get_duration_in_days(Date::new(2000, 1, 1), false) == 33594);
    assert(Date::new(2169, 2, 14).get_duration_in_days(Date::new(2000, 1, 1), false) == 61771);
    assert(Date::new(2038, 11, 12).get_duration_in_days(Date::new(2000, 1, 1), false) == 14195);
    assert(Date::new(2129, 7, 11).get_duration_in_days(Date::new(2000, 1, 1), false) == 47308);
    assert(Date::new(2112, 9, 16).get_duration_in_days(Date::new(2000, 1, 1), false) == 41166);
    assert(Date::new(2109, 7, 23).get_duration_in_days(Date::new(2000, 1, 1), false) == 40015);
    assert(Date::new(2101, 12, 18).get_duration_in_days(Date::new(2000, 1, 1), false) == 37241);
    assert(Date::new(2150, 1, 7).get_duration_in_days(Date::new(2000, 1, 1), false) == 54793);
    assert(Date::new(2179, 9, 15).get_duration_in_days(Date::new(2000, 1, 1), false) == 65636);
    assert(Date::new(2038, 1, 30).get_duration_in_days(Date::new(2000, 1, 1), false) == 13909);
    assert(Date::new(2154, 7, 4).get_duration_in_days(Date::new(2000, 1, 1), false) == 56432);
    assert(Date::new(2010, 10, 27).get_duration_in_days(Date::new(2000, 1, 1), false) == 3952);
    assert(Date::new(2194, 9, 4).get_duration_in_days(Date::new(2000, 1, 1), false) == 71104);
    assert(Date::new(2014, 7, 23).get_duration_in_days(Date::new(2000, 1, 1), false) == 5317);
    assert(Date::new(2118, 12, 17).get_duration_in_days(Date::new(2000, 1, 1), false) == 43449);
    assert(Date::new(2116, 9, 27).get_duration_in_days(Date::new(2000, 1, 1), false) == 42638);
    assert(Date::new(2091, 9, 25).get_duration_in_days(Date::new(2000, 1, 1), false) == 33505);
    assert(Date::new(2147, 11, 15).get_duration_in_days(Date::new(2000, 1, 1), false) == 54009);
    assert(Date::new(2130, 7, 30).get_duration_in_days(Date::new(2000, 1, 1), false) == 47692);
    assert(Date::new(2031, 12, 18).get_duration_in_days(Date::new(2000, 1, 1), false) == 11674);
    assert(Date::new(2092, 1, 30).get_duration_in_days(Date::new(2000, 1, 1), false) == 33632);
    assert(Date::new(2111, 7, 14).get_duration_in_days(Date::new(2000, 1, 1), false) == 40736);
    assert(Date::new(2089, 11, 10).get_duration_in_days(Date::new(2000, 1, 1), false) == 32821);
    assert(Date::new(2022, 10, 26).get_duration_in_days(Date::new(2000, 1, 1), false) == 8334);
    assert(Date::new(2159, 7, 19).get_duration_in_days(Date::new(2000, 1, 1), false) == 58273);
    assert(Date::new(2164, 8, 25).get_duration_in_days(Date::new(2000, 1, 1), false) == 60137);
    assert(Date::new(2079, 4, 13).get_duration_in_days(Date::new(2000, 1, 1), false) == 28957);

    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2017, 6, 18), false) == -6378);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2179, 6, 6), false) == -0xffff);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2019, 6, 6), false) == -7096);
    assert(Date::new(2000, 12, 31).get_duration_in_days(Date::new(2001, 1, 1), false) == -1);
    assert(Date::new(2000, 12, 31).get_duration_in_days(Date::new(2001, 1, 1), false) == -1);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2001, 1, 1), false) == -366);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), false) == 0);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 1, 15), false) == -14);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 2, 1), false) == -31);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 12, 31), false) == -364);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2024, 1, 1), false) == -365);
    assert(Date::new(2020, 1, 1).get_duration_in_days(Date::new(2024, 1, 1), false) == -1461);
    assert(Date::new(2020, 3, 1).get_duration_in_days(Date::new(2024, 1, 1), false) == -1401);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2024, 12, 31), false) == -366);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2028, 12, 31), false) == -1827);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2029, 12, 31), false) == -2192);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2022, 10, 26), false) == -8334);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2159, 7, 19), false) == -58273);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2164, 8, 25), false) == -60137);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2079, 4, 13), false) == -28957);

    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2017, 6, 18), true) == 6378);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2179, 6, 6), true) == 0xffff);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2019, 6, 6), true) == 7096);
    assert(Date::new(2000, 12, 31).get_duration_in_days(Date::new(2001, 1, 1), true) == 1);
    assert(Date::new(2000, 12, 31).get_duration_in_days(Date::new(2001, 1, 1), true) == 1);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2001, 1, 1), true) == 366);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 1, 1), true) == 0);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 1, 15), true) == 14);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 2, 1), true) == 31);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2023, 12, 31), true) == 364);
    assert(Date::new(2023, 1, 1).get_duration_in_days(Date::new(2024, 1, 1), true) == 365);
    assert(Date::new(2020, 1, 1).get_duration_in_days(Date::new(2024, 1, 1), true) == 1461);
    assert(Date::new(2020, 3, 1).get_duration_in_days(Date::new(2024, 1, 1), true) == 1401);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2024, 12, 31), true) == 366);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2028, 12, 31), true) == 1827);
    assert(Date::new(2023, 12, 31).get_duration_in_days(Date::new(2029, 12, 31), true) == 2192);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2022, 10, 26), true) == 8334);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2159, 7, 19), true) == 58273);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2164, 8, 25), true) == 60137);
    assert(Date::new(2000, 1, 1).get_duration_in_days(Date::new(2079, 4, 13), true) == 28957);
}

#[test]
fn test_date_eq() {
    let date = Date::new(2023, 1, 1);

    assert(date.eq(Date::new(2023, 1, 1)));
    assert(!date.eq(Date::new(2023, 1, 2)));
}

#[test]
fn test_date_ne() {
    let date = Date::new(2023, 1, 1);

    assert(!date.ne(Date::new(2023, 1, 1)));
    assert(date.ne(Date::new(2023, 1, 2)));
}

#[test]
fn test_date_gt() {
    let date = Date::new(2023, 1, 1);

    assert(!date.gt(Date::new(2023, 1, 1)));
    assert(!date.gt(Date::new(2023, 1, 2)));
    assert(date.gt(Date::new(2022, 12, 31)));
}

#[test]
fn test_date_lt() {
    let date = Date::new(2023, 1, 1);

    assert(!date.lt(Date::new(2023, 1, 1)));
    assert(!date.lt(Date::new(2022, 12, 31)));
    assert(date.lt(Date::new(2023, 1, 2)));
}

#[test]
fn test_date_gte() {
    let date = Date::new(2023, 1, 1);

    assert(date.gte(Date::new(2023, 1, 1)));
    assert(!date.gte(Date::new(2023, 1, 2)));
    assert(date.gte(Date::new(2022, 12, 31)));
}

#[test]
fn test_date_lte() {
    let date = Date::new(2023, 1, 1);

    assert(date.lte(Date::new(2023, 1, 1)));
    assert(!date.lte(Date::new(2022, 12, 31)));
    assert(date.lte(Date::new(2023, 1, 2)));
}

#[test]
fn test_date_add_years() {
    let date = Date::new(2023, 7, 14);

    assert(date.add_years(0).eq(Date::new(2023, 7, 14)));
    assert(date.add_years(1).eq(Date::new(2024, 7, 14)));
    assert(date.add_years(2).eq(Date::new(2025, 7, 14)));
    assert(date.add_years(3).eq(Date::new(2026, 7, 14)));
    assert(date.add_years(4).eq(Date::new(2027, 7, 14)));
    assert(date.add_years(5).eq(Date::new(2028, 7, 14)));
}

#[test]
fn test_date_sub_years() {
    let date = Date::new(2023, 7, 14);

    assert(date.sub_years(0).eq(Date::new(2023, 7, 14)));
    assert(date.sub_years(1).eq(Date::new(2022, 7, 14)));
    assert(date.sub_years(2).eq(Date::new(2021, 7, 14)));
    assert(date.sub_years(3).eq(Date::new(2020, 7, 14)));
    assert(date.sub_years(4).eq(Date::new(2019, 7, 14)));
    assert(date.sub_years(5).eq(Date::new(2018, 7, 14)));
}

#[test]
fn test_date_add_months() {
    let date = Date::new(2023, 7, 14);

    assert(date.add_months(0).eq(Date::new(2023, 7, 14)));
    assert(date.add_months(1).eq(Date::new(2023, 8, 14)));
    assert(date.add_months(2).eq(Date::new(2023, 9, 14)));

    assert(date.add_months(6).eq(Date::new(2024, 1, 14)));
    assert(date.add_months(7).eq(Date::new(2024, 2, 14)));
    assert(date.add_months(8).eq(Date::new(2024, 3, 14)));

    assert(date.add_months(17).eq(Date::new(2024, 12, 14)));
    assert(date.add_months(18).eq(Date::new(2025, 1, 14)));

    assert(date.add_months(29).eq(Date::new(2025, 12, 14)));
    assert(date.add_months(30).eq(Date::new(2026, 1, 14)));
}

#[test]
fn test_date_sub_months() {
    let date = Date::new(2023, 7, 14);

    assert(date.sub_months(0).eq(Date::new(2023, 7, 14)));
    assert(date.sub_months(1).eq(Date::new(2023, 6, 14)));
    assert(date.sub_months(2).eq(Date::new(2023, 5, 14)));

    assert(date.sub_months(6).eq(Date::new(2023, 1, 14)));
    assert(date.sub_months(7).eq(Date::new(2022, 12, 14)));
    assert(date.sub_months(8).eq(Date::new(2022, 11, 14)));

    assert(date.sub_months(17).eq(Date::new(2022, 2, 14)));
    assert(date.sub_months(18).eq(Date::new(2022, 1, 14)));
    assert(date.sub_months(19).eq(Date::new(2021, 12, 14)));

    assert(date.sub_months(30).eq(Date::new(2021, 1, 14)));
    assert(date.sub_months(31).eq(Date::new(2020, 12, 14)));

    assert(date.sub_months(41).eq(Date::new(2020, 2, 14)));
    assert(date.sub_months(42).eq(Date::new(2020, 1, 14)));
    assert(date.sub_months(43).eq(Date::new(2019, 12, 14)));
}

#[test]
fn test_date_add_days() {
    let date = Date::new(2023, 7, 14);

    assert(date.add_days(0).eq(Date::new(2023, 7, 14)));
    assert(date.add_days(1).eq(Date::new(2023, 7, 15)));
    assert(date.add_days(2).eq(Date::new(2023, 7, 16)));

    assert(date.add_days(17).eq(Date::new(2023, 7, 31)));
    assert(date.add_days(18).eq(Date::new(2023, 8, 1)));
    assert(date.add_days(19).eq(Date::new(2023, 8, 2)));

    assert(date.add_days(31).eq(Date::new(2023, 8, 14)));
    assert(date.add_days(32).eq(Date::new(2023, 8, 15)));
    assert(date.add_days(33).eq(Date::new(2023, 8, 16)));

    assert(date.add_days(365).eq(Date::new(2024, 7, 13)));
    assert(date.add_days(366).eq(Date::new(2024, 7, 14)));
    assert(date.add_days(367).eq(Date::new(2024, 7, 15)));

    assert(date.add_days(365 + 365).eq(Date::new(2025, 7, 13)));
    assert(date.add_days(365 + 366).eq(Date::new(2025, 7, 14)));
    assert(date.add_days(365 + 367).eq(Date::new(2025, 7, 15)));

    assert(date.add_days(365 + 366 + 364).eq(Date::new(2026, 7, 13)));
    assert(date.add_days(365 + 366 + 365).eq(Date::new(2026, 7, 14)));
    assert(date.add_days(365 + 366 + 366).eq(Date::new(2026, 7, 15)));

    // After 4 regular years and 2 leap years
    assert(date.add_days(365 * 4 + 366 * 2 - 1).eq(Date::new(2029, 7, 13)));
    assert(date.add_days(365 * 4 + 366 * 2).eq(Date::new(2029, 7, 14)));
    assert(date.add_days(365 * 4 + 366 * 2 + 1).eq(Date::new(2029, 7, 15)));
}

#[test]
fn test_date_sub_days() {
    let date = Date::new(2023, 7, 14);

    assert(date.sub_days(0).eq(Date::new(2023, 7, 14)));
    assert(date.sub_days(1).eq(Date::new(2023, 7, 13)));
    assert(date.sub_days(2).eq(Date::new(2023, 7, 12)));

    assert(date.sub_days(17).eq(Date::new(2023, 6, 28)));
    assert(date.sub_days(18).eq(Date::new(2023, 6, 27)));
    assert(date.sub_days(19).eq(Date::new(2023, 6, 26)));

    assert(date.sub_days(31).eq(Date::new(2023, 6, 14)));
    assert(date.sub_days(32).eq(Date::new(2023, 6, 13)));
    assert(date.sub_days(33).eq(Date::new(2023, 6, 12)));

    assert(date.sub_days(365).eq(Date::new(2022, 7, 14)));
    assert(date.sub_days(366).eq(Date::new(2022, 7, 13)));
    assert(date.sub_days(367).eq(Date::new(2022, 7, 12)));

    assert(date.sub_days(365 + 365).eq(Date::new(2021, 7, 14)));
    assert(date.sub_days(365 + 366).eq(Date::new(2021, 7, 13)));
    assert(date.sub_days(365 + 367).eq(Date::new(2021, 7, 12)));

    assert(date.sub_days(365 + 365 + 365).eq(Date::new(2020, 7, 14)));
    assert(date.sub_days(365 + 365 + 366).eq(Date::new(2020, 7, 13)));
    assert(date.sub_days(365 + 365 + 367).eq(Date::new(2020, 7, 12)));

    // After 5 regular years and 1 leap year
    assert(date.sub_days(365 * 5 + 366 - 1).eq(Date::new(2017, 7, 15)));
    assert(date.sub_days(365 * 5 + 366).eq(Date::new(2017, 7, 14)));
    assert(date.sub_days(365 * 5 + 366 + 1).eq(Date::new(2017, 7, 13)));

    // After 6 regular years and 2 leap years
    assert(date.sub_days(365 * 6 + 366 * 2 - 1).eq(Date::new(2015, 7, 15)));
    assert(date.sub_days(365 * 6 + 366 * 2).eq(Date::new(2015, 7, 14)));
    assert(date.sub_days(365 * 6 + 366 * 2 + 1).eq(Date::new(2015, 7, 13)));
}

#[test]
fn test_date_age() {
    let birthdate = Date::new(1995, 4, 13);

    // Add 18 years to the birthdate
    // to get the date when the person is 18 years old
    let majority_date = birthdate.add_years(18);

    // Make sure the majority date is correct
    assert(majority_date.eq(Date::new(2013, 4, 13)));

    // Compare the majority date to the current date
    // to see if the person is 18 years old
    assert(majority_date.lte(Date::new(2023, 12, 20)));
}
