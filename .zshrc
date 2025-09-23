# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =====================  Env =======================
export PATH=:.:$HOME/bin:/usr/local/bin:/home/$USER/.local/bin:/home/$USER/.npm-global/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# ====================  Theme ======================
ZSH_THEME="powerlevel10k/powerlevel10k"

# ====================  Plugins ====================
plugins=(
    git
    zsh-autosuggestions
    history-substring-search
    fzf
    colored-man-pages
    extract
    shrink-path
    zsh-syntax-highlighting
    fzf-tab
)
# zsh-autocompletions has to be loaded before sourcing omz
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

# ====================  Aliases ====================
alias py="python3"
alias vim="nvim"
alias ducks='while read -r line;do du -sh "$line";done < <(ls -1A) | sort -rh | head -n11'
gd_line() {
    gawk 'match($0,"^@@ -([0-9]+),([0-9]+) [+]([0-9]+),([0-9]+) @@",a){
          left=a[1]
          ll=length(a[2])
          right=a[3]
          rl=length(a[4])
          }
          /^(---|\+\+\+|[^-+ ])/{ print;next }
          { line=substr($0,2) }
          /^[-]/{ padding = right;
                  gsub(/./, " ", padding);
                  printf "-%"ll"s %"rl"s:%s\n",left++,padding,line; next }
          /^[+]/{ padding = left;
                  gsub(/./, " ", padding);
                  printf "+%"ll"s %"rl"s:%s\n",padding,right++,line; next }
                { printf " %"ll"s %"rl"s:%s\n",left++,right++,line }
        '
}
alias gd="git diff | gd_line | bat"
alias gu="git up"
alias grammar="aichat -r grammar -- $@"

# ==================== p10k config ==================
fpath+=${ZDOTDIR:-~}/.zsh_functions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# zoxide settings
eval "$(zoxide init zsh)"
unset ZSH_AUTOSUGGEST_USE_ASYNC

# ================= Activate env file =================
source ~/.env

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/fhsieh/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
