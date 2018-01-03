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
-a          alias name (default = bcsgo)
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

## Commands

`bcs add`:
```
 bcs add --help
usage: bcs add [-h] [-l LABEL] [-t TYPE] [-f] [dir]

positional arguments:
  dir                        name of directory to add (if not pwd) or # of directory to update

optional arguments:
  -h, --help                 show this help message and exit
  -l LABEL, --label LABEL    label for directory to add/update (optional)
  -t TYPE, --type TYPE       type for directory to add/update (optional)
  -f, --force                force update of already-used label or directory
```

`bcs list`:
```
usage: bcs list [-h] [-l] [dir]

positional arguments:
  dir                        # or label of directory to list (lists all by default)

optional arguments:
  -h, --help                 show this help message and exit
  -l, --long                 use long listing (dates, labels, types)
  -n, --nonexistent          list only nonexistent directories
```

`bcs rm`:
```
usage: bcs rm [-h] [-t TYPE] [-a] [dir]

positional arguments:
  dir                        #(s) or label(s) of directory(s) to remove from list

optional arguments:
  -h, --help                 show this help message and exit
  -t TYPE, --type TYPE       remove all of specified type
  -n, --nonexistent          remove nonexistent directories
  -a, --all                  remove all
```

`bcsgo`: (no space)
```
usage: bcsgo [dir]

positional arguments:
  dir                        # or label of directory to cd
```
Due to shell limitations, `bcsgo` is implemented as an alias for tcsh and a function for bash.
The alias/function can be renamed by the installation script; one shorter example is `bcd`.