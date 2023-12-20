use dep::std::println;

struct Date {
    day: u8,
    month: u8,
    year: u16,
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
    pub fn new(year: u16, month: u8, day: u8) -> Self {
        assert(month >= 1 & month <= 12);
        assert(day >= 1 & day <= 31);
        let date = Self {
            day: day,
            month: month,
            year: year,
        };
        assert(day <= date.get_days_in_month(month));
        date
    }

    pub fn from_bytes_short_year(date: [u8; 6], threshold_year: [u8; 2]) -> Self {
        let firstYearDigit = get_number_from_utf8_code(date[0]);
        let secondYearDigit = get_number_from_utf8_code(date[1]);

        let mut year: u16 = firstYearDigit as u16 * 10 + secondYearDigit as u16;

        let firstMonthDigit = get_number_from_utf8_code(date[2]);
        let secondMonthDigit = get_number_from_utf8_code(date[3]);

        let month = firstMonthDigit * 10 + secondMonthDigit;

        let firstDayDigit = get_number_from_utf8_code(date[4]);
        let secondDayDigit = get_number_from_utf8_code(date[5]);

        let day = firstDayDigit * 10 + secondDayDigit;

        let currentYearFirstDigit = get_number_from_utf8_code(threshold_year[0]);
        let currentYearSecondDigit = get_number_from_utf8_code(threshold_year[1]);

        let mut currentYear: u16 = currentYearFirstDigit as u16 * 10 + currentYearSecondDigit as u16;

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

        Self {
            day: day,
            month: month,
            year: year,
        }
    }

    pub fn from_bytes_long_year(date: [u8; 8]) -> Self {
        let firstYearDigit = get_number_from_utf8_code(date[0]);
        let secondYearDigit = get_number_from_utf8_code(date[1]);
        let thirdYearDigit = get_number_from_utf8_code(date[2]);
        let fourthYearDigit = get_number_from_utf8_code(date[3]);

        let year: u16 = firstYearDigit as u16 * 1000 + secondYearDigit as u16 * 100 + thirdYearDigit as u16 * 10 + fourthYearDigit as u16;

        let firstMonthDigit = get_number_from_utf8_code(date[4]);
        let secondMonthDigit = get_number_from_utf8_code(date[5]);

        let month = firstMonthDigit * 10 + secondMonthDigit;

        let firstDayDigit = get_number_from_utf8_code(date[6]);
        let secondDayDigit = get_number_from_utf8_code(date[7]);

        let day = firstDayDigit * 10 + secondDayDigit;

        Self {
            day: day,
            month: month,
            year: year,
        }
    }

    pub fn from_str_short_year(date: str<6>, threshold_year: str<2>) -> Self {
        let date_bytes = date.as_bytes();
        Date::from_bytes_short_year(date_bytes, threshold_year.as_bytes())
    }
    
    pub fn from_str_long_year(date: str<8>) -> Self {
        let date_bytes = date.as_bytes();
        Date::from_bytes_long_year(date_bytes)
    }

    fn get_duration_in_days(self: Self, other: Self, absolute: bool) -> i32 {
        let totalDuration: i32 = self.get_duration_between_years(other) as i32 
        + self.get_duration_between_months(other) as i32
        + (self.day as i32 - other.day as i32);

        if (totalDuration < 0) & absolute {
            -1 * totalDuration
        }

        totalDuration
    }

    fn gt(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) > 0
    }

    fn lt(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) < 0
    }

    fn eq(self: Self, other: Self) -> bool {
        (self.day == other.day) & (self.month == other.month) & (self.year == other.year)
    }

    fn ne(self: Self, other: Self) -> bool {
        !self.eq(other)
    }

    fn gte(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) >= 0
    }

    fn lte(self: Self, other: Self) -> bool {
        self.get_duration_in_days(other, false) <= 0
    }

    fn println(self: Self) {
        println(self);
    }

    fn to_bytes(self: Self) -> [u8; 8] {
        let mut date: [u8; 8] = [0; 8];

        let firstYearDigit = self.year / 1000;
        let secondYearDigit = (self.year - firstYearDigit * 1000) / 100;
        let thirdYearDigit = (self.year - firstYearDigit * 1000 - secondYearDigit * 100) / 10;
        let fourthYearDigit = self.year - firstYearDigit * 1000 - secondYearDigit * 100 - thirdYearDigit * 10;

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

    fn is_leap_year(self: Self) -> bool {
        self.year % 4 == 0
    }

    fn get_days_in_month(self: Self, month: u8) -> u8 {
        assert(month >= 1 & month <= 12);
        if month == 2 {
            if self.is_leap_year() {
                29
            } else {
                28
            }
        } else {
            if (month == 1) | (month == 3) | (month == 5) | (month == 7) | (month == 8) | (month == 10) | (month == 12) {
                31
            } else {
                30
            }
        }
    }

    fn get_duration_between_months(self: Self, other: Self) -> i32 {
        assert(self.month >= 1 & self.month <= 12);
        assert(other.month >= 1 & other.month <= 12);
        let mut duration: i32 = 0;
        if(self.month < other.month) {
            for month in self.month..other.month {
                duration -= other.get_days_in_month(month) as i32;
            }
        } else {
            for month in other.month..self.month {
                duration += self.get_days_in_month(month) as i32;
            }
        }
        duration
    }

    fn get_duration_between_years(self: Self, other: Self) -> i32 {
        let mut duration: i32 = 0;
        if(self.year < other.year) {
            for year in self.year..other.year {
                if Date::new(year as u16, 1, 1).is_leap_year() {
                    duration -= 366;
                } else {
                    duration -= 365;
                }
            }
        } else {
            for year in other.year..self.year {
                if Date::new(year as u16, 1, 1).is_leap_year() {
                    duration += 366;
                } else {
                    duration += 365;
                }
            }
        }
        duration
    }

    fn add_years(self: Self, years: u16) -> Self {
        Self {
            day: self.day,
            month: self.month,
            year: self.year + years,
        }
    }

    fn sub_years(self: Self, years: u16) -> Self {
        Self {
            day: self.day,
            month: self.month,
            year: self.year - years,
        }
    }

    fn add_months(self: Self, months: u8) -> Self {
        let mut newMonth = self.month + months;
        let mut newYear = self.year;
        let yearToAdd = (newMonth - 1) / 12;
        if newMonth > 12 {
            newYear += yearToAdd as u16;
            newMonth -= 12 * yearToAdd;
        }
        Self {
            day: self.day,
            month: newMonth,
            year: newYear,
        }
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
    assert(Date::new(2024, 12, 31).get_duration_in_days(date, false) == 365 + 365);
    assert(Date::new(2025, 1, 1).get_duration_in_days(date, false) == 365 + 366);
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
