RUNNING=0

if [ -f ~/.ssh/agent ]; then
  . ~/.ssh/agent

  if ps -o comm ${SSH_AGENT_PID} | grep ssh-agent; then
    RUNNING=1
  fi
fi

if [[ $RUNNING == 0 ]]; then
  ssh-agent > ~/.ssh/agent
  . ~/.ssh/agent
  ssh-add
fi

unset RUNNING
