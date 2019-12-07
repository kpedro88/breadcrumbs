# breadcrumbs

A simple script to keep track of working directories.
Intended as a lightweight alternative to screen/tmux
for developers working on a number of projects
with different directories/environments.

## Installation

The installation script downloads the `bcs` script, installs it in the specified directory,
and adds the required alias or function to the logon file (see below).

```
wget https://raw.githubusercontent.com/kpedro88/breadcrumbs/master/install_bcs.sh
chmod +x install_bcs.sh
./install_bcs.sh -d [directory]
```

Installation script options:
```
-d          installation directory (required)
-f          logon file to install alias (default = ~/.bashrc or ~/.cshrc)
-a          alias name for cd + env (default = bcd)
-b          alias name for cd (default = bgo)
-v          version of bcs to install (default = master)
-s          shell (default = $SHELL)
```

## Usage

`bcs` keeps track of a list of directories in a json file. It can list the directories
(including certain metadata attributes), as well as add, remove, or change associated metadata.
Each directory has a unique label (if not specified, automatically set to the directory path
to ensure uniqueness) as well as a non-unique type (used as a classifier to allow removing
groups of directories). The date a directory was added to the list is also stored, and
newest directories are displayed first. (Re-adding a directory updates its date,
but modifying metadata (label or type) does not change the date.)

The simplest usage is just to call `bcs add` before closing one's terminal or ssh connection,
to keep track of one's last location. This can be automated by including the `bcs add`
call in a logout file. (The "type" attribute can be used to separate directories added
automatically from those added manually, if desired.)
One can then call `bcs list` on login to see the list of breadcrumbs.
The unique labels can be used as keywords if the user does not want to keep track of
the automatic numbering in the list.

A directory in the list can block other related directories from being added to the list.
By default, blocking is not enabled. A directory with a block level of 0 will block any of its subdirectories.
A higher block level will also block subdirectories of the corresponding higher-level directory.
For example, a directory `/A/B/C/D` with a block level of 1 would block all other subdirectories of `/A/B/C`,
while a block level of 2 would block all other subdirectories of `/A/B`.

Examples of the above:

`.login`:
```
bcs list -l
```

`.logout`:
```
if ( $PWD !~ $HOME ) then
    source $HOME/py.csh
    bcs add -t auto
endif
```

## Commands

`bcs add`:
```
usage: bcs add [-h] [-l LABEL] [-t TYPE] [-e ENV] [-k BLOCK] [-f] [-b] [dir]

positional arguments:
  dir                        name of directory to add (if not pwd)

optional arguments:
  -h, --help                 show this help message and exit
  -l LABEL, --label LABEL    label for directory to add (optional)
  -t TYPE, --type TYPE       type for directory to add (optional)
  -e ENV, --env ENV          env command for directory to add (optional)
  -k BLOCK, --block BLOCK    block level (optional)
  -f, --force                force update of already-used label or directory
  -b, --backup               make backup before changes
```

`bcs set`:
```
usage: bcs set [-h] [-l LABEL] [-t TYPE] [-e ENV] [-k BLOCK] [-f] [-b] [dir]

positional arguments:
  dir                        # or label of directory to update

optional arguments:
  -h, --help                 show this help message and exit
  -l LABEL, --label LABEL    label for directory to update (optional)
  -t TYPE, --type TYPE       type for directory to update (optional)
  -e ENV, --env ENV          env command for directory to update (optional)
  -k BLOCK, --block BLOCK    block level (optional)
  -f, --force                force update of already-used label
  -b, --backup               make backup before changes
```

`bcs list`:
```
usage: bcs list [-h] [-a] [-l] [-n | -k] [dir]

positional arguments:
  dir                        # or label of directory to list (lists all by default)

optional arguments:
  -h, --help                 show this help message and exit
  -a, --all                  list all properties for directory
  -l, --long                 use long listing (dates, labels, types)
  -n, --nonexistent          list only nonexistent directories
  -k, --blocked              list only blocked directories
```

`bcs rm`:
```
usage: bcs rm [-h] [-t TYPE] [-n] [-k] [-a] [-b] [dir [dir ...]]

positional arguments:
  dir                        #(s) or label(s) of directory(s) to remove from list

optional arguments:
  -h, --help                 show this help message and exit
  -t TYPE, --type TYPE       remove all of specified type
  -n, --nonexistent          remove nonexistent directories
  -k, --blocked              remove blocked directories
  -a, --all                  remove all
  -b, --backup               make backup before changes
```

`bcs cd`: used in shell commands
```
usage: bcs cd [-h] [-g] [dir]

positional arguments:
  dir         # or label of directory to cd

optional arguments:
  -h, --help  show this help message and exit
  -g, --go    go to directory without setting env
```

`bcs update`: used at installation for compatibility with schema changes
```
usage: bcs update [-h] [-b]

optional arguments:
  -h, --help    show this help message and exit
  -b, --backup  make backup before changes
```

`bcd`: (cd and set env)
```
usage: bcd [dir]

positional arguments:
  dir                        # or label of directory to cd
```

`bgo`: (cd, don't set env)
```
usage: bgo [dir]

positional arguments:
  dir                        # or label of directory to cd
```

Due to shell limitations, `bcd` and `bgo` are implemented as aliases for tcsh and functions for bash.
The aliases/functions can be renamed by the installation script.
