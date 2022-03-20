# store colors

function color_my_prompt {
   local MAGENTA="\[\033[0;35m\]"
   local YELLOW="\[\033[01;33m\]"
   local BLUE="\[\033[01;34m\]"
   local LIGHT_GRAY="\[\033[0;37m\]"
   local CYAN="\[\033[0;36m\]"
   local GREEN="\[\033[01;32m\]"
   local RED="\[\033[0;31m\]"
   local VIOLET='\[\033[01;35m\]'
   local DEFAULT="\[\033[0m\]"
   local __user_and_host="$GREEN\u$DEFAULT@$CYAN\h"
   local __cur_location="$BLUE\W"           # capital 'W': current directory, small 'w': full file path
   local __git_branch_color="$GREEN"
   local __prompt_tail="$VIOLET$"
   local __user_input_color="$DEFAULT"
   local __git_branch='$(__git_ps1)'; 
	      
  # colour branch name depending on state
   if [[ "$(__git_ps1)" =~ "*" ]]; then     # if repository is dirty
      __git_branch_color="$RED"
   elif [[ "$(__git_ps1)" =~ "$" ]]; then   # if there is something stashed
      __git_branch_color="$YELLOW"
   elif [[ "$(__git_ps1)" =~ "%" ]]; then   # if there are only untracked files
      __git_branch_color="$LIGHT_GRAY"
   elif [[ "$(__git_ps1)" =~ "+" ]]; then   # if there are staged files
      __git_branch_color="$CYAN"
   fi
										   
   # Build the PS1 (Prompt String)
   PS1="$__user_and_host $__cur_location$__git_branch_color$__git_branch $__prompt_tail$__user_input_color "
}
										     
# configure PROMPT_COMMAND which is executed each time before PS1
export PROMPT_COMMAND=color_my_prompt
										     
# if .git-prompt.sh exists, set options and execute it
if [ -f ~/.bashrc.d/git-prompt.sh ]; then
    GIT_PS1_SHOWDIRTYSTATE=true
    GIT_PS1_SHOWSTASHSTATE=true
    GIT_PS1_SHOWUNTRACKEDFILES=true
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_HIDE_IF_PWD_IGNORED=true
    GIT_PS1_SHOWCOLORHINTS=true
    . ~/.bashrc.d/git-prompt.sh
fi

