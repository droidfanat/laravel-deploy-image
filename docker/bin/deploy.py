import yaml
import io
import os
from envs import env


main = yaml.safe_load(open('docker-compose.yml'))
# Write YAML file main['services']['app']['depends_on'] = ['redis','mysql']
with io.open('docker-compose.yml', 'w', encoding='utf8') as outfile:
    yaml.dump(main, outfile, default_flow_style=True, allow_unicode=True)