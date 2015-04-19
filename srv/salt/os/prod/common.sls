{% set host         = salt['grains.get']('host') %}

copy_pwd_content_file:
  file.managed:
    - name: /etc/pwd
    - source: salt://common/{{ host }}/etc/pwd

/etc/hosts:
  file.managed:
    - source: salt://common/etc/hosts.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      host: {{ host }}