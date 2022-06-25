# Libsh-iniparser

Ini-Config file parser for bash.

## Processing Rules

1. Same section & key pair will override its ancestors.
2. Lines starting with `#` or `;` will be ignored.
3. Empty lines will be ignored.
4. Values with no keys will be ignored.
5. At the beginning of the config file, keys with unspecified sections will automatically be added to the `default` section.
6. Sections & keys can only contain alpha-numeric characters and underscores.
7. Sections & keys are case sensitive (by default).
8. Leading/trailing spaces will be removed.
9. In key/section punctuation characters (`.`, `:` etc.) will be converted to underscores `_` internally (so `foo.bar` will be identical to `foo_bar`).
10. In key/section multiple underscores will be removed internally (e.g. `__some_key__` to `_some_key_`).
11. Comments inside values will be removed.

## Functions

1. `ini_process_file` - Process an ini/config file.
2. `ini_get_value` - Print a specific value.
3. `ini_display` - Display the processed file.
4. `ini_display_by_section` - Display only a section.

## Globals (For Altering The Behaviour)

There is a complete example available ([parsing-example.sh](demo/parsing-example.sh)).

|Globals                         |Type   |Default value|
|---                             |---    |---          |
|`INI_IS_CASE_SENSITIVE_SECTIONS`|boolean|true         |
|`INI_IS_CASE_SENSITIVE_KEYS`    |boolean|true         |
|`INI_IS_SHOW_WARNINGS`          |boolean|true         |
|`INI_IS_SHOW_ERRORS`            |boolean|true         |
|`INI_IS_RAW_MODE`               |boolean|false        |
  
* In raw mode, `printf` format controls won't be interpreted.

### With Globals

```shell
#!/bin/bash

# Turn off warnings
INI_IS_SHOW_WARNINGS=false

# Case insensitive section names
INI_IS_CASE_SENSITIVE_KEYS=false

# Load the parser
source libsh-iniparser.sh

# Process the config file
ini_process_file 'example.conf'

# Display a specific value from a specific section
ini_get_value 'section1' 'key1'
```

### Without Globals

```shell
#!/bin/bash

# Load the parser
source libsh-iniparser.sh

# Process the config file
ini_process_file 'example.conf'

# Display a specific value from a specific section
ini_get_value 'section1' 'key1'
```

## License

libsh-iniparser since 59e6753 is sublicensed under the LGPL v3. See LICENSE for details.
  
**Note: I have no affiliation with Wolf Software.**
  
Copyright (C) <2022> Fatih Yeğin
  
Copyright (C) <2009-2021> Wolf Software

## Caveat

Two arrays per section will be generated. One for keys and one for values.
