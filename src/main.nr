use dep::date::Date;
use dep::std::println;

fn main() {
    let firstDate = Date::new(2023, 11, 1);
    firstDate.println();

    let secondDate = Date::new(2025, 1, 1);
    secondDate.println();

    let duration = secondDate.get_duration_in_days(firstDate, true);
    println("Duration in days: ");
    println(duration);
}
