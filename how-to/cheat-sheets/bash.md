# Bash scripting cheatsheet

## Starting a script

- name should end with .sh
- First line should be a shebang line
  - #!/usr/bin/env bash
  - #!/usr/bin/bash

## Variables

``` bash
NAME="John"                         # Defineing the var
echo "Hi $NAME"                     #=> Hi John
echo 'Hi $NAME'                     #=> Hi $NAME
```

## Functions

``` bash
get_name() {
  echo "John"
}

echo "You are $(get_name)"          # Calling in a string
get_name                            # Calling on the script
```

## Conditionals

``` bash
if [[ -z "$string" ]]; then
  echo "String is empty"
elif [[ -n "$string" ]]; then
  echo "String is not empty"
fi
```

## Conditional execution

``` bash
git commit && git push              # Do git commit if succes then git push
git commit || echo "Commit failed"  # Do git commit if fail then git echo "Commit failed"
```

