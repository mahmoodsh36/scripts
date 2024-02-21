/usr/bin/env sh
mkdir -p "$WORK_DIR/" 2>/dev/null
cd "$WORK_DIR"

echo "setting up awesome"
git clone https://github.com/mahmoodsheikh36/awesome
cd awesome
./restore.sh

echo "setting up emacs"
git clone https://github.com/mahmoodsheikh36/dotfiles
cd dotfiles
./restore.sh

echo "setting up dotfiles"
git clone https://github.com/mahmoodsheikh36/otherdots
cd otherdots
./restore.sh

echo "setting up scripts"
git clone https://github.com/mahmoodsheikh36/scripts
cd scripts
./restore.sh

echo "setting up neovim"
git clone https://github.com/mahmoodsheikh36/nvim
cd nvim
./restore.sh
