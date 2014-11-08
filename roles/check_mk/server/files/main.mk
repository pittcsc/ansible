all_hosts = ["ops-01", "app-01", "web-01", "gateway-01"]

contacts.update({
  'slack': {
    'alias': u'Slack',
    'contactgroups': ['all'],
    'email': 'pittcsc+nagios@gmail.com',
    'host_notification_commands': 'check-mk-notify',
    'host_notification_options': 'durfs',
    'notification_method': ('flexible', [
      {
        'disabled': False,
        'host_events': ['d', 'u', 'r', 'f', 's', 'x'],
        'parameters': [],
        'plugin': 'slack',
        'service_events': ['w', 'u', 'c', 'r', 'f', 's', 'x'],
        'timeperiod': '24X7'
      }
    ]),
    'notification_period': '24X7',
    'notifications_enabled': True,
    'pager': '',
    'service_notification_commands': 'check-mk-notify',
    'service_notification_options': 'wucrfs'
  }
})
