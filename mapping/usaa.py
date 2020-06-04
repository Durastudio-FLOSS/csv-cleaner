from __future__ import (
    absolute_import, division, print_function, unicode_literals)

from operator import itemgetter

mapping = {
    'has_header': True,
    'delimiter': ',',
    'bank': 'USAA',
    'currency': 'USD',
    'date': itemgetter('Date'),
    'payee': itemgetter('Payee'),
    'account': itemgetter('Account'),
    'amount': itemgetter('Amount'),
}
