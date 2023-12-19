# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =====================  Env =======================
export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# ====================  Theme ======================
ZSH_THEME="powerlevel10k/powerlevel10k"

# ====================  Plugins ====================
plugins=(
    git
    zsh-autosuggestions
    history-substring-search
    z
    fzf
    colored-man-pages
    extract
    shrink-path
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# ====================  Aliases ====================
alias py="python3"
alias bat="batcat"

fpath+=${ZDOTDIR:-~}/.zsh_functions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
