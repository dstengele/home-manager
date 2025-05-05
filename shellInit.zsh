
# -------------------------------------------------------------------
# Functions
# -------------------------------------------------------------------

function disk_ids() {
    ls -la /dev/disk/by-id/ | tail -n+4 | grep -v part | rev | sort | rev | awk '{ printf "%s\t%s\t%s\n", $(NF-2), $(NF-1), $(NF) }' | column -t
}

function command_exists () {
    type "$1" &> /dev/null ;
}

function pgw() {
    ping $( netstat -nr | grep 'default' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -n 1 );
}

function extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)        tar xjf $1        ;;
            *.tar.gz)         tar xzf $1        ;;
            *.bz2)            bunzip2 $1        ;;
            *.rar)            unrar x $1        ;;
            *.gz)             gunzip $1         ;;
            *.tar)            tar xf $1         ;;
            *.tbz2)           tar xjf $1        ;;
            *.tgz)            tar xzf $1        ;;
            *.zip)            unzip $1          ;;
            *.Z)              uncompress $1     ;;
            *)                echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function man() {
    env \
        LESS_TERMCAP_mb=$(printf "\e[1;31m") \
        LESS_TERMCAP_md=$(printf "\e[1;31m") \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
        man "$@"
}

function keychain_get_password () {
    security find-generic-password -w -s $1
}
function keychain_get_username () {
    security find-generic-password -s $1 | grep acct | head -n 7 | tail -n 1 | cut -d "\"" -f 4 | perl -pe 's[\\(?:([0-7]{1,3})|(.))] [defined($1) ? chr(oct($1)) : $2]eg'
}

function bwlockzone() {
    bw lock add dns -i file:/var/lib/bind/primary/$1
}

function ffind() {
    find $1 -iname \*$2\*
}

function gcal() {
    local GCAL_BIN="gcalcli"
    local OPTS=""

    if [[ $1 = "work" ]] ; then
        OPTS+="--configFolder ~/.gcalci/work --calendar Dennis"
        if [[ $2 = "team" ]] ; then
            OPTS+="--calendar Team\ Ghostbusters"
        fi
    fi
    if [[ $1 = "private" ]] ; then
        OPTS+="--configFolder ~/.gcalci/private --calendar Dennis"
    fi
    echo $GCAL_BIN $OPTS
}

function bweditnode() {
    if [ ! -z $BW_REPO_PATH ]
    then
        FILETOEDIT=$(grep -Rl $1\'] $BW_REPO_PATH/nodes)
    else
        FILETOEDIT=$(grep -Rl $1\'] $PWD)
    fi
    vim $FILETOEDIT
}

function assign-jira-license() {
    local GROUP_NAME="lig_Atlassian-JiraSoftware"
    local LICENSE_COUNT=600

    if get-user-groups "$1" | grep -q "$GROUP_NAME"; then
        echo "User is already a member, exiting."
        return 1
        fi

        local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    local USER_COUNT=$(get-jira-user-count)

    if [ $USER_COUNT -ge $LICENSE_COUNT ]; then
        echo "Max user count ($LICENSE_COUNT) reached, exiting."
        return 1
    fi

    echo "$USER_COUNT of $LICENSE_COUNT used. Adding new user."

    time az ad group member add --member-id "$USER_ID" --group "$GROUP_NAME"
}

function assign-jsm-license() {
    local GROUP_NAME="lig_Atlassian-JiraServiceManagement"
    local LICENSE_COUNT=200

    if get-user-groups "$1" | grep -q "$GROUP_NAME"; then
        echo "User is already a member, exiting."
        return 1
    fi

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    local USER_COUNT=$(get-jsm-user-count)

    if [ $USER_COUNT -ge $LICENSE_COUNT ]; then
        echo "Max user count ($LICENSE_COUNT) reached, exiting."
        return 1
    fi

    echo "$USER_COUNT of $LICENSE_COUNT used. Adding new user."

    time az ad group member add --member-id "$USER_ID" --group "$GROUP_NAME"
}

function assign-standarduser-license() {
    local GROUP_NAME="lig_Atlassian-StandardUser"

    if get-user-groups "$1" | grep -q "$GROUP_NAME"; then
        echo "User is already a member, exiting."
        return 1
    fi

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member add --member-id "$USER_ID" --group "$GROUP_NAME"
}

function assign-confluence-license() {
    local GROUP_NAME="lig_Atlassian-Confluence"
    local LICENSE_COUNT=600

    if get-user-groups "$1" | grep -q "$GROUP_NAME"; then
        echo "User is already a member, exiting."
        return 1
    fi

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    local USER_COUNT=$(get-confluence-user-count)

    if [ $USER_COUNT -ge $LICENSE_COUNT ]; then
        echo "Max user count ($LICENSE_COUNT) reached, exiting"
        return 1
    fi

    echo "$USER_COUNT of $LICENSE_COUNT used. Adding new user."

    time az ad group member add --member-id "$USER_ID" --group "$GROUP_NAME"
}

function assign-confluence-guest-license() {
    local GROUP_NAME="lig_Atlassian-Confluence-Guests"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member add --member-id "$USER_ID" --group "$GROUP_NAME"
}

function remove-jira-license() {
    local GROUP_NAME="lig_Atlassian-JiraSoftware"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member remove --member-id "$USER_ID" --group "$GROUP_NAME"
}

function remove-jsm-license() {
    local GROUP_NAME="lig_Atlassian-JiraServiceManagement"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member remove --member-id "$USER_ID" --group "$GROUP_NAME"
}

function remove-standarduser-license() {
    local GROUP_NAME="lig_Atlassian-StandardUser"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member remove --member-id "$USER_ID" --group "$GROUP_NAME"
}

function remove-confluence-license() {
    local GROUP_NAME="lig_Atlassian-Confluence"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member remove --member-id "$USER_ID" --group "$GROUP_NAME"
}

function remove-confluence-guest-license() {
    local GROUP_NAME="lig_Atlassian-Confluence-Guests"

    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    time az ad group member remove --member-id "$USER_ID" --group "$GROUP_NAME"
}

function get-user-groups() {
    local USER_ID=$({time az ad user list --filter "mail eq '$1'"} | jq -r 'first | .id')

    {time az ad user get-member-groups --id "$USER_ID"} | jq -r '.[] | .displayName' | sort
}

function get-active-group-members() { # $1 = groupName
    groupMembersCommand="{time az ad group member list -g $1 --query '[].id'} | jq -r '.[]' | sort"
    activeUsersCommand="{time az ad user list --filter 'accountEnabled eq true' --query '[].id'} | jq -r '.[]' | sort"

    comm -12 <(eval $groupMembersCommand) <(eval $activeUsersCommand)
}

function get-confluence-user-count() {
    get-active-group-members lig_Atlassian-Confluence | wc -l
}

function get-jira-user-count() {
    get-active-group-members lig_Atlassian-JiraSoftware | wc -l
}

function get-jsm-user-count() {
    get-active-group-members lig_Atlassian-JiraServiceManagement | wc -l
}

# -------------------------------------------------------------------
# Keybindings
# -------------------------------------------------------------------

bindkey -M vicmd '?' history-incremental-search-backward
bindkey "^R" history-incremental-search-backward

bindkey "^[." insert-last-word

bindkey "^[3;5~"             delete-char
bindkey "^A"                 beginning-of-line
bindkey "^E"                 end-of-line
bindkey "${terminfo[khome]}" beginning-of-line
bindkey "${terminfo[kend]}"  end-of-line
bindkey "^[[H"               beginning-of-line
bindkey "^[[F"               end-of-line

case "${TERM}" in
  cons25*|linux) # plain BSD/Linux console
    bindkey '\e[H'    beginning-of-line   # home
    bindkey '\e[F'    end-of-line         # end
    bindkey '\e[5~'   delete-char         # delete
    bindkey '[D'      emacs-backward-word # esc left
    bindkey '[C'      emacs-forward-word  # esc right
    ;;
  *rxvt*) # rxvt derivatives
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    # workaround for screen + urxvt
    bindkey '\e[7~'   beginning-of-line   # home
    bindkey '\e[8~'   end-of-line         # end
    bindkey '^[[1~'   beginning-of-line   # home
    bindkey '^[[4~'   end-of-line         # end
    ;;
  *xterm*) # xterm derivatives
    bindkey '\e[H'    beginning-of-line   # home
    bindkey '\e[F'    end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\e[1;5C' forward-word        # ctrl right
    bindkey '\e[1;5D' backward-word       # ctrl left
    # workaround for screen + xterm
    bindkey '\e[1~'   beginning-of-line   # home
    bindkey '\e[4~'   end-of-line         # end
    ;;
  screen)
    bindkey '^[[1~'   beginning-of-line   # home
    bindkey '^[[4~'   end-of-line         # end
    bindkey '\e[3~'   delete-char         # delete
    bindkey '\eOc'    forward-word        # ctrl right
    bindkey '\eOd'    backward-word       # ctrl left
    bindkey '^[[1;5C' forward-word        # ctrl right
    bindkey '^[[1;5D' backward-word       # ctrl left
    ;;
esac


# Load Bash Completions
autoload -U +X bashcompinit
bashcompinit
if [ -d /etc/bash_completion.d ]; then
    for bashcompletion in /etc/bash_completion.d/*; do
        source $bashcompletion
    done
fi

zstyle ':completion:*' menu select
zstyle ':completion::complete:*' gain-privileges 1
setopt COMPLETE_ALIASES

# Make sshrc use ssh completion
compdef sshrc=ssh

if command -v jira > /dev/null 2>&1; then
    source <(jira completion zsh)
fi

# Window Title
case "$TERM" in (rxvt|rxvt-*|st|st-*|*xterm*|(dt|k|E)term)
    local term_title () { print -n "\e]0;${(j: :q)@}\a" }
    precmd () {
      local DIR="$(print -P '[%c]%#')"
      term_title "$DIR" "zsh"
    }
    preexec () {
      local DIR="$(print -P '[%c]%#')"
      local CMD="${(j:\n:)${(f)1}}"
      term_title "$DIR" "$CMD"
    }
  ;;
esac

# Fix for WSL not propagating DISPLAY to dbus session
if test -f /proc/sys/fs/binfmt_misc/WSLInterop-late; then
    dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
fi

