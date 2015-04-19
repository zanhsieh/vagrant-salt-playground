{% include 'common.sls' %}

create_file:
  cmd.run:
    - name: ls -la > /tmp/test.txt