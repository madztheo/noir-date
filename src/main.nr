use dep::date::Date;

fn main() {
    let firstDate = Date::new(2023, 11, 28);
    firstDate.println();

    let secondDate = Date::new(2023, 12, 28);
    secondDate.println();

    let duration = firstDate.get_duration_in_days(secondDate, true);
    println("Duration in days: ");
    println(duration);
}
