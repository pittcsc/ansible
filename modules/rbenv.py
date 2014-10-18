from ansible.module_utils.basic import *

def versions(module):
  (status, output, error) = module.run_command('rbenv versions --bare', check_rc=True)
  return output.splitlines()

def global_version(module):
  (status, output, error) = module.run_command('rbenv global', check_rc=True)
  return output

def install(module):
  if not module.check_mode:
    command = 'rbenv_install %s' % module.params['version']
    module.run_command(command, check_rc=True)

def uninstall(module):
  if not module.check_mode:
    command = 'rbenv uninstall -f %s' % module.params['version']
    module.run_command(command, check_rc=True)

def set_global_version(module):
  if not module.check_mode:
    command = 'rbenv global %s' module.params['version']
    module.run_command(command, check_rc=True)

def main():
  module = AnsibleModule(
    argument_spec = dict(
      version = dict(required=True, type='str'),
      state = dict(required=False, type='str', default='installed', choices=['installed', 'present', 'absent', 'global'])
    ),
    supports_check_mode = True
  )
  version = module.params['version']
  state = module.params['state']
  changed = False

  if state in ['installed', 'present']:
    if not version in versions(module):
      install(module)
      changed = True
  elif state == 'absent':
    if version in versions(module):
      uninstall(module)
      changed = True
  elif state == 'global':
    if not version == global_version(module):
      set_global_version(module)
      changed = True

  module.exit_json(changed=changed, version=version, state=state)

main()
