# Noir Date

## Description

This library makes it easier to use date in Noir.

## Installation

In your Nargo.toml file, add the following dependency:

```
[dependencies]
date = { tag = "main", git = "https://github.com/madztheo/noir-date.git" }
```

### Import the library

Add this line to the top of your Noir file:

```rust
use dep::date::Date;
```

## Usage

### Initiaze a Date

```rust
// December 19, 2023
let date = Date::new(2023, 12, 19);

// Or alternatively from a string following this format yyyyMMdd
let date = Date::from_str_long_year("20231219");

// Or even from a byte representation of a ASCII string
let date = Date::from_bytes_long_year([50, 48, 50, 51, 49, 50, 49, 57]);
```

### Get the duration in days between two dates

```rust
let date1 = Date::new(2023, 10, 2);

let date2 = Date::new(2023, 12, 20);

// Will return 79
// date2 - date1
let duration = date2.duration(date1);
```

## Notes

This library is still in development and has not been fully tested yet. At the moment, there is a known bug related to comparisons with negative and positive numbers.
If you find any other bugs, please report them in the issues section of this repository.
