#!/usr/bin/env sh
# script to setup dotfiles and (possibly) more

homedir=/home/mahmooz #"$HOME", im using a different variable than the standard for no good reason
export HOME="$homedir" 

handle_repo() {
    remote_repo="$1"
    local_dir_path="$2"
    repo_name="$(basename "$remote_repo")"
    local_path="$local_dir_path/$repo_name"
    echo "== handling $repo_name =="
    if [ ! -d "$local_path" ]; then
        mkdir -p "$local_dir_path" 2>/dev/null
        cd "$local_dir_path"
        git clone "$remote_repo" "$repo_name"
    else
        cd "$local_path"
        git pull
    fi
}

handle_repo "https://github.com/mahmoodsheikh36/dotfiles" "$homedir/work"
source "$homedir/work/dotfiles/restore.sh"
handle_repo "https://github.com/mahmoodsheikh36/awesome" "$homedir/.config"
handle_repo "https://github.com/mahmoodsheikh36/scripts" "$homedir/work"
handle_repo "https://github.com/mahmoodsheikh36/dotfiles" "$homedir/.config"