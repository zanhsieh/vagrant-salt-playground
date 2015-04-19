highstate_run:
  local.state.highstate:
    - tgt: {{ data['id'] }}
    - arg: 
      - saltenv=os_tb
