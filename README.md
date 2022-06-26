# Libsh-iniparser

Ini-Config file parser for bash.

## Processing Rules

1. Same section & key pair will override its ancestors.
2. Lines starting with `#` or `;` will be ignored.
3. Empty lines will be ignored.
4. Values with no keys will be ignored.
5. At the beginning of the config file, keys with unspecified sections will automatically be added to the `Fallback` section.
6. Sections & keys can only contain alpha-numeric characters and underscores.
7. Sections & keys are case sensitive (by default).
8. Leading/trailing blanks will be removed.
9. Punctuation characters inside keys/sections will be converted to underscores `_` internally (so `foo.bar` will be identical to `foo_bar`).
10. Multiple underscores inside keys/sections will be removed internally (e.g. `__some_key__` to `_some_key_`).
11. Comments inside values will be removed.

## Functions

|Funcitons               |Argument(s)    |Description                                      |
|---                     |---            |---                                              |
|`ini_process_file`      |"file"         |Process the specified config file.               |
|`ini_get_value`         |"section" "key"|Return a value from specified section & key pair.|
|`ini_display`           |none           |Fully display the processed file.                |
|`ini_display_keys`      |"section"      |Display the keys of a specified section.         |
|`ini_display_values`    |"section"      |Display the values of a specified section.       |
|`ini_display_by_section`|"section"      |Display a specified section.                     |

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

## Defaults

Other than the above mentioned globals, there are also default variables.

|Defaults             |Type     |Value     |Value Changes With|Value Changes to|
|---                  |---      |---       |---               |---             |
|`INI_DEFAULT_PRINTF` |**\*Hardcoded**|"printf"  |`INI_IS_RAW_MODE` |"printf %s"     |
|`INI_DEFAULT_SECTION`|**\*Hardcoded**|"Fallback"|-                 |-               |
  
*However, changing them may result with undefined behaviour.*
  
*(\* Hardcoded: To change the value, one should modify the library.)*

## Examples

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

## Caveats

1. Two arrays per section will be generated. One for keys and one for values.
2. For a more secure approach, `#!/bin/bash` is used as SheBang. If this causes problems, please run `which bash` and change the SheBang accordingly.

## License

libsh-iniparser since 59e6753 is **sublicensed** under the LGPL v3. See LICENSE for details.
  
A relevant section of the original version's license is below:
```
Copyright © `2009-2021` `Wolf Software`

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the “Software”), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
```
  
**Note: I have no affiliation with Wolf Software.**
  
Copyright (C) <2022> Fatih Yeğin
  
Copyright (C) <2009-2021> Wolf Software
