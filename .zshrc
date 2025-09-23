# ---------- p10k instant prompt ----------
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ---------- PATH ----------
# Keep $HOME/bin and $HOME/.local/bin first; avoid hard-coded /home/$USER on macOS
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
# Prefer Homebrew paths on macOS
if [[ "$OSTYPE" == darwin* ]] && command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
fi

# ---------- Oh My Zsh ----------
export ZSH="$HOME/.oh-my-zsh"

# ---------- Theme ----------
ZSH_THEME="powerlevel10k/powerlevel10k"

# ---------- Plugins ----------
plugins=(
  git
  fzf                      # OMZ fzf plugin (bindings/completion)
  zsh-completions          # needs compinit after fpath set
  zsh-autosuggestions
  history-substring-search
  extract
  colored-man-pages
  shrink-path
  fzf-tab                  # needs fzf installed; enhances completion UI
  zsh-syntax-highlighting  # keep last
)

# Ensure custom plugins are in fpath before compinit (for zsh-completions).
fpath+=("${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src")

# Initialize completion system once.
autoload -U compinit
compinit -u

# Load Oh My Zsh (loads plugins from the list above).
source "$ZSH/oh-my-zsh.sh"

# ---------- Aliases ----------
alias py="python3"
# Only alias vim to nvim if nvim exists
if command -v nvim >/dev/null 2>&1; then
  alias vim="nvim"
fi

# show top 10 sizes of current dir entries
alias ducks='while read -r line; do du -sh "$line"; done < <(ls -1A) | sort -rh | head -n11'

# git diff pretty printer (requires bat or batcat shim)
gd_line() {
  gawk 'match($0,"^@@ -([0-9]+),([0-9]+) [+]([0-9]+),([0-9]+) @@",a){
        left=a[1]; ll=length(a[2]); right=a[3]; rl=length(a[4])}
        /^(---|\+\+\+|[^-+ ])/{ print; next }
        { line=substr($0,2) }
        /^[-]/{ padding = right; gsub(/./," ",padding);
                printf "-%"ll"s %"rl"s:%s\n",left++,padding,line; next }
        /^[+]/{ padding = left;  gsub(/./," ",padding);
                printf "+%"ll"s %"rl"s:%s\n",padding,right++,line; next }
              { printf " %"ll"s %"rl"s:%s\n",left++,right++,line }'
}
alias gd="git diff | gd_line | bat"
alias gu="git up"
alias grammar="aichat -r grammar -- $@"

# ---------- p10k config ----------
fpath+=${ZDOTDIR:-~}/.zsh_functions
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# ---------- Optional tools ----------
# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
# Disable async suggestions if you prefer synchronous feel
unset ZSH_AUTOSUGGEST_USE_ASYNC

# ---------- Load .env if present ----------
if [[ -f "$HOME/.env" ]]; then
  set -o allexport
  source "$HOME/.env"
  set +o allexport
fi

# ---------- Docker Desktop completions (macOS) ----------
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
  autoload -Uz compinit
  compinit -u
fi
