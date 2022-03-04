# base.sh
`base.sh` is just a skeleton to be used by others scripts. Although it runs, it does nothing. 
It *imports* `writer.sh` (that *imports* `colors.sh` in its turn) to make use of `msg`, `info`, `warning`, and `error` functions (declared in *writer.sh*) and `colorize`, `remove_colors`, and `update_short_names_values` (functions declared in *colors.sh*).
Besides that, it implements these readonly functions:

- `assert_var `: Utility function to assert if a var has value. Otherwise prints a message with the var name and calls the `usage` function. Params:
  - `$1`: variable value.
  - `$2`: variable name.
- `debug`: # Prints a message to console, only if `-v` or `--verbose` is present in the arguments. Params:
  - `$1`: message to print.
- `get_param`: Search for both short or long names among the script's arguments. If they are found sets the global var "param"'s value and return success, otherwise failure. Params:
  - `$1`: parameter's short name.
  - `$2`: parameter's long name.
- `get_param_or_default`: Search for both short or long names among the script's arguments. If they are found sets the global var `param`'s value, otherwise uses the default one, and then return success. Params:
  - `$1` parameter's short name.
  - `$2` parameter's long name.
  - `$3` The default value to be used in case it is not found/set.
- `has_flag`: Checks if a flag is present among the script's arguments and return success or failure. Params:
  - `$1`: flag's short name.
  - `$2`: flag's long name.
- `has_param`: Checks if a parameter is present among the script's arguments and return success or failure. Params:
  - `$1`: parameter's short name.
  - `$2`: parameter's long name.
- `main`: The function your script can call in its end. It will call the others function in that order:
  1. `setup_consts`
  2. `usage`: only if `-h` or `--help` is present and exit.
  3. `initialize_vars`
  4. `parse_params`
  5. `setup_default`
  6. `run`
- `rename_function`: Renames a declared function from $1 to $2. Allowing to override it. Params:
  - `$1`: function to rename.
  - `$2`: new function's name. Defaults to 'base.$1'
- and `throw_error`: Write a message to the console and exits with the provided code. Params:
  - `$1`: Message to be printed.
  - `$2`: error code for the exit. Defaults to `1`.

and functions that may be overriden (and/or renamed them before):

- `cleanup`: Whenever the script exits this function will be called.
- `usage`: Content to be displayed whenever `-h` or `--help` flag is passed as paramenter.
- `parse_params`: Does some dummy parsing. By overriding it you have to redeclare the last four cases (in that order).
- `setup_consts`: Sets script's constants .
- `setup_default`: After the params are parsed it is clled to setup the default values.
- `initialize_vars`: Initializes script's variables before the params are parsed.
- `run`: The core function that is called after the script is ready to be executed. From this one, you can call any of yours.


After you've sourced `base.sh` file, and you want that everything run *automatically*, you have to call the `main` function in the very end of your script.
If, on the other hand, you only want to use the utilities function, just *source* `base.sh` and use then on your way.