# gitup plugin for oh-my-zsh

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)][codeofconduct]

The `gitup` plugin for [oh-my-zsh][ohmyzsh] simplifies the task of updating
multiple branches in [Git][git] repo clones at the same time. It can be
configured with a list of branches and will operate on one or more repo
clone directories to update all of the named branches.

## Installing and Using the Plugin

### Installation

To install the plugin, perform these steps:

1. Clone this repo to your [oh-my-zsh][ohmyzsh] plugins directory like so:

    ```shell
    $ git clone https://github.com/tammymakesthings/gitup.plugin.zsh.git ~/.oh-my-zsh/plugins/gitup
    ```

2. Add the following lines to your `~/.zshrc` file to enable and configure the plugin:

    ```shell
    plugins += (gitup)
    export GITUP_DIRS=(...)  # See the Configuration section of the readme
    ```

3. Reload your shell environment.

### Configuration

There are three configuration variables that control the plugin's behavior:

| **Variable**     | **Purpose**                                                                                             | **Default Value** |
| ---------------- | ------------------------------------------------------------------------------------------------------- | ----------------- |
| `GITUP_DIRS`     | An array listing the directories you want to update if the `gitup` command is called with no arguments. | `()`              |
| `GITUP_BRANCHES` | An array listing the branch names of the branches you want `gitup` to update.                           | `("qa", "main")`  |
| `GITUP_VERBOSE`  | Enables more verbose debugging output if set to any value.                                              | *not set*         |

It doesn't matter if these variables are set before or after the `gitup`
plugin is loaded in your `~/.zshrc` file.

### Usage

Once the plugin is loaded, the `gitup` command is available in your shell. The
command can operate in two modes: with or without command-line arguments.

If the `gitup` command is run **with** arguments, each argument should be the
path to a directory. If the directory exists, and is a [git][git] repo clone,
the update process will be run in that directory. If the directory exists
but is not a [git][git] repo clone, it will be skipped. If the directory does
not exist, an error message will be printed.

If the `gitup` command is run **without** arguments, **and** the current
directory *is* a [git][git] repo clone, the update process will be run on the
current directory.

If the `gitup` command is run **without** arguments, **and** the current
directory *is not* a [git][git] repo clone, the update process will be run
on the list of directories specified in the `GITUP_DIRS` variable.

In all cases, the update process proceeds as described in the next section.

## How It Works

In whatever mode the command is operating, the `gitup` command calls an
internal function (named `_gitup_one`) to perform the update. The steps
performed by `_gitup_one` are as follows:

1. The current working directory is temporarily changed (by `pushd`)
   to the repo directory to be operated on.

2. The repo is updated in a fetch/prune. That is, the plugin performs the
   following [git][git] command:

   ```shell
   git fetch --prune --tags --prune-tags --progress --auto-maintenance
   ```

3. The currently active branch is retrieved and saved.

4. For each branch listed in the `GITUP_BRANCHES` array, `gitup` switches
   to that branch (with the `git switch`) command. As noted above, if the
   branch exists on the remote but not the local, it's checked out and
   a local tracking branch is created. Otherwise, it's selected and a
   `git pull --autostash` is run to pull changes .

5. The previously current branch is selected (again, via a `git switch`
   command.)

6. The previous working directory is restored (by `popd`).

When the `gitup` command is run with no arguments, it checks if the current
directory has a `.git` subdirectory. If it does, it invokes the `_gitup_one`
function, passing it the value of `$PWD` to update the repo in the current
directory. Otherwise, it invokes another internal function, named
`_gitup_all_configured` which in turn invokes `_gitup_one` for each
directory in the `GITUP_DIRS` list.

## Contributing

Please note that this project is released with a
[Contributor Code of Conduct][codeofconduct]. By participating in this
project you agree to abide by its terms. Participation
covers any forum used to converse about CircuitPython including unofficial
and official spaces. Failure to do so will result in corrective actions such
as time out or ban from the project.

### Licensing

By contributing to this repository you are certifying that you have all necessary
permissions to license the code under an MIT License. You still retain the
copyright but are granting many permissions under the [MIT License][mitlicense].

If you have an employment contract with your employer please make sure that they
don't automatically own your work product. Make sure to get any necessary approvals
before contributing. Another term for this contribution off-hours is moonlighting.

### Author

[gitup.plugin.zsh][repo], Copyright 2023, [Tammy Cravit][tammy].
Released under the terms of the [MIT License][mitlicense]

### Revision History

| **Date**   | **Version** | **Revision Notes** |
| ---------- | ----------- | ------------------ |
| 2023-06-27 | 1.00        | Initial Revision   |

[codeofconduct]: ./CODE_OF_CONDUCT.md
[git]: https://git-scm.org/
[mitlicense]: ./LICENSE.md
[ohmyzsh]: https://ohmyz.sh/
[repo]: https://github.com/tammymakesthings/gitup.plugin.zsh.git
[tammy]: https://github.com/tammymakesthings
