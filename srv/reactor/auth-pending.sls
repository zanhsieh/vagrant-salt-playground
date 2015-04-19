{% if not data['result'] and data['id'].startswith('min') %}
minion_remove:
  wheel.key.delete:
    - match: {{ data['id'] }}
minion_rejoin:
  local.cmd.run:
    - tgt: master1
    - arg:
      - ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "{{ data['id'] }}" 'sleep 10 && /etc/init.d/salt-minion restart'
{% endif %}

{% if 'act' in data and data['act'] == 'pend' and data['id'].startswith('min') %}
minion_add:
  wheel.key.accept:
    - match: {{ data['id'] }}
{% endif %}
