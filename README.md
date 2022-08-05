# breadcrumbs

A simple script to keep track of working directories in `bash`.
Intended as a lightweight alternative to screen/tmux
for developers working on a number of projects
with different directories/environments.

## Installation

The installation script downloads the `bcs` script, installs it in the specified directory,
and adds the required functions to the logon file (see below).

```
wget https://raw.githubusercontent.com/kpedro88/breadcrumbs/master/install_bcs.sh
chmod +x install_bcs.sh
./install_bcs.sh -d [directory]
```

Installation script options:
```
-d          installation directory (required)
-f          logon file to install functions (default = ~/.bashrc)
-a          function name for cd + env (default = bcd)
-b          function name for cd (default = bgo)
-e          script name for CMSSW singularity env (default = benv)
-v          version of bcs to install (default = master)
-h          print this message and exit
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

When adding a directory, the environment command will be automatically populated with
``eval `scramv1 runtime -sh`​``
if the directory name contains "CMSSW". This can be disabled using the `-E` flag.
If Singularity is needed for a given CMSSW version (determined by checking the base OS),
the environment command will launch the appropriate container (with GPU support, if possible),
and call the above CMSSW environment command.
This is accomplished by a bash script `benv` that is created by the installation script.

A directory in the list can block other related directories from being added to the list.
By default, blocking is not enabled. A directory with a block level of 0 will block any of its subdirectories.
A higher block level will also block subdirectories of the corresponding higher-level directory.
For example, a directory `/A/B/C/D` with a block level of 1 would block all other subdirectories of `/A/B/C`,
while a block level of 2 would block all other subdirectories of `/A/B`.

Examples of the above:

`.bash_login`:
```bash
if type bcs >& /dev/null; then
	bcs list -l
fi
```

`.bash_logout`:
```bash
if type bcs >& /dev/null && [ "$PWD" != "$HOME" ] && [ "$PWD" != "$(readlink $HOME)" ]; then
	bcs add -t auto
fi
```

## Commands

`bcs add`:
```
usage: bcs add [-h] [-l LABEL] [-t TYPE] [-e ENV] [-E] [-k BLOCK] [-f] [-b] [dir]

positional arguments:
  dir                        name of directory to add (if not pwd)

optional arguments:
  -h, --help                 show this help message and exit
  -l LABEL, --label LABEL    label for directory to add (optional)
  -t TYPE, --type TYPE       type for directory to add (optional)
  -e ENV, --env ENV          env command for directory to add (optional)
  -E, --no-auto-env          disable automatic env determination
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
usage: bcs list [-h] [-a] [-l] [-t TYPE | -n | -k] [dir]

positional arguments:
  dir                        # or label of directory to list (lists all by default)

optional arguments:
  -h, --help                 show this help message and exit
  -a, --all                  list all properties for directory
  -l, --long                 use long listing (dates, labels, types)
  -r, --reverse              use reverse ordering w/ negative indices when listing all
  -t TYPE, --type TYPE       list all of specified type
  -n, --nonexistent          list only nonexistent directories
  -k, --blocked              list only blocked directories
```

`bcs rm`:
```
usage: bcs rm [-h] [-v] [-t TYPE] [-n] [-k] [-a] [-b] [dir [dir ...]]

positional arguments:
  dir                        #(s) or label(s) of directory(s) to remove from list

optional arguments:
  -h, --help                 show this help message and exit
  -v, --verbose              print removed directory(s)
  -r, --reverse              use reverse ordering w/ negative indices for verbose
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

The commands `bcd` and `bgo` are implemented as functions in bash.
They can be renamed by the installation script.
