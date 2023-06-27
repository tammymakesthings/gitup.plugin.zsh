# -*- coding: utf-8 -*-
###############################################################################
# gitup.plugin.zsh
#         oh-my-zsh plugin to pdate multiple git branches in a repo or set of repos.
#
# Tammy Cravit, tammy@tammymakesthings.com
# Version: 1.00, 2023-06-27
###############################################################################
# SPDX-FileCopyrightText: 2023 Tammy Cravit
# SPDX-License-Identifier: MIT
# SPDX-PackageDownloadLocation: https://github.com/tammymakesthings/gitup.plugin.zsh
###############################################################################

autoload colors && colors

if [[ ! -v GITUP_DIRS ]]; then
    export GITUP_DIRS=()
fi

if [[ ! -v GITUP_BRANCHES ]]; then
    export GITUP_BRANCHES=("qa", "main")
fi

_gitup_one () {
    if [[ "$1" = "" ]]; then
        if [[ -v "${GITUP_VERBOSE}" ]]; then
            echo $fg_bold[cyan] "_gitup_one" $fg[default] ": no directory provided; using "
                    $fg[magenta] "${PWD}" $fg[default]
        fi
        process_directory="$PWD"
    else
        if [[ -v "${GITUP_VERBOSE}" ]]; then
            echo $fg_bold[cyan] "_gitup_one" $fg[default] ": running git updates in " \
                    $fg[magenta] "$1" $fg[default]
        fi
        process_directory="$1"
    fi

    if [ ! -d "${process_directory}" ]; then
        echo $fg_bold[red] "_gitup_one" $fg[default] ": directory" $fg[cyan] "$process_directory" \
            $fg[default] "not found!"
        return 201
    fi

    if [ ! -d "${process_directory}/.git" ]; then
        echo $fg_bold[red] "_gitup_one" $fg[default] ": directory" $fg[cyan] "$process_directory" \
            $fg[default] "is not a git repo"
        return 201
    fi

    pushd "${process_directory}" >/dev/null 2>/dev/null
    echo $fg_bold[green] "_gitup_one" $fg[default] ": updating git repo clone in" \
        $fg[cyan] "$process_directory" $fg[default]

    if [[ -v "${GITUP_VERBOSE}" ]]; then
        echo $fg_bold[cyan] "_gitup_one" $fg[default] ": performing git fetch/prune operation"
    fi
    git fetch --prune --tags --prune-tags --progress --auto-maintenance

    current_branch="$(git rev-parse --abbrev-ref HEAD)"

    if [[ -v "${GITUP_VERBOSE}" ]]; then
        echo $fg_bold[cyan] "_gitup_one" $fg[default] ": obtaining list of branches"
    fi
    remote_heads=(${(f)"$(git ls-remote --heads 2>/dev/null | awk '{print $2}' | sed 's/refs\/heads\///')"})

    if [[ -v "${GITUP_VERBOSE}" ]]; then
        echo $fg_bold[cyan] "_gitup_one" $fg[default] ": current branch is " \
                $fg[magenta] "${current_branch}" $fg[default]
    fi

    for update_branch in $GITUP_BRANCHES
    do
        if [[ ${remote_heads[(r)${update_branch}]} == ${update_branch} ]]
        then
            if [[ -v "${GITUP_VERBOSE}" ]]; then
                echo $fg_bold[cyan] "_gitup_one" $fg[default] ": updating branch" \
                        $fg[magenta] "${update_branch}" $fg[default]
            fi
            if git show-ref --quiet refs/heads/$update_branch; then
                if [[ -v "${GITUP_VERBOSE}" ]]; then
                    echo $fg_bold[cyan] "_gitup_one" $fg[default] ": local branch" \
                            $fg[magenta] "${update_branch}" $fg[default] "exists; switching to it"
                fi
                git switch --quiet ${update_branch}
                git pull --autostash
            else
                if [[ -v "${GITUP_VERBOSE}" ]]; then
                    echo $fg_bold[cyan] "_gitup_one" $fg[default] ": local branch" \
                            $fg[magenta] "${update_branch}" $fg[default] "does not exist; checking it out"
                fi
                git switch --create --track ${update_branch} origin/${update_branch}
            fi
        else
            if [[ -v "${GITUP_VERBOSE}" ]]; then
                echo $fg_bold[cyan] "_gitup_one" $fg[default] ": remote branch" \
                        $fg[magenta] "${update_branch}" $fg[default] "not found ; skipping" \
                        $fg[default]
            fi
            true
        fi
    done
    if [ "${current_branch}" != "" ]
    then
        if [[ -v "${GITUP_VERBOSE}" ]]; then
            echo $fg_bold[cyan] "_gitup_one" $fg[default] \
                    ": restoring original branch" \
                    $fg[magenta] "${current_branch}" $fg[default]
        fi
        git switch --quiet ${current_branch}
    fi

    popd >/dev/null 2>/dev/null
    return 0
}

_gitup_all_configured() {
    if [[ -v GITUP_DIRS ]]
    then
        for process_dir in ${GITUP_DIRS}
        do
            if [ -d "${process_dir}" ]; then
                _gitup_one "${process_dir}"
            else
            echo $fg_bold[magenta] "WARNING" $fg[default] ": the directory" $fg[cyan] "${process_dir}" \
                $fg[default] "was not found; skipping it."
            fi
        done
    else
        return -1
    fi
}

gitup() {
    if [ "$1" = "" ]; then
        if [ -d "${PWD}/.git" ]; then
            echo $fg_bold[yellow] "gitup" $fg[default] ": current directory" $fg[cyan] \
                "${PWD}" $fg[default] "is a git repo clone; updating it"
            _gitup_one "${PWD}"
        else
            echo $fg_bold[yellow] "gitup" $fg[default] ": current directory" $fg[cyan] \
                "${PWD}" $fg[default] \
                "is not a git repo clone; updating configured repo dirs instead"
            _gitup_all_configured
        fi
    else
        for repo_dir in $*
        do
            if [ -d "$1" ]; then
                _gitup_one "${repo_dir}"
            else
                echo $fg_bold[red] "gitup" $fg[default] ": ERROR: directory" $fg[cyan] "${repo_dir}" \
                    $fg[default] "not found!"
            fi
        done
    fi
}

