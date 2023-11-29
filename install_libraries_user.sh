#!/bin/bash

set -e

DEBUG_LEVEL=0

git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
#rm -r build/  # clear the CMake cache
make CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/neovim"
make install
echo "export PATH=\$HOME/neovim/bin:\$PATH" >> /home/$USER/.zshrc

curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash

echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USER/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/$USER/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /home/$USER/.zshrc
export NVM_DIR="/home/$USER/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install --lts --latest-npm
npm install --global @pnpm/exe

curl -fsSL "https://get.pulumi.com" | sh
echo "export PATH=\$PATH:\$HOME/.pulumi/bin" >> /home/$USER/.zshrc

mkdir krew
pushd krew
wget -q -O archive.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/').tar.gz"
tar zxvf archive.tar.gz
./"krew-$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" install krew
popd
rm -r -f krew
echo "export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\"" >> /home/$USER/.zshrc

kubectl completion zsh > /home/$USER/.oh-my-zsh/plugins/history-substring-search/_kubectl

wget -q -O f.sh https://sh.rustup.rs
chmod +x f.sh
./f.sh -y
rm f.sh
echo "export PATH=\$PATH:\$HOME/.cargo/bin" >> /home/$USER/.zshrc
export PATH=$PATH:$HOME/.cargo/bin

wget -q -O - "https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh" | bash

echo "# Setup path for Go" >> /home/$USER/.zshrc
echo "export GOROOT=/home/\$USER/.go" >> /home/$USER/.zshrc
echo "export PATH=\$GOROOT/bin:\$PATH" >> /home/$USER/.zshrc
echo "export GOPATH=/home/\$USER/go" >> /home/$USER/.zshrc
echo "export PATH=\$GOPATH/bin:\$PATH" >> /home/$USER/.zshrc

# Cloudflare: worker cli, wrangler
npm install --global wrangler

# Rust: install cargo-watch 
cargo install cargo-watch

# Rust: install wasm32 target 
rustup target add wasm32-unknown-unknown

# Supabase: install deno cli
curl -fsSL https://deno.land/x/install/install.sh | sh

echo "export DENO_ROOT=/home/\$USER/.deno" >> /home/$USER/.zshrc
echo "export DENO_INSTALL=\$DENO_ROOT/bin/deno" >> /home/$USER/.zshrc
echo "export PATH=\$DENO_ROOT/bin:\$PATH" >> /home/$USER/.zshrc


# This does not work, cannot be installed globally, instead `npm i supabase --save-dev`
# Supabase: install supabase cli
# npm install --global supabase

# Utility: install lite-server
npm install --global lite-server

# Utility: install wasmtime
curl https://wasmtime.dev/install.sh -sSf | bash

# wget -q -O /usr/local/bin/liqoctl "https://get.liqo.io/liqoctl-$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')"
# chmod +x /usr/local/bin/liqoctl
#liqoctl completion zsh > /home/$USER/.oh-my-zsh/plugins/history-substring-search/_liqoctl

